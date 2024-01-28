defmodule TwitchStory.Repo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :twitch_story,
    adapter: Ecto.Adapters.SQLite3
end
