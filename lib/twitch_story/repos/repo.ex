defmodule TwitchStory.Repo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :twitch_story,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 10

  def count(queryable), do: aggregate(queryable, :count)
end
