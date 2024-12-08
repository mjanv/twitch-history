defmodule TwitchStoryWeb.WebhookController do
  @moduledoc false

  use TwitchStoryWeb, :controller

  require Logger

  def event(%Plug.Conn{req_headers: headers} = conn, event) do
    case at(headers, "twitch-eventsub-message-type") do
      "webhook_callback_verification" ->
        send_resp(conn, 200, event["challenge"])

      "notification" ->
        # Do something with the event
        send_resp(conn, 204, "")

      "revocation" ->
        Logger.error("Revocation #{inspect(event)}")
        send_resp(conn, 204, "")
    end
  end

  defp at(headers, key) do
    headers
    |> List.keyfind(key, 0)
    |> elem(1)
  end
end
