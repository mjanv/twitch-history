defmodule TwitchStoryWeb.Layouts.SwiftUI do
  @moduledoc false

  use TwitchStoryNative, [:layout, format: :swiftui]

  embed_templates "layouts_swiftui/*"
end
