defmodule TwitchStoryWeb.Components.Search do
  @moduledoc false

  use Phoenix.Component

  alias Phoenix.LiveView.JS

  def infinite_scroll(assigns) do
    ~H"""
    <div id="infinite-scroll-marker" phx-hook="InfiniteScroll" data-page={@page}></div>
    """
  end

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

  def toggle(assigns) do
    ~H"""
    <div class="flex items-center">
      <button
        type="button"
        id={@id}
        phx-click={enable_toggle("##{@id}")}
        class="bg-gray-200 relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-indigo-600 focus:ring-offset-2"
        role="switch"
      >
        <span class="translate-x-0 pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out">
        </span>
      </button>
      <span class="ml-3 text-sm font-medium text-gray-100"><%= @caption %></span>
    </div>
    """
  end

  def enable_toggle(js \\ %JS{}, id) do
    js
    |> JS.toggle_class("bg-gray-200", to: id)
    |> JS.toggle_class("bg-indigo-600", to: id)
    |> JS.toggle_class("translate-x-5", to: "#{id} > span")
    |> JS.toggle_class("translate-x-0", to: "#{id} > span")
  end

  def select(assigns) do
    ~H"""
    <div>
      <label id="listbox-label" class="block text-sm font-medium leading-6 text-gray-900">
        Assigned to
      </label>
      <div class="relative mt-2">
        <button
          type="button"
          class="relative w-full cursor-default rounded-md bg-white py-1.5 pl-3 pr-10 text-left text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 focus:outline-none focus:ring-2 focus:ring-indigo-600 sm:text-sm sm:leading-6"
          aria-haspopup="listbox"
          aria-expanded="true"
          aria-labelledby="listbox-label"
        >
          <span class="block truncate">Tom Cook</span>
          <span class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-2">
            <svg
              class="h-5 w-5 text-gray-400"
              viewBox="0 0 20 20"
              fill="currentColor"
              aria-hidden="true"
            >
              <path
                fill-rule="evenodd"
                d="M10 3a.75.75 0 01.55.24l3.25 3.5a.75.75 0 11-1.1 1.02L10 4.852 7.3 7.76a.75.75 0 01-1.1-1.02l3.25-3.5A.75.75 0 0110 3zm-3.76 9.2a.75.75 0 011.06.04l2.7 2.908 2.7-2.908a.75.75 0 111.1 1.02l-3.25 3.5a.75.75 0 01-1.1 0l-3.25-3.5a.75.75 0 01.04-1.06z"
                clip-rule="evenodd"
              />
            </svg>
          </span>
        </button>
        <!--
          Select popover, show/hide based on select state.

          Entering: ""
            From: ""
            To: ""
          Leaving: "transition ease-in duration-100"
            From: "opacity-100"
            To: "opacity-0"
        -->
        <ul
          class="absolute z-10 mt-1 max-h-60 w-full overflow-auto rounded-md bg-white py-1 text-base shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none sm:text-sm"
          tabindex="-1"
          role="listbox"
          aria-labelledby="listbox-label"
          aria-activedescendant="listbox-option-3"
        >
          <!--
            Select option, manage highlight styles based on mouseenter/mouseleave and keyboard navigation.

            Highlighted: "bg-indigo-600 text-white", Not Highlighted: "text-gray-900"
          -->
          <li
            class="text-gray-900 relative cursor-default select-none py-2 pl-8 pr-4"
            id="listbox-option-0"
            role="option"
          >
            <!-- Selected: "font-semibold", Not Selected: "font-normal" -->
            <span class="font-normal block truncate">Wade Cooper</span>
            <!--
              Checkmark, only display for selected option.

              Highlighted: "text-white", Not Highlighted: "text-indigo-600"
            -->
            <span class="text-indigo-600 absolute inset-y-0 left-0 flex items-center pl-1.5">
              <svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                <path
                  fill-rule="evenodd"
                  d="M16.704 4.153a.75.75 0 01.143 1.052l-8 10.5a.75.75 0 01-1.127.075l-4.5-4.5a.75.75 0 011.06-1.06l3.894 3.893 7.48-9.817a.75.75 0 011.05-.143z"
                  clip-rule="evenodd"
                />
              </svg>
            </span>
          </li>
          <!-- More items... -->
        </ul>
      </div>
    </div>
    """
  end
end
