defmodule TwitchStoryWeb.ImageController do
  @moduledoc false

  use TwitchStoryWeb, :controller

  alias TwitchStory.Games.Eurovision

  def eurovision(conn, %{"code" => code}) do
    conn
    |> put_resp_content_type("image/png")
    |> send_resp(200, Eurovision.get_country(code: code).binary)
  end
end
