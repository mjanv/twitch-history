defmodule TwitchStoryWeb.Components.Titles do
  @moduledoc false

  use Phoenix.Component

  attr :title, :string, required: true
  slot :inner_block

  def heading(assigns) do
    ~H"""
    <div class="md:flex md:items-center md:justify-between">
      <div class="min-w-0 flex-1">
        <h1 class="text-2xl font-bold leading-7 text-gray-900 sm:truncate sm:text-3xl sm:tracking-tight">
          <%= @title %>
        </h1>
      </div>
      <div class="mt-4 flex md:ml-4 md:mt-0">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  def section(assigns) do
    ~H"""
    <div class="relative mt-8">
      <div class="absolute inset-0 flex items-center" aria-hidden="true">
        <div class="w-full border-t border-gray-300"></div>
      </div>
      <div class="relative flex justify-start">
        <span class="bg-white pr-3 text-xl font-semibold leading-6 text-gray-900">
          <%= @title %>
        </span>
      </div>
    </div>
    """
  end
end
