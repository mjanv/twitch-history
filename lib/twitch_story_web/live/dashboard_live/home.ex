defmodule TwitchStoryWeb.DashboardLive.Home do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  alias TwitchStory.Request.Metadata

  alias TwitchStoryWeb.DashboardLive.Components

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> allow_upload(:request, accept: ~w(.zip), max_file_size: 999_000_000, max_entries: 1)
    |> then(fn socket -> {:ok, socket} end)
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket
    |> handle_action(socket.assigns.live_action, params)
    |> then(fn socket -> {:noreply, socket} end)
  end

  def handle_action(socket, _action, %{"id" => request_id}) do
    socket
    |> assign(:request_id, request_id)
    |> assign(:file, to_charlist(path_priv(request_id)))
  end

  def handle_action(socket, _action, _params), do: socket

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
    |> then(fn request ->
      {:noreply, push_patch(socket, to: ~p"/request/overview?id=#{request}")}
    end)
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
