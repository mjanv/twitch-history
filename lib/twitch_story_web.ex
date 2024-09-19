defmodule TwitchStoryWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use TwitchStoryWeb, :controller
      use TwitchStoryWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  def router do
    quote do
      use Phoenix.Router, helpers: false

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: TwitchStoryWeb.Layouts]

      import Plug.Conn
      import TwitchStoryWeb.Gettext

      unquote(verified_routes())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView, layout: {TwitchStoryWeb.Layouts, :app}

      unquote(html_helpers())
    end
  end

  def component do
    quote do
      use Phoenix.Component

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  def html do
    quote do
      use Phoenix.Component

      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      import Phoenix.HTML
      import TwitchStoryWeb.Components.CoreComponents
      import TwitchStoryWeb.Components.Titles
      import TwitchStoryWeb.Components.Search
      import TwitchStoryWeb.Gettext

      alias Phoenix.LiveView.JS

      unquote(verified_routes())
      unquote(responses())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: TwitchStoryWeb.Endpoint,
        router: TwitchStoryWeb.Router,
        statics: TwitchStoryWeb.static_paths()
    end
  end

  def responses do
    quote do
      defp noreply(socket), do: {:noreply, socket}
      defp ok(socket), do: {:ok, socket}
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
