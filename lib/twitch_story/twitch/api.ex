defmodule TwitchStory.Twitch.Api do
  @moduledoc false

  alias TwitchStory.Twitch

  defdelegate reverse_search(login), to: Twitch.Api.ChannelApi
  defdelegate channel(broadcaster_id), to: Twitch.Api.ChannelApi
  defdelegate schedule(broadcaster_id), to: Twitch.Api.ChannelApi
  defdelegate clips(broadcaster_id, shift_opts \\ [day: -7]), to: Twitch.Api.ChannelApi
end
