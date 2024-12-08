defmodule TwitchStoryWeb.Plug.Hmac do
  @moduledoc false

  import Plug.Conn

  @secret Application.compile_env(:twitch_story, :hmac_secret, "secretsecret")

  def init(args), do: args

  def call(%Plug.Conn{req_headers: headers} = conn, _args) do
    if List.keymember?(headers, "twitch-eventsub-message-id", 0) do
      hash_a =
        at(headers, "twitch-eventsub-message-signature")

      hash_b =
        conn
        |> read_body()
        |> then(fn {:ok, body, _} ->
          at(headers, "twitch-eventsub-message-id") <>
            at(headers, "twitch-eventsub-message-timestamp") <>
            body
        end)
        |> then(fn code -> :crypto.mac(:hmac, :sha256, @secret, code) end)
        |> Base.encode16()
        |> then(fn code -> "sha256=" <> String.downcase(code) end)

      if :crypto.hash_equals(hash_a, hash_b) do
        conn
      else
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(403, "Forbidden")
        |> halt()
      end
    else
      conn
    end
  end

  def call(conn, _args), do: conn

  defp at(headers, key) do
    headers
    |> List.keyfind(key, 0)
    |> elem(1)
  end
end
