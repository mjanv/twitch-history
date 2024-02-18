defmodule TwitchStory.Twitch.Api do
  @moduledoc false

  alias TwitchStory.Twitch

  defdelegate reverse_search(login), to: Twitch.Api.ChannelApi
  defdelegate emotes(broadcaster_id), to: Twitch.Api.ChannelApi
  defdelegate channel(broadcaster_id), to: Twitch.Api.ChannelApi
end
