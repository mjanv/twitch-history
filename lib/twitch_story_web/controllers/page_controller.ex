defmodule TwitchStoryWeb.PageController do
  use TwitchStoryWeb, :controller

  def home(conn, _params) do
    render(conn, :home, layout: false)
  end
end
