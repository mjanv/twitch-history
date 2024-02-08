defmodule TwitchStoryWeb.DashboardLive.Home do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  alias Phoenix.LiveView.AsyncResult
  alias TwitchStory.Request.{Channels, Commerce, Community, Metadata, SiteHistory}

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:request_id, nil)
    |> assign(:metadata, AsyncResult.loading())
    |> assign(:stats, AsyncResult.loading())
    |> assign(:channels, AsyncResult.loading())
    |> assign(:chat_messages, AsyncResult.loading())
    |> assign(:minute_watched, AsyncResult.loading())
    |> allow_upload(:request, accept: ~w(.zip), max_file_size: 999_000_000, max_entries: 1)
    |> then(fn socket -> {:ok, socket} end)
  end

  @impl true
  def handle_params(%{"id" => request_id}, _uri, socket) do
    file = to_charlist(path_priv(request_id))

    socket
    |> assign(:request_id, request_id)
    |> start_async(:metadata, fn -> Metadata.read(file) end)
    |> start_async(:stats, fn ->
      %{
        follows: file |> Community.Follows.read() |> SiteHistory.n_rows(),
        chat_messages: file |> SiteHistory.ChatMessages.read() |> SiteHistory.n_rows(),
        hours_watched: file |> SiteHistory.MinuteWatched.read() |> SiteHistory.n_rows(60),
        subscriptions: file |> Commerce.Subs.read() |> SiteHistory.n_rows()
      }
    end)
    |> start_async(:channels, fn -> Channels.channels(file) end)
    |> start_async(:chat_messages, fn ->
      file
      |> SiteHistory.ChatMessages.read()
      |> SiteHistory.ChatMessages.group_month_year()
      |> SiteHistory.nominal_date_column()
    end)
    |> start_async(:minute_watched, fn ->
      file
      |> SiteHistory.MinuteWatched.read()
      |> SiteHistory.MinuteWatched.group_month_year()
      |> SiteHistory.nominal_date_column()
    end)
    |> then(fn socket -> {:noreply, socket} end)
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event("search", %{"query" => _query}, socket) do
    {:noreply, socket}
  end

  def handle_event("validate", _params, socket) do
    socket.assigns.uploads.request
    |> Map.get(:entries)
    |> List.first()
    |> case do
      nil ->
        socket

      entry ->
        socket.assigns.uploads.request
        |> upload_errors(entry)
        |> Enum.reduce(socket, fn error, socket ->
          put_flash(socket, :error, error_to_string(error))
        end)
    end
    |> then(fn socket -> {:noreply, socket} end)
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :request, ref)}
  end

  @impl true
  def handle_event("save", _params, socket) do
    socket
    |> consume_uploaded_entries(:request, fn %{path: path}, _entry ->
      request = Metadata.read(to_charlist(path)).request_id
      :ok = File.cp!(path, path_priv(request))
      {:ok, request}
    end)
    |> List.first()
    |> then(fn request -> {:noreply, push_patch(socket, to: ~p"/request/#{request}")} end)
  end

  @impl true
  def handle_async(task, {:ok, data}, socket) do
    socket.assigns
    |> Map.get(task)
    |> AsyncResult.ok(data)
    |> then(fn result -> {:noreply, assign(socket, task, result)} end)
  end

  @impl true
  def handle_async(task, {:exit, reason}, socket) do
    socket
    |> put_flash(:error, "Task #{task} failed: #{inspect(reason)}")
    |> assign(task, %AsyncResult{})
    |> then(fn socket -> {:noreply, socket} end)
  end

  def error_to_string(:too_large), do: "Too large"
  def error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  def error_to_string(:external_client_failure), do: "Something went terribly wrong"

  defp path_priv(request) do
    :twitch_story
    |> Application.app_dir("priv/static/uploads")
    |> Path.join(request)
    |> then(fn dest -> dest <> ".zip" end)
  end
end
