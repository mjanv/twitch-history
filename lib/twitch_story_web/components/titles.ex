defmodule TwitchStoryWeb.Components.Titles do
  @moduledoc false

  use Phoenix.Component

  import TwitchStoryWeb.Components.CoreComponents

  attr :title, :string, required: true
  slot :inner_block

  def heading(assigns) do
    ~H"""
    <div class="mb-2 md:flex md:items-center md:justify-between">
      <div class="min-w-0 flex-1">
        <h1 class="text-2xl font-bold leading-7 text-gray-900 sm:truncate sm:text-3xl sm:tracking-tight">
          {@title}
        </h1>
      </div>
      <div class="mt-4 flex md:ml-4 md:mt-0">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  attr :title, :string, required: true

  def section(assigns) do
    ~H"""
    <div class="relative mt-12 mb-2">
      <div class="absolute inset-0 flex items-center" aria-hidden="true">
        <div class="w-full border-t border-gray-300 shadow-[2px_2px_0_0] shadow-purple-500/30 transform hover:shadow-[8px_8px_0_0] hover:shadow-purple-600/50 transition-shadow duration-300">
        </div>
      </div>
      <div class="relative flex justify-start">
        <span class="bg-white pr-3 text-xl font-semibold leading-6 text-gray-900">
          {@title}
        </span>
      </div>
    </div>
    """
  end

  attr :title, :string, required: true
  attr :description, :string, required: false, default: ""
  attr :icon, :string, required: false

  def empty(assigns) do
    ~H"""
    <div class="flex flex-col items-center justify-center h-full p-8 mt-4 text-center border border-gray-300 rounded-lg">
      <.icon name={@icon} class="w-16 h-16 text-gray-400 mb-2 size-6" />
      <h3 class="text-lg font-semibold text-gray-600">{@title}</h3>
      <%= if @description do %>
        <p class="text-gray-500 mt-2">{@description}</p>
      <% end %>
    </div>
    """
  end

  attr :rows, :list, default: []

  def stats(assigns) do
    ~H"""
    <div>
      <dl class="mt-5 mb-6 grid grid-cols-1 gap-5 sm:grid-cols-7">
        <%= for {title, value} <- @rows do %>
          <div class="overflow-hidden rounded-lg bg-white px-4 pt-3 pb-5 border border-gray-700/20 shadow-[4px_4px_0_0] shadow-purple-500/30 transform hover:shadow-[8px_8px_0_0] hover:shadow-purple-600/50 transition-shadow duration-300">
            <dt class="truncate text-l font-semibold text-gray-800">{title}</dt>
            <dd class="mt-1 text-3xl font-semibold tracking-tight text-gray-900">
              {value}
            </dd>
          </div>
        <% end %>
      </dl>
    </div>
    """
  end
end
