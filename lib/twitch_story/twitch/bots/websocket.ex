defmodule TwitchStory.Twitch.Bots.Websocket do
  @moduledoc false

  use WebSockex

  @keep_alive 30
  @url "wss://eventsub.wss.twitch.tv/ws?keepalive_timeout_seconds=#{@keep_alive}"

  def start_link(_state) do
    WebSockex.start_link(@url, __MODULE__, %{url: @url, session_id: nil})
  end

  def handle_connect(_conn, state) do
    {:ok, state}
  end

  def handle_disconnect(_conn, state) do
    {:ok, state}
  end

  def handle_frame({type, msg}, state) do
    message = Jason.decode!(msg)
    IO.puts("Received Message - Type: #{inspect(type)} -- Message: #{inspect(message)}")

    case handle(message) do
      {:ok, metadata} ->
        {:ok, Map.merge(state, metadata)}

      _ ->
        {:ok, state}
    end
  end

  def handle_cast({:send, {type, msg} = frame}, state) do
    IO.puts("Sending #{type} frame with payload: #{msg}")
    {:reply, frame, state}
  end

  def terminate(_reason, _state) do
    :ok
  end

  def handle(%{
        "metadata" => %{
          "message_id" => _,
          "message_timestamp" => _,
          "message_type" => "session_welcome"
        },
        "payload" => %{
          "session" => %{
            "connected_at" => _,
            "id" => session_id,
            "keepalive_timeout_seconds" => @keep_alive,
            "reconnect_url" => _,
            "recovery_url" => _,
            "status" => "connected"
          }
        }
      }) do
    {:ok, %{session_id: session_id}}
  end

  def handle(_), do: :ok
end
