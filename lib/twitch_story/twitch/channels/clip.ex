defmodule TwitchStory.Twitch.Channels.Clip do
  @moduledoc false

  use TwitchStory.Schema

  alias TwitchStory.Repo

  @type t() :: %__MODULE__{
          twitch_id: String.t(),
          video_id: String.t(),
          title: String.t(),
          created_at: NaiveDateTime.t(),
          broadcaster_id: String.t(),
          stats: map(),
          urls: map()
        }

  schema "clips" do
    field :twitch_id, :string
    field :video_id, :string
    field :title, :string
    field :created_at, :utc_datetime

    field :broadcaster_id, :string

    embeds_one :stats, Stats, primary_key: false do
      field :duration, :float
      field :view_count, :integer
    end

    embeds_one :urls, Urls, primary_key: false do
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

  @doc "Get a clip by its Twitch ID"
  @spec get(String.t()) :: t() | nil
  def get(twitch_id) do
    Repo.get_by(__MODULE__, twitch_id: twitch_id)
  end

  @doc "Get the list of clips of a broadcaster"
  @spec broadcaster(String.t(), integer(), integer(), Keyword.t()) :: [t()]
  def broadcaster(broadcaster_id, page \\ 1, page_size \\ 10, order_by \\ [desc: :created_at]) do
    __MODULE__
    |> where(broadcaster_id: ^broadcaster_id)
    |> order_by(^order_by)
    |> Repo.paginate(page: page, page_size: page_size)
    |> Map.get(:entries)
  end

  @doc "Get the list of clips of all broadcasters"
  @spec page(integer(), integer(), Keyword.t()) :: [t()]
  def page(page, page_size \\ 10, order_by \\ [desc: :created_at]) do
    __MODULE__
    |> order_by(^order_by)
    |> Repo.paginate(page: page, page_size: page_size)
    |> Map.get(:entries)
  end

  @doc "Count the number of clips"
  @spec count :: integer()
  def count, do: Repo.count(__MODULE__)

  @doc "Create a new clip or update an existing one"
  @spec create(map()) :: {:ok, t()} | {:error, Ecto.Changeset.t()}
  def create(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert(
      conflict_target: [:twitch_id],
      on_conflict: {:replace, [:title, :created_at, :stats, :urls]}
    )
  end
end
