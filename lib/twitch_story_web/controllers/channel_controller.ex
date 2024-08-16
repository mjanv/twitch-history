defmodule TwitchStoryWeb.ChannelController do
  @moduledoc false

  use TwitchStoryWeb, :controller

  alias TwitchStory.Twitch

  def index(conn, _params) do
    render(conn, :index,
      channels: Twitch.channels(),
      changeset: Twitch.channel_changeset()
    )
  end

  def create(conn, %{"channel" => %{"name" => name}}) do
    name
    |> Twitch.create_channel()
    |> case do
      {:ok, _channel} -> put_flash(conn, :info, "Channel created successfully.")
      {:error, :not_found} -> put_flash(conn, :info, "Channel not found.")
    end
    |> redirect(to: ~p"/channels")
  end
end
