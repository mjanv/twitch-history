defmodule TwitchStory.Twitch.Channels.Schedule do
  @moduledoc false

  use TwitchStory.Schema

  alias TwitchStory.Repo

  schema "schedules" do
    embeds_many :entries, Entry do
      field :entry_id, :string
      field :title, :string
      field :category, :string
      field :start_time, :utc_datetime
      field :end_time, :utc_datetime
      field :is_canceled, :boolean, default: false
      field :is_recurring, :boolean, default: false
    end

    timestamps()

    # belongs_to :channel, TwitchStory.Twitch.Channels.Channel
  end

  def changeset(schedule, attrs) do
    schedule
    |> cast(attrs, [:channel_id])
    |> cast_embed(:entries, with: &entry_changeset/2)
    |> validate_required([:entries])
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

  def save(channel, entries) do
    %__MODULE__{}
    |> changeset(%{channel_id: channel.id, entries: entries})
    |> Repo.insert()
  end
end
