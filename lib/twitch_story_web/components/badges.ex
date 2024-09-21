defmodule TwitchStoryWeb.Components.Badges do
  @moduledoc false

  use Phoenix.Component

  alias TwitchStory.Games.Eurovision

  attr :code, :string, required: true
  attr :height, :integer, default: 6
  attr :text, :boolean, default: true

  def flag(%{code: nil} = assigns) do
    ~H"""
    """
  end

  def flag(%{text: true} = assigns) do
    assigns = assign(assigns, :country, Eurovision.get_country(assigns.code))

    ~H"""
    <img class={"h-#{@height} w-auto inline-flex"} src={@country.binary} /> <%= @country.name %>
    """
  end

  def flag(%{text: false} = assigns) do
    assigns = assign(assigns, :country, Eurovision.get_country(assigns.code))

    ~H"""
    <img class={"h-#{@height} w-auto inline-flex"} src={@country.binary} />
    """
  end

  attr :status, :string, required: true

  def status(%{status: :started} = assigns) do
    ~H"""
    <span class="inline-flex items-center rounded-md bg-green-50 px-2 py-1 text-xs font-medium text-green-700 ring-1 ring-inset ring-green-700/10">
      <%= @status %>
    </span>
    """
  end

  def status(%{status: status} = assigns) when status in [:paused, :cancelled] do
    ~H"""
    <span class="inline-flex items-center rounded-md bg-red-50 px-2 py-1 text-xs font-medium text-red-700 ring-1 ring-inset ring-red-700/10">
      <%= @status %>
    </span>
    """
  end

  def status(assigns) do
    ~H"""
    <span class="inline-flex items-center rounded-md bg-purple-50 px-2 py-1 text-xs font-medium text-purple-700 ring-1 ring-inset ring-purple-700/10">
      <%= @status %>
    </span>
    """
  end
end
