defmodule TwitchStoryWeb.Components.Search do
  @moduledoc false

  use Phoenix.Component

  def search_bar(assigns) do
    ~H"""
    <div class="flex flex-1 gap-x-4 self-stretch lg:gap-x-6">
      <form class="flex flex-1" phx-change="search" phx-debounce="300">
        <label for="search-field" class="sr-only">Search</label>
        <div class="relative w-full">
          <svg
            class="pointer-events-none absolute inset-y-0 left-0 h-full w-5 text-gray-500"
            viewBox="0 0 20 20"
            fill="currentColor"
            aria-hidden="true"
          >
            <path
              fill-rule="evenodd"
              d="M9 3.5a5.5 5.5 0 100 11 5.5 5.5 0 000-11zM2 9a7 7 0 1112.452 4.391l3.328 3.329a.75.75 0 11-1.06 1.06l-3.329-3.328A7 7 0 012 9z"
              clip-rule="evenodd"
            />
          </svg>
          <input
            id="search-field"
            class="block h-full w-full border-0 bg-transparent py-0 pl-8 pr-0 text-white focus:ring-0 sm:text-sm"
            placeholder="Search..."
            type="search"
            name="query"
          />
        </div>
      </form>
    </div>
    """
  end
end
