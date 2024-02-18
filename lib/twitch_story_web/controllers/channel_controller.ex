defmodule TwitchStoryWeb.ChannelController do
  @moduledoc false

  use TwitchStoryWeb, :controller

  alias TwitchStory.Twitch.{Api, Channels}

  def index(conn, _params) do
    render(conn, :index,
      channels: Channels.Channel.list(),
      changeset: Channels.Channel.change(%Channels.Channel{})
    )
  end

  def create(conn, %{"channel" => %{"name" => name}}) do
    name
    |> Api.reverse_search()
    |> case do
      {:ok, broadcaster_id} -> Api.channel(broadcaster_id)
      {:error, :not_found} -> {:error, :not_found}
    end
    |> case do
      {:ok, channel} -> Channels.Channel.create(channel)
      {:error, :not_found} -> {:error, :not_found}
    end
    |> case do
      {:ok, _channel} -> put_flash(conn, :info, "Channel created successfully.")
      {:error, :not_found} -> put_flash(conn, :info, "Channel not found.")
    end
    |> redirect(to: ~p"/channels")
  end
end
