defmodule TwitchStory.Twitch.Requests.Channels do
  @moduledoc false

  alias TwitchStory.Twitch.Requests.Community
  alias TwitchStory.Twitch.Requests.SiteHistory

  def channels(file) do
    a =
      file
      |> SiteHistory.MinuteWatched.read()
      |> SiteHistory.MinuteWatched.group_channel()

    b =
      file
      |> SiteHistory.ChatMessages.read()
      |> SiteHistory.ChatMessages.group_channel()

    c =
      file
      |> Community.Follows.read()
      |> Community.Follows.all()

    a
    |> Explorer.DataFrame.join(b, how: :left, on: [:channel])
    |> Explorer.DataFrame.join(c, how: :left, on: [:channel])
  end
end
