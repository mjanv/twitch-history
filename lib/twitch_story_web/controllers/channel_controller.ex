defmodule TwitchStoryWeb.ChannelController do
  @moduledoc false

  use TwitchStoryWeb, :controller

  alias TwitchStory.Twitch.{Api, Channel}

  def index(conn, _params) do
    render(conn, :index, channels: Channel.list(), changeset: Channel.change(%Channel{}))
  end

  def create(conn, %{"channel" => %{"name" => name}}) do
    name
    |> Api.find_broadcaster_id()
    |> case do
      {:ok, broadcaster_id} -> Api.channel(broadcaster_id)
      {:error, :not_found} -> {:error, :not_found}
    end
    |> case do
      {:ok, channel} -> Channel.create(channel)
      {:error, :not_found} -> {:error, :not_found}
    end
    |> case do
      {:ok, _channel} -> conn |> put_flash(:info, "Channel created successfully.")
      {:error, :not_found} -> conn |> put_flash(:info, "Channel not found.")
    end
    |> redirect(to: ~p"/channels")
  end
end
