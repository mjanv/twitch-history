defmodule TwitchStory.Repo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :twitch_story,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 10

  import Ecto.Query

  @doc "Count the number of elements returned by a query"
  @spec count(Ecto.Queryable.t()) :: integer()
  def count(queryable), do: aggregate(queryable, :count)

  @doc "Returns elements from the last N time intervals"
  @spec last(
          Ecto.Queryable.t(),
          atom(),
          integer(),
          :year | :month | :week | :day | :hour | :minute
        ) ::
          Ecto.Queryable.t()
  def last(queryable, field \\ :inserted_at, n \\ 1, interval \\ :hour) do
    where(
      queryable,
      [c],
      field(c, ^field) > datetime_add(^DateTime.utc_now(), ^(-n), ^Atom.to_string(interval))
    )
  end
end
