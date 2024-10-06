defmodule TwitchStory.Twitch.Channels.Emote do
  @moduledoc false

  use TwitchStory.Schema

  schema "emotes" do
    field :emote_id, :string
    field :name, :string
    field :emote_set_id, :string
    field :formats, {:array, :string}
    field :scales, {:array, :string}
    field :themes, {:array, :string}
    field :tier, :integer
    field :thumbnail_url, :string

    belongs_to :channel, TwitchStory.Twitch.Channels.Channel, references: :broadcaster_id

    timestamps(type: :utc_datetime)
  end

  @attrs [
    :name,
    :channel_id,
    :emote_set_id,
    :formats,
    :scales,
    :themes,
    :tier,
    :thumbnail_url
  ]

  def changeset(emote, attrs) do
    emote
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
    |> assoc_constraint(:channel)
  end

  def list, do: Repo.all(__MODULE__)
  def count, do: Repo.count(__MODULE__)

  def get(clauses) do
    Repo.get_by(__MODULE__, clauses)
  end

  def create(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def update(%__MODULE__{} = emote, attrs) do
    emote
    |> changeset(attrs)
    |> Repo.update()
  end

  def delete(%__MODULE__{} = emote), do: Repo.delete(emote)

  def from_api(emote) do
    %{
      emote_id: emote.emote_id,
      name: emote.name,
      emote_set_id: emote.emote_set_id,
      formats: emote.format,
      scales: emote.scale,
      themes: emote.theme_mode,
      tier: String.to_integer(emote.tier),
      thumbnail_url:
        emote.template
        |> String.replace("{{id}}", emote.emote_id)
        |> String.replace("{{format}}", hd(emote.format))
        |> String.replace("{{theme_mode}}", hd(emote.theme_mode))
        |> String.replace("{{scale}}", hd(Enum.reverse(emote.scale))),
      channel_id: emote.channel_id
    }
  end
end
