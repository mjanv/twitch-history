defmodule TwitchStory.Twitch.Api.UserApi do
  @moduledoc false

  use TwitchStory.Twitch.Api.Client

  alias TwitchStory.Twitch.Api.AuthApi

  @type user() :: %{
          required(:id) => String.t(),
          required(:login) => String.t(),
          required(:display_name) => String.t(),
          required(:email) => String.t(),
          required(:profile_image_url) => String.t(),
          required(:created_at) => DateTime.t()
        }

  @type color() :: %{
          required(:color) => String.t()
        }

  @type channel() :: %{
          required(:broadcaster_id) => String.t(),
          required(:broadcaster_login) => String.t(),
          required(:broadcaster_name) => String.t(),
          required(:followed_at) => DateTime.t()
        }

  @type stream() :: %{
          required(:id) => String.t(),
          required(:type) => String.t(),
          required(:started_at) => DateTime.t(),
          required(:title) => String.t(),
          required(:language) => String.t(),
          required(:tags) => [String.t()],
          required(:user_id) => String.t(),
          required(:user_name) => String.t(),
          required(:game_id) => String.t(),
          required(:game_name) => String.t(),
          required(:is_mature) => boolean(),
          required(:tag_ids) => [String.t()],
          required(:thumbnail_url) => String.t(),
          required(:user_login) => String.t(),
          required(:viewer_count) => non_neg_integer()
        }

  @doc """
  Returns the Twitch user rattached to the token
  """
  @spec user(token()) :: {:ok, any()} | {:error, :invalid_request}
  def user(token) do
    AuthApi.get(url: "/helix/users", token: token.access_token)
    |> case do
      {:ok, %Req.Response{status: 200, body: %{"data" => [user | _]}}} ->
        user
        |> Map.take(["id", "login", "display_name", "email", "profile_image_url", "created_at"])
        |> string_to_atom_keys()
        |> then(fn %{created_at: c} = u ->
          Map.put(u, :created_at, c |> DateTime.from_iso8601() |> elem(1))
        end)
        |> then(fn user -> {:ok, user} end)

      _ ->
        {:error, :invalid_request}
    end
  end

  @doc """
  Returns the channel color
  """
  @spec color(token()) :: result(color(), :not_found)
  def color(token) do
    AuthApi.get(
      url: "/helix/chat/color?user_id=#{token.user.twitch_id}",
      token: token.access_token
    )
    |> case do
      {:ok, %Req.Response{status: 200, body: %{"data" => [color | _]}}} ->
        color
        |> Map.take(["color"])
        |> string_to_atom_keys()
        |> then(fn color -> {:ok, color} end)

      _ ->
        {:error, :not_found}
    end
  end

  @doc """
  Returns the list of followed channels
  """
  @spec followed_channels(token(), cursor()) :: ok([channel()])
  def followed_channels(token, cursor \\ nil) do
    url =
      case cursor do
        nil -> "/helix/channels/followed?user_id=#{token.user.twitch_id}&first=100"
        cursor -> "/helix/channels/followed?user_id=#{token.user.twitch_id}&after=#{cursor}"
      end

    AuthApi.get(url: url, token: token.access_token)
    |> case do
      {:ok, %Req.Response{status: 200, body: %{"data" => data, "pagination" => pagination}}} ->
        {:ok, next} =
          case pagination do
            %{"cursor" => cursor} -> followed_channels(token, cursor)
            _ -> {:ok, []}
          end

        data
        |> Enum.map(&string_to_atom_keys/1)
        |> Enum.map(fn %{followed_at: f} = c ->
          Map.put(c, :followed_at, f |> DateTime.from_iso8601() |> elem(1))
        end)
        |> Kernel.++(next)

      _ ->
        []
    end
    |> then(fn channels -> {:ok, channels} end)
  end

  @doc """
  Returns the list of live streams
  """
  @spec live_streams(token()) :: ok([stream()])
  def live_streams(token) do
    AuthApi.get(
      url: "/helix/streams/followed?user_id=#{token.user.twitch_id}&first=100",
      token: token.access_token
    )
    |> case do
      {:ok, %Req.Response{status: 200, body: %{"data" => data}}} -> data
      _ -> []
    end
    |> Enum.map(&string_to_atom_keys/1)
    |> then(fn streams -> {:ok, streams} end)
  end
end
