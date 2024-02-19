defmodule TwitchStory.Twitch.Api.AuthApi do
  @moduledoc false

  @api Application.compile_env(:twitch_story, :twitch_api)

  def get(url: url, token: token) do
    [base_url: @api[:api_url]]
    |> Req.new()
    |> Req.Request.put_headers([
      {"Authorization", "Bearer #{token}"},
      {"Client-Id", @api[:client_id]}
    ])
    |> Req.get(url: url)
  end

  def get(url: url) do
    [base_url: @api[:api_url]]
    |> Req.new()
    |> Req.Request.put_headers([
      {"Authorization", "Bearer #{app_access_token()}"},
      {"Client-Id", @api[:client_id]}
    ])
    |> Req.get(url: url)
  end

  def user_access_token(client_secret) do
    token(
      client_id: @api[:client_id],
      client_secret: client_secret,
      grant_type: "client_credentials"
    )
  end

  def app_access_token do
    token(
      client_id: @api[:client_id],
      client_secret: @api[:client_secret],
      grant_type: "client_credentials"
    )
  end

  defp token(params) do
    Req.new(base_url: @api[:id_api_url])
    |> Req.Request.put_headers([{"Content-Type", "application/x-www-form-urlencoded"}])
    |> Req.post(
      url: "/oauth2/token",
      params: params
    )
    |> case do
      {:ok,
       %Req.Response{
         status: 200,
         body: %{"token_type" => "bearer", "access_token" => access_token}
       }} ->
        access_token

      {:error, %Req.Response{}} ->
        ""
    end
  end
end
