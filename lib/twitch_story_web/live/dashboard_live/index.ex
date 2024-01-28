defmodule TwitchStoryWeb.DashboardLive.Index do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  alias Phoenix.LiveView.AsyncResult
  alias TwitchStory.Request

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:files, [])
      |> assign(:metadata, AsyncResult.loading())
      |> allow_upload(:request, accept: ~w(.zip), max_file_size: 999_000_000, max_entries: 1)

    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
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
    {:noreply, cancel_upload(socket, :avatar, ref)}
  end

  @impl true
  def handle_event("save", _params, socket) do
    files =
      consume_uploaded_entries(socket, :request, fn %{path: path}, _entry ->
        dest =
          Path.join(
            Application.app_dir(:twitch_story, "priv/static/uploads"),
            Path.basename(path)
          ) <> ".zip"

        File.cp!(path, dest)
        {:ok, dest}
      end)

    send(self(), {:work, List.first(files)})

    {:noreply, update(socket, :files, &(&1 ++ files))}
  end

  #
  @impl true
  def handle_info({:work, file}, socket) do
    socket =
      socket
      |> start_async(:metadata, fn -> Request.Metadata.read(to_charlist(file)) end)

    {:noreply, socket}
  end

  @impl true
  def handle_async(:metadata, {:ok, metadata}, socket) do
    result = AsyncResult.ok(socket.assigns.metadata, metadata)
    {:noreply, assign(socket, :metadata, result)}
  end

  def error_to_string(:too_large), do: "Too large"
  def error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  def error_to_string(:external_client_failure), do: "Something went terribly wrong"
end
