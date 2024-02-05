defmodule TwitchStoryWeb.DashboardLive.Home do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  alias Phoenix.LiveView.AsyncResult
  alias TwitchStory.Request.{Commerce, Community, Metadata, SiteHistory}

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:files, [])
    |> assign(:metadata, AsyncResult.loading())
    |> assign(:stats, AsyncResult.loading())
    |> assign(:chat_messages, AsyncResult.loading())
    |> assign(:minute_watched, AsyncResult.loading())
    |> allow_upload(:request, accept: ~w(.zip), max_file_size: 999_000_000, max_entries: 1)
    |> then(fn socket -> {:ok, socket} end)
  end

  @impl true
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
      dest =
        Path.join(
          Application.app_dir(:twitch_story, "priv/static/uploads"),
          Path.basename(path)
        ) <> ".zip"

      File.cp!(path, dest)
      {:ok, dest}
    end)
    |> tap(fn files -> send(self(), {:work, to_charlist(List.first(files))}) end)
    |> then(fn files -> {:noreply, update(socket, :files, &(&1 ++ files))} end)
  end

  @impl true
  def handle_info({:work, file}, socket) do
    socket
    |> start_async(:metadata, fn -> Metadata.read(file) end)
    |> start_async(:stats, fn ->
      %{
        follows: Community.Follows.n(file),
        chat_messages: SiteHistory.ChatMessages.n(file),
        hours_watched: SiteHistory.MinuteWatched.n(file),
        subscriptions: Commerce.Subs.n(file)
      }
    end)
    |> start_async(:chat_messages, fn ->
      file
      |> SiteHistory.ChatMessages.read()
      |> SiteHistory.preprocess()
      |> SiteHistory.years(2019, 2023)
      |> SiteHistory.group_month()
    end)
    |> start_async(:minute_watched, fn ->
      file
      |> SiteHistory.MinuteWatched.read()
      |> SiteHistory.MinuteWatched.preprocess(threshold: 60 * 6)
      |> SiteHistory.MinuteWatched.years(2019, 2023)
      |> SiteHistory.MinuteWatched.group_month()
    end)
    |> then(fn socket -> {:noreply, socket} end)
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
end
