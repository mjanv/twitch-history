defmodule TwitchStoryWeb.Layouts do
  @moduledoc false

  use TwitchStoryWeb, :html

  embed_templates "layouts/*"

  def open_sidebar(js \\ %JS{}) do
    js
    |> JS.show(
      transition: {"ease-out duration-300", "opacity-0", "opacity-100"},
      to: "#close-button",
      display: "flex"
    )
    |> JS.show(
      transition:
        {"transition ease-in-out duration-300 transform", "-translate-x-full", "translate-x-0"},
      to: "#off-canvas-menu",
      display: "flex"
    )
    |> JS.show(
      transition: {"transition-opacity ease-linear duration-300", "opacity-0", "opacity-100"},
      to: "#off-canvas-menu-backdrop",
      display: "flex"
    )
  end

  def close_sidebar(js \\ %JS{}) do
    js
    |> JS.hide(
      transition: {"ease-out duration-300", "opacity-100", "opacity-0"},
      to: "#close-button"
    )
    |> JS.hide(
      transition:
        {"transition ease-in-out duration-300 transform", "translate-x-0", "-translate-x-full"},
      to: "#off-canvas-menu"
    )
    |> JS.hide(
      transition: {"transition-opacity ease-linear duration-300", "opacity-100", "opacity-0"},
      to: "#off-canvas-menu-backdrop"
    )
  end
end
