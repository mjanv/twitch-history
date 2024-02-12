defmodule TwitchStory.Apis.TwitchApi do
  @moduledoc false

  @api Application.compile_env(:twitch_story, :twitch_api)

  def token do
    Req.new(base_url: "https://id.twitch.tv")
    |> Req.Request.put_headers([{"Content-Type", "application/x-www-form-urlencoded"}])
    |> Req.post(
      url: "/oauth2/token",
      params: [
        client_id: @api[:client_id],
        client_secret: @api[:client_secret],
        grant_type: "client_credentials"
      ]
    )
    |> case do
      {:ok,
       %Req.Response{
         status: 200,
         body: %{"token_type" => "bearer", "access_token" => access_token}
       }} ->
        access_token

      _ ->
        nil
    end
  end

  def emotes(broadcaster_id) do
    Req.new(base_url: "https://api.twitch.tv")
    |> Req.Request.put_headers([
      {"Authorization", "Bearer #{token()}"},
      {"Client-Id", @api[:client_id]}
    ])
    |> Req.get(url: "/helix/chat/emotes?broadcaster_id=#{broadcaster_id}")
    |> case do
      {:ok, %Req.Response{status: 200, body: %{"data" => data}}} -> data
      _ -> []
    end
    |> Enum.map(fn emote -> Map.take(emote, ["name"]) end)
  end
end
