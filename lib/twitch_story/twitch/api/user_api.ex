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

  def color(token, id) do
    AuthApi.get(url: "/helix/chat/color?user_id=#{id}", token: token.access_token)
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

  @doc """
   %{
       id: "41004855461",
       type: "live",
       started_at: "2024-08-27T09:22:20Z",
       title: "c'est reparti pour du gamedev Unity Multiplayer",
       language: "fr",
       tags: ["chill", "radio", "maman", "Français", "Unity", "IndieGameDev",
        "Angers"],
       user_id: "462818643",
       user_name: "Aqueuse",
       game_id: "1469308723",
       game_name: "Software and Game Development",
       is_mature: false,
       tag_ids: [],
       thumbnail_url: "https://static-cdn.jtvnw.net/previews-ttv/live_user_aqueuse-{width}x{height}.jpg",
       user_login: "aqueuse",
       viewer_count: 30
     }
  """

  def live_streams(token, id) do
    AuthApi.get(
      url: "/helix/streams/followed?user_id=#{id}&first=100",
      token: token.access_token
    )
    |> case do
      {:ok, %Req.Response{status: 200, body: %{"data" => data}}} -> data
      _ -> []
    end
    |> Enum.map(&string_to_atom_keys/1)
    |> then(fn streams -> {:ok, streams} end)
  end

  @doc """
  %{
    "broadcaster_id" => "49632767",
    "broadcaster_login" => "blitzstream",
    "broadcaster_name" => "BlitzStream",
    "followed_at" => "2020-04-13T20:13:50Z"
  }
  """
  def followed_channels(token, id, cursor \\ nil) do
    url =
      case cursor do
        nil -> "/helix/channels/followed?user_id=#{id}&first=100"
        cursor -> "/helix/channels/followed?user_id=#{id}&after=#{cursor}"
      end

    AuthApi.get(url: url, token: token.access_token)
    |> case do
      {:ok, %Req.Response{status: 200, body: %{"data" => data, "pagination" => pagination}}} ->
        {:ok, next} =
          case pagination do
            %{"cursor" => cursor} -> followed_channels(token, id, cursor)
            _ -> {:ok, []}
          end

        Enum.map(data, &string_to_atom_keys/1) ++ next

      _ ->
        []
    end
    |> then(fn streams -> {:ok, streams} end)
  end

  defp string_to_atom_keys(m) do
    for {k, v} <- m, into: %{}, do: {String.to_atom(k), v}
  end
end
