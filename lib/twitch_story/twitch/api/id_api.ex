defmodule TwitchStory.Twitch.Api.IdApi do
  @moduledoc false

  @api Application.compile_env(:twitch_story, :twitch_api)

  def app_access_token do
    Req.new(base_url: @api[:id_api_url])
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
end
