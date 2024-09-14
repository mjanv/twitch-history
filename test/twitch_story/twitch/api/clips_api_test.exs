defmodule TwitchStory.Twitch.Api.ClipApiTest do
  use ExUnit.Case

  alias TwitchStory.Twitch.Api.ClipApi

  @moduletag :api

  test "channel_clips/1" do
    {:ok, clips} = ClipApi.channel_clips(468_884_133)

    for clip <- clips do
      assert Enum.sort(Map.keys(clip)) ==
               Enum.sort([
                 :id,
                 :video_id,
                 :title,
                 :url,
                 :duration,
                 :created_at,
                 :broadcaster_id,
                 :broadcaster_name,
                 :embed_url,
                 :thumbnail_url,
                 :view_count
               ])

      assert clip.created_at.__struct__ == DateTime
    end
  end
end
