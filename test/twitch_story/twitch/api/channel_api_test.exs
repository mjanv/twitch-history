defmodule TwitchStory.Twitch.Api.ChannelApiTest do
  use ExUnit.Case

  alias TwitchStory.Twitch.Api.ChannelApi

  @moduletag :api

  test "reverse_search/1" do
    assert ChannelApi.reverse_search("flonflon") == {:ok, 468_884_133}
    assert ChannelApi.reverse_search("giregejrigjeorig") == {:error, :not_found}
  end

  test "emotes/1" do
    {:ok, emotes} = ChannelApi.emotes(468_884_133)

    assert length(emotes) == 39

    assert List.first(emotes) == %{
             "channel_id" => "468884133",
             "emote_set_id" => "300667317",
             "format" => ["static"],
             "id" => "emotesv2_99b8a71a7de54664a489953555c6a596",
             "name" => "flonflFCana",
             "scale" => ["1.0", "2.0", "3.0"],
             "theme_mode" => ["light", "dark"]
             # "images" => %{"url_1x" => "https://static-cdn.jtvnw.net/emoticons/v2/emotesv2_99b8a71a7de54664a489953555c6a596/static/light/1.0", "url_2x" => "https://static-cdn.jtvnw.net/emoticons/v2/emotesv2_99b8a71a7de54664a489953555c6a596/static/light/2.0", "url_4x" => "https://static-cdn.jtvnw.net/emoticons/v2/emotesv2_99b8a71a7de54664a489953555c6a596/static/light/3.0"},
           }
  end

  test "channel/1" do
    {:ok, channel} = ChannelApi.channel(468_884_133)

    assert channel == %{
             "broadcaster_id" => "468884133",
             "broadcaster_language" => "fr",
             "broadcaster_login" => "flonflon",
             "broadcaster_name" => "Flonflon",
             "description" =>
               "Une chaine qui parle de musique : des émissions d'actu musicale, des playlists thématiques collaboratives, des interviews, des react Star Academy...",
             "tags" => [
               "Français",
               "fr",
               "actualités",
               "musique",
               "react",
               "music",
               "culture",
               "newmusicfriday"
             ],
             "thumbnail_url" =>
               "https://static-cdn.jtvnw.net/jtv_user_pictures/27d0d345-fa19-4f06-ad53-94a955d85f54-profile_image-300x300.png"
           }
  end
end
