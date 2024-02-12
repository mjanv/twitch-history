defmodule TwitchStory.Apis.TwitchApiTest do
  use ExUnit.Case

  alias TwitchStory.Apis.TwitchApi

  test "emotes/1" do
    assert TwitchApi.emotes(468_884_133) == [
             %{"name" => "flonflFCana"},
             %{"name" => "flonflMichal"},
             %{"name" => "flonflLenie"},
             %{"name" => "flonflMimolette"},
             %{"name" => "flonflBretsmeh"},
             %{"name" => "flonflAna"},
             %{"name" => "flonflBriquet"},
             %{"name" => "flonflPamal"},
             %{"name" => "flonflDance"},
             %{"name" => "flonflMaitreSimonin"},
             %{"name" => "flonflFCRaph"},
             %{"name" => "flonflMichaelshocked"},
             %{"name" => "flonflClapclap"},
             %{"name" => "flonflExcellent"},
             %{"name" => "flonflViolet"},
             %{"name" => "flonflMescacahuetes"},
             %{"name" => "flonflBretsyeah"},
             %{"name" => "flonflStarAc"},
             %{"name" => "flonflScream"},
             %{"name" => "flonflDutronc"},
             %{"name" => "flonflModered"},
             %{"name" => "flonflHeyoh"},
             %{"name" => "flonflSexophone"},
             %{"name" => "flonflTiburce"},
             %{"name" => "flonflBretsno"},
             %{"name" => "flonflLeq"},
             %{"name" => "flonflMercibigflo"},
             %{"name" => "flonflPopstars"},
             %{"name" => "flonflBlas"},
             %{"name" => "flonflGA"},
             %{"name" => "flonflYeah"},
             %{"name" => "flonflBeaufdefrance"},
             %{"name" => "flonflBZH"},
             %{"name" => "flonflNoel"},
             %{"name" => "flonflDroite"},
             %{"name" => "flonflNikos"},
             %{"name" => "flonflIncroyable"}
           ]
  end

  test "channel/1" do
    assert TwitchApi.channel(468_884_133) == %{
             "broadcaster_id" => "468884133",
             "broadcaster_name" => "flonfl",
             "broadcaster_language" => "fr",
             "game_id" => "509670",
             "game_name" => "Just Chatting",
             "title" => "Just Chatting",
             "is_mature" => false,
             "started_at" => "2021-07-01T18:00:00Z",
             "thumbnail_url" =>
               "https://static-cdn.jtvnw.net/previews-ttv/live_user_flonfl-{width}x{height}.jpg",
             "tag_ids" => ["6ea6bca4-4712-4ab9-a906-e3336a9d8039"],
             "is_tag_rouge" => true
           }
  end

  test "user/1" do
    assert TwitchApi.user(468_884_133) == %{
             "id" => "468884133",
             "login" => "flonfl",
             "display_name" => "flonfl",
             "type" => "",
             "broadcaster_type" => "partner",
             "description" => "Just Chatting",
             "profile_image_url" =>
               "https://static-cdn.jtvnw.net/jtv_user_pictures/3e3e3e3e-3e3e-3e3e-3e3e-3e3e3e3e3e3e-profile_image-300x300.png",
             "offline_image_url" =>
               "https://static-cdn.jtvnw.net/jtv_user_pictures/3e3e3e3e-3e3e-3e3e-3e3e-3e3e3e3e3e3e-channel_offline_image-1920x1080.png",
             "view_count" => 0,
             "email" => "fol"
           }
  end
end
