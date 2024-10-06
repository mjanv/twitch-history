defmodule TwitchStory.Twitch.Requests.Request do
  @moduledoc false

  use TwitchStory.Schema

  alias TwitchStory.Repo
  alias TwitchStory.Twitch.Requests.Metadata

  schema "twitch_requests" do
    field :user_id, :string
    field :username, :string
    field :request_id, :string

    field :start_time, :utc_datetime
    field :end_time, :utc_datetime

    field :stats, :map

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(request, attrs) do
    request
    |> cast(attrs, [:user_id, :request_id, :username, :start_time, :end_time, :stats])
    |> validate_required([:user_id, :request_id, :username, :start_time, :end_time])
  end

  def create(%Metadata{} = metadata) do
    %__MODULE__{}
    |> changeset(Map.from_struct(metadata))
    |> Repo.insert(on_conflict: :nothing)
  end

  def update(request, attrs) do
    request
    |> changeset(Enum.into(attrs, %{}))
    |> Repo.update()
  end

  def delete(request_id) do
    query = from r in __MODULE__, where: r.request_id == ^request_id

    Repo.delete_all(query)
    |> case do
      {1, nil} -> :ok
      _ -> :error
    end
  end

  def get(clauses) do
    __MODULE__
    |> Repo.get_by(clauses)
    |> case do
      nil -> {:error, :not_found}
      request -> {:ok, request}
    end
  end

  def all(user_id) do
    query =
      from r in __MODULE__,
        where: r.user_id == ^user_id,
        select: r

    query
    |> Repo.all()
    |> then(fn requests -> {:ok, requests} end)
  end
end
