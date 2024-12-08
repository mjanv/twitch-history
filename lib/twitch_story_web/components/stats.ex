defmodule TwitchStoryWeb.Components.Stats do
  @moduledoc false

  use Phoenix.Component

  attr :title, :string, required: true
  attr :value, :integer, required: true
  attr :unit, :string, default: ""

  def stat(assigns) do
    ~H"""
    <div class="bg-white border border-gray-200 py-6 px-4 sm:px-6 lg:px-8 sm:border-l">
      <p class="text-xl font-medium leading-6 text-white-100">{@title}</p>
      <p class="mt-2 flex items-baseline gap-x-2">
        <span class="text-6xl font-semibold tracking-tight text-gray-900">
          {@value}
        </span>
        <span class="text-sm text-gray-900">{@unit}</span>
      </p>
    </div>
    """
  end
end
