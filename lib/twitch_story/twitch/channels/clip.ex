defmodule TwitchStory.Twitch.Channels.Clip do
  @moduledoc false

  use TwitchStory.Schema

  alias TwitchStory.Repo

  schema "clips" do
    field :twitch_id, :string
    field :video_id, :string
    field :title, :string
    field :created_at, :utc_datetime

    field :broadcaster_id, :string

    embeds_one :stats, Stats do
      field :duration, :float
      field :view_count, :integer
    end

    embeds_one :urls, Urls do
      field :url, :string
      field :embed_url, :string
      field :thumbnail_url, :string
    end

    timestamps()
  end

  def changeset(clip, attrs) do
    clip
    |> cast(attrs, [:twitch_id, :video_id, :title, :created_at, :broadcaster_id])
    |> validate_required([:twitch_id, :title, :created_at, :broadcaster_id])
    |> cast_embed(:stats, required: true, with: &stats_changeset/2)
    |> cast_embed(:urls, required: true, with: &urls_changeset/2)
  end

  def stats_changeset(stats, attrs \\ %{}) do
    stats
    |> cast(attrs, [:duration, :view_count])
    |> validate_required([:duration, :view_count])
  end

  def urls_changeset(urls, attrs \\ %{}) do
    urls
    |> cast(attrs, [:url, :embed_url, :thumbnail_url])
    |> validate_required([:url, :embed_url, :thumbnail_url])
  end

  def all, do: Repo.all(__MODULE__)

  def broadcaster(broadcaster_id, page \\ 1, page_size \\ 10) do
    __MODULE__
    |> where(broadcaster_id: ^broadcaster_id)
    |> order_by(desc: :created_at)
    |> Repo.paginate(page: page, page_size: page_size)
    |> Map.get(:entries)
  end

  def page(page, page_size \\ 10, order_by \\ [asc: :created_at]) do
    __MODULE__
    |> order_by(^order_by)
    |> Repo.paginate(page: page, page_size: page_size)
    |> Map.get(:entries)
  end

  def count, do: Repo.count(__MODULE__)

  def create(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert(
      conflict_target: [:twitch_id],
      on_conflict: {:replace, [:title, :created_at, :stats, :urls]}
    )
  end
end
