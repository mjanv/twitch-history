defmodule TwitchStoryWeb.HomepageLive.SwiftUI do
  @moduledoc false

  use TwitchStoryNative, [:render_component, format: :swiftui]

  def render(assigns, _interface) do
    ~LVN"""
    <Text>Hello, LiveView Native!</Text>
    """
  end
end
