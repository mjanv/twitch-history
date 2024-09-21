defmodule TwitchStoryWeb.PageController do
  @moduledoc false

  use TwitchStoryWeb, :controller

  def home(conn, _params) do
    render(conn, :home, layout: false)
  end

  def about(conn, _params) do
    render(conn, :about, layout: false)
  end
end
