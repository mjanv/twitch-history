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
    [
      client_id: @api[:client_id],
      client_secret: @api[:client_secret],
      grant_type: "client_credentials"
    ]
    |> token()
    |> case do
      {:ok, %{"access_token" => access_token}} -> access_token
      _ -> ""
    end
  end

  def refresh_access_token(refresh_token) do
    token(
      client_id: @api[:client_id],
      client_secret: @api[:client_secret],
      grant_type: "refresh_token",
      refresh_token: refresh_token
    )
    |> case do
      {:ok, body} ->
        body
        |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
        |> Enum.into(%{})
        |> Map.drop([:scope, :token_type, :expires_in])
        |> then(fn body -> {:ok, body} end)

      {:error, reason} ->
        {:error, reason}
    end
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
         body: %{"token_type" => "bearer"} = body
       }} ->
        {:ok, body}

      {:ok, %Req.Response{}} ->
        {:ok, %{}}

      {:error, %Req.Response{}} ->
        {:error, %{}}
    end
  end
end
