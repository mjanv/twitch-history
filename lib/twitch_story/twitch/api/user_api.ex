defmodule TwitchStory.Twitch.Api.UserApi do
  @moduledoc false

  alias TwitchStory.Twitch.Api.AuthApi

  @fields ["id", "login", "display_name", "email", "profile_image_url", "created_at"]

  def user(token) do
    AuthApi.get(url: "/helix/users", token: token.access_token)
    |> case do
      {:ok, %Req.Response{status: 200, body: %{"data" => [user | _]}}} ->
        user
        |> Map.take(@fields)
        |> string_to_atom_keys()
        |> then(fn user -> {:ok, user} end)

      _ ->
        {:error, :invalid_request}
    end
  end

  @fields ["color"]

  def color(token) do
    AuthApi.get(url: "/helix/chat/color?user_id=#{token.user_id}", token: token.access_token)
    |> case do
      {:ok, %Req.Response{status: 200, body: %{"data" => [color | _]}}} ->
        color
        |> Map.take(@fields)
        |> string_to_atom_keys()
        |> then(fn color -> {:ok, color} end)

      _ ->
        {:error, :not_found}
    end
  end

  @fields ["user_id", "user_login", "user_name"]

  def followed_channels(token) do
    AuthApi.get(
      url: "/helix/streams/followed?user_id=#{token.user_id}",
      token: token.access_token
    )
    |> case do
      {:ok, %Req.Response{status: 200, body: %{"data" => data}}} -> data
      _ -> []
    end
    |> Enum.map(&Map.take(&1, @fields))
    |> Enum.map(&string_to_atom_keys/1)
    |> then(fn channels -> {:ok, channels} end)
  end

  defp string_to_atom_keys(m) do
    for {k, v} <- m, into: %{}, do: {String.to_atom(k), v}
  end
end
