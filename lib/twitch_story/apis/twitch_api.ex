defmodule TwitchStory.Apis.TwitchApi do
  @moduledoc false

  @api Application.compile_env(:twitch_story, :twitch_api)

  def token do
    Req.new(base_url: "https://id.twitch.tv")
    |> Req.Request.put_headers([{"Content-Type", "application/x-www-form-urlencoded"}])
    |> Req.post(
      url: "/oauth2/token",
      params: [
        client_id: @api[:client_id],
        client_secret: @api[:client_secret],
        grant_type: "client_credentials"
      ]
    )
    |> case do
      {:ok,
       %Req.Response{
         status: 200,
         body: %{"token_type" => "bearer", "access_token" => access_token}
       }} ->
        access_token

      _ ->
        nil
    end
  end

  def emotes(broadcaster_id) do
    Req.new(base_url: "https://api.twitch.tv")
    |> Req.Request.put_headers([
      {"Authorization", "Bearer #{token()}"},
      {"Client-Id", @api[:client_id]}
    ])
    |> Req.get(url: "/helix/chat/emotes?broadcaster_id=#{broadcaster_id}")
    |> case do
      {:ok, %Req.Response{status: 200, body: %{"data" => data}}} -> data
      _ -> []
    end

    # |> Enum.map(fn emote -> Map.take(emote, ["name"]) end)
  end

  def channel(broadcaster_id) do
    Req.new(base_url: "https://api.twitch.tv")
    |> Req.Request.put_headers([
      {"Authorization", "Bearer #{token()}"},
      {"Client-Id", @api[:client_id]}
    ])
    |> Req.get(url: "/helix/channels?broadcaster_id=#{broadcaster_id}")
    |> case do
      {:ok, %Req.Response{status: 200, body: %{"data" => data}}} -> data
      error -> error
    end
  end

  def user(broadcaster_id) do
    Req.new(base_url: "https://api.twitch.tv")
    |> Req.Request.put_headers([
      {"Authorization", "Bearer #{token()}"},
      {"Client-Id", @api[:client_id]}
    ])
    |> Req.get(url: "/helix/users?id=#{broadcaster_id}")
    |> case do
      {:ok, %Req.Response{status: 200, body: %{"data" => data}}} -> data
      error -> error
    end
  end

  """
  %{"emote_set_id" => "327382231", "emote_type" => "subscriptions", "format" => ["static", "animated"], "id" => "emotesv2_7800b6632ca846979bf47440bbb26a5d", "images" => %{"url_1x" => "https://static-cdn.jtvnw.net/emoticons/v2/emotesv2_7800b6632ca846979bf47440bbb26a5d/static/light/1.0", "url_2x" => "https://static-cdn.jtvnw.net/emoticons/v2/emotesv2_7800b6632ca846979bf47440bbb26a5d/static/light/2.0", "url_4x" => "https://static-cdn.jtvnw.net/emoticons/v2/emotesv2_7800b6632ca846979bf47440bbb26a5d/static/light/3.0"}, "name" => "flonflLenie", "scale" => ["1.0", "2.0", "3.0"], "theme_mode" => ["light", "dark"], "tier" => "1000"}
  %{"broadcaster_id" => "468884133", "broadcaster_language" => "fr", "broadcaster_login" => "flonflon", "broadcaster_name" => "Flonflon", "content_classification_labels" => [], "delay" => 0, "game_id" => "509658", "game_name" => "Just Chatting", "is_branded_content" => false, "tags" => ["Français", "musique", "playlist"], "title" => "LA PLAYLIST IDÉALE... DES ONE-HIT WONDERS (les artistes qui n'ont fait qu'un tube) 🎶 | !soutenir !instagram !holy"}
  %{"broadcaster_type" => "partner", "description" => "Just Chatting", "display_name" => "flonfl", "email" => "fol", "id" => "468884133", "login" => "flonfl", "offline_image_url" => "https://static-cdn.jtvnw.net/jtv_user_pictures/3e3e3e3e-3e3e-3e3e-3e3e-3e3e3e3e3e3e-channel_offline_image-1920x1080.png", "profile_image_url" => "https://static-cdn.jtvnw.net/jtv_user_pictures/3e3e3e3e-3e3e-3e3e-3e3e-3e3e3e3e3e3e-profile_image-300x300.png", "type" => "", "view_count" => 0}
  """
end
