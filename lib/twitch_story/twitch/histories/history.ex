defmodule TwitchStory.Twitch.Histories.History do
  @moduledoc false

  use TwitchStory.Schema

  alias TwitchStory.Repo
  alias TwitchStory.Twitch.Histories.Metadata
  alias TwitchStory.Twitch.Histories.Summary

  @type t() :: %{
          user_id: String.t(),
          username: String.t(),
          history_id: String.t(),
          start_time: NaiveDateTime.t(),
          end_time: NaiveDateTime.t(),
          summary: Summary.t(),
          created_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  schema "twitch_histories_history" do
    field :user_id, :string
    field :username, :string
    field :history_id, :string

    field :start_time, :utc_datetime
    field :end_time, :utc_datetime

    embeds_one :summary, Summary

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(history, attrs) do
    history
    |> cast(attrs, [:user_id, :history_id, :username, :start_time, :end_time])
    |> validate_required([:user_id, :history_id, :username, :start_time, :end_time])
    |> cast_embed(:summary, required: false)
  end

  def create(%Metadata{} = metadata) do
    %__MODULE__{}
    |> changeset(Map.from_struct(metadata))
    |> Repo.insert(on_conflict: :nothing)
  end

  def update(history, attrs) do
    history
    |> changeset(Enum.into(attrs, %{}))
    |> Repo.update()
  end

  def delete(history_id) do
    query = from r in __MODULE__, where: r.history_id == ^history_id

    query
    |> Repo.delete_all()
    |> case do
      {1, nil} -> :ok
      _ -> :error
    end
  end

  @spec get(Keyword.t()) :: {:ok, t()} | {:error, atom()}
  def get(clauses) do
    __MODULE__
    |> Repo.get_by(clauses)
    |> case do
      nil -> {:error, :not_found}
      history -> {:ok, history}
    end
  end

  def all(user_id) do
    query =
      from r in __MODULE__,
        where: r.user_id == ^user_id,
        select: r

    query
    |> Repo.all()
  end
end
