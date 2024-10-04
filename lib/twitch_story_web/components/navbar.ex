defmodule TwitchStoryWeb.Components.Navbar do
  @moduledoc false

  use TwitchStoryWeb, :component

  embed_templates "navbar/*"

  attr :icon, :string, required: true
  attr :title, :string, required: true
  attr :href, :string, required: true

  def row(assigns) do
    ~H"""
    <li>
      <a
        href={@href}
        class="text-gray-400 hover:text-white hover:bg-purple-800 group flex gap-x-3 rounded-md p-2 text-sm leading-6 font-semibold"
      >
        <.icon name={@icon} class="h-6 w-6 shrink-0" /> <%= @title %>
      </a>
    </li>
    """
  end

  attr :title, :string, required: true
  attr :rows, :list, default: []

  def section(assigns) do
    ~H"""
    <li>
      <div class="text-s font-semibold leading-6 text-gray-400"><%= @title %></div>
      <ul role="list" class="-mx-2 mt-2 space-y-1">
        <%= for {icon, title, href} <- @rows do %>
          <.row icon={icon} title={title} href={href} />
        <% end %>
      </ul>
    </li>
    """
  end

  attr :avatar, :string, required: true

  def footer(assigns) do
    ~H"""
    <li class="-mx-6 mt-auto">
      <.link
        href={~p"/users/log_out"}
        method="delete"
        class="flex items-center gap-x-4 px-6 py-3 text-sm font-semibold leading-6 text-white hover:bg-purple-800"
      >
        <img class="h-8 w-8 rounded-full bg-gray-800" src={@avatar} />
        <span aria-hidden="true">Log out</span>
        <.icon name="hero-arrow-right-on-rectangle" class="w-6 h-6 shrink-0" />
      </.link>
    </li>
    """
  end

  slot :inner_block, required: true

  def sidebar(assigns) do
    ~H"""
    <div class="flex grow flex-col gap-y-5 overflow-y-auto bg-gray-900 px-6 ring-1 ring-white/5">
      <div class="flex h-16 shrink-0 items-center"></div>
      <nav class="flex flex-1 flex-col">
        <ul role="list" class="flex flex-1 flex-col gap-y-7">
          <%= render_slot(@inner_block) %>
        </ul>
      </nav>
    </div>
    """
  end
end
