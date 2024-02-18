defmodule TwitchStory.Accounts.UserToken do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Query

  alias TwitchStory.Repo

  @hash_algorithm :sha256
  @rand_size 32

  @reset_password_validity_in_days 1
  @confirm_validity_in_days 7
  @change_email_validity_in_days 7
  @session_validity_in_days 60

  schema "users_tokens" do
    field :token, :binary
    field :context, :string
    field :sent_to, :string
    belongs_to :user, TwitchStory.Accounts.User

    timestamps(updated_at: false)
  end

  @doc "Generates a session token."
  def generate_user_session_token(%{id: id}) do
    token = :crypto.strong_rand_bytes(@rand_size)
    Repo.insert!(%__MODULE__{token: token, context: "session", user_id: id})
    token
  end

  @doc "Gets the user with the given signed token."
  def get_user_by_session_token(token) do
    query =
      from token in by_token_and_context_query(token, "session"),
        join: user in assoc(token, :user),
        where: token.inserted_at > ago(@session_validity_in_days, "day"),
        select: user

    Repo.one(query)
  end

  @doc "Deletes the signed token with the given context."
  def delete_user_session_token(token) do
    Repo.delete_all(by_token_and_context_query(token, "session"))
    :ok
  end

  @doc "Builds a token and its hash to be delivered to the user's email."
  def build_email_token(%{id: id, email: email}, context) do
    token = :crypto.strong_rand_bytes(@rand_size)

    Repo.insert!(%__MODULE__{
      token: :crypto.hash(@hash_algorithm, token),
      context: context,
      sent_to: email,
      user_id: id
    })

    {:ok, Base.url_encode64(token, padding: false)}
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The given token is valid if it matches its hashed counterpart in the database, the user email has not changed and is used within a certain time period.
  """
  def verify_email_token_query(token, context) do
    token
    |> Base.url_decode64(padding: false)
    |> case do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)
        days = days_for_context(context)

        query =
          from token in by_token_and_context_query(hashed_token, context),
            join: user in assoc(token, :user),
            where: token.inserted_at > ago(^days, "day") and token.sent_to == user.email,
            select: user

        Repo.one(query)

      :error ->
        nil
    end
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The given token is valid if it matches its hashed counterpart in the database and has not changed and is used within a certain time period. The context must be prefixed with "change:".
  """
  def verify_change_email_token_query(token, "change:" <> _ = context) do
    token
    |> Base.url_decode64(padding: false)
    |> case do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)
        days = days_for_context(context)

        query =
          from token in by_token_and_context_query(hashed_token, context),
            where: token.inserted_at > ago(^days, "day")

        Repo.one(query)

      :error ->
        nil
    end
  end

  defp days_for_context("change:" <> _), do: @change_email_validity_in_days
  defp days_for_context("confirm"), do: @confirm_validity_in_days
  defp days_for_context("reset_password"), do: @reset_password_validity_in_days

  @doc "Returns the token struct for the given token value and context."
  def by_token_and_context_query(token, context) do
    from __MODULE__, where: [token: ^token, context: ^context]
  end

  @doc "Gets all tokens for the given user for the given contexts."
  def by_user_and_contexts_query(user, :all) do
    from t in __MODULE__, where: t.user_id == ^user.id
  end

  def by_user_and_contexts_query(user, [_ | _] = contexts) do
    from t in __MODULE__, where: t.user_id == ^user.id and t.context in ^contexts
  end
end
