defmodule TwitchStoryWeb.PageController do
  @moduledoc false

  use TwitchStoryWeb, :controller

  def home(conn, _params) do
    render(conn, :home, layout: false)
  end
end
