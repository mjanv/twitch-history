defmodule TwitchStory.Twitch.Channels.Schedule do
  @moduledoc false

  use TwitchStory.Schema

  alias TwitchStory.Repo

  schema "schedules" do
    embeds_many :entries, Entry, on_replace: :delete, primary_key: false do
      field :entry_id, :string
      field :title, :string
      field :category, :string
      field :start_time, :utc_datetime
      field :end_time, :utc_datetime
      field :is_canceled, :boolean, default: false
      field :is_recurring, :boolean, default: false
    end

    timestamps()

    belongs_to :channel, TwitchStory.Twitch.Channels.Channel
  end

  def changeset(schedule, attrs) do
    schedule
    |> cast(attrs, [:channel_id])
    |> cast_embed(:entries, with: &entry_changeset/2, required: false)
  end

  def entry_changeset(entry, attrs) do
    entry
    |> cast(attrs, [
      :entry_id,
      :title,
      :category,
      :start_time,
      :end_time,
      :is_canceled,
      :is_recurring
    ])
    |> validate_required([:entry_id, :title, :start_time, :end_time])
  end

  def count, do: Repo.aggregate(__MODULE__, :count, :id)

  def save(channel, entries) do
    case Repo.get_by(__MODULE__, channel_id: channel.id) do
      nil -> %__MODULE__{}
      schedule -> schedule
    end
    |> changeset(%{channel_id: channel.id, entries: entries})
    |> Repo.insert_or_update()
  end

  def get(channel_id) do
    __MODULE__
    |> where(channel_id: ^channel_id)
    |> Repo.one()
    |> Repo.preload(:channel)
  end

  def all(channel_ids, now \\ DateTime.utc_now()) do
    seven_days_later = DateTime.add(now, 7 * 24 * 60 * 60, :second)

    __MODULE__
    |> where([s], s.channel_id in ^channel_ids)
    |> select([s], %__MODULE__{
      id: s.id,
      channel_id: s.channel_id,
      entries:
        fragment(
          """
          (
            SELECT jsonb_agg(entry)
            FROM jsonb_array_elements(s0.entries) AS entry
            WHERE (entry->>'start_time')::timestamptz <= ?
          )
          """,
          ^seven_days_later
        ),
      inserted_at: s.inserted_at,
      updated_at: s.updated_at
    })
    |> order_by(asc: :inserted_at)
    |> Repo.all()
    |> Enum.map(fn schedule ->
      schedule
      |> Map.put(:inserted_at, DateTime.from_naive!(schedule.inserted_at, "Etc/UTC"))
      |> Map.put(:updated_at, DateTime.from_naive!(schedule.updated_at, "Etc/UTC"))
      |> Map.put(
        :entries,
        schedule.entries
        |> Jason.encode!()
        |> Jason.decode!(keys: :atoms)
        |> Enum.map(fn entry ->
          entry
          |> Map.put(:start_time, to_datetime(entry.start_time))
          |> Map.put(:end_time, to_datetime(entry.end_time))
          |> Map.delete(:id)
        end)
      )
    end)
  end

  defp to_datetime(datetime) do
    datetime
    |> DateTime.from_iso8601()
    |> elem(1)
  end
end
