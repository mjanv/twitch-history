defmodule TwitchStory.Accounts.User do
  @moduledoc false

  use TwitchStory.Schema

  alias TwitchStory.EventBus

  @type t() :: %__MODULE__{
          name: String.t(),
          email: String.t(),
          provider: String.t(),
          role: :admin | :streamer | :viewer,
          password: String.t(),
          hashed_password: String.t(),
          confirmed_at: NaiveDateTime.t(),
          twitch_id: String.t(),
          twitch_avatar: String.t(),
          confirmed_at: NaiveDateTime.t(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  @derive {Jason.Encoder, only: [:name, :email, :role, :twitch_id, :twitch_avatar]}
  schema "users" do
    field :name, :string
    field :email, :string
    field :provider, :string, default: "identity"
    field :role, Ecto.Enum, values: [:admin, :streamer, :viewer]

    # Identity provider
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :confirmed_at, :naive_datetime

    # Twitch provider
    field :twitch_id, :string
    field :twitch_avatar, :string
    has_one :twitch_token, TwitchStory.Twitch.Auth.OauthToken

    many_to_many :followed_channels, TwitchStory.Twitch.Channels.Channel,
      join_through: TwitchStory.Twitch.FollowedChannel

    timestamps(type: :utc_datetime)
  end

  defimpl FunWithFlags.Actor, for: __MODULE__ do
    def id(%{id: id}), do: "user:#{id}"
  end

  @doc "Count the number of users by role"
  def count_roles do
    Repo.all(from(u in __MODULE__, group_by: u.role, select: {u.role, count(u.id)}))
  end

  @doc "Get all users"
  def all, do: Repo.all(__MODULE__)

  @doc "Get a user"
  def get(id), do: Repo.get(__MODULE__, id)

  @doc "Get or register a user by email"
  def get_or_register_user(%{email: email, provider: "twitch"} = attrs) do
    email
    |> get_user_by_email()
    |> case do
      nil -> register_twitch_user(attrs)
      user -> {:ok, user}
    end
  end

  @doc "Gets a user by email."
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(__MODULE__, email: email)
  end

  @doc "Gets a user by email and password."
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(__MODULE__, email: email)
    if valid_password?(user, password), do: user
  end

  @doc "Gets a user by Twitch ID."
  def get_user_by_twitch_id(twitch_id) do
    Repo.get_by(__MODULE__, twitch_id: twitch_id)
  end

  @doc "Gets a single user."
  def get_user!(id), do: Repo.get!(__MODULE__, id)

  @doc "Registers a Twitch user."
  def register_twitch_user(attrs) do
    %__MODULE__{}
    |> registration_twitch_changeset(attrs)
    |> Repo.insert()
    |> EventBus.ok(fn user -> %UserCreated{id: user.id} end)
  end

  @doc "Registration Twitch changeset"
  def registration_twitch_changeset(user, attrs, _opts \\ []) do
    user
    |> cast(attrs, [:name, :email, :provider, :role, :twitch_id, :twitch_avatar])
    |> validate_required([:name, :email, :provider, :role, :twitch_id])
  end

  @doc "Assigns a role to an user."
  def assign_role(user, role) do
    user
    |> update_changeset(%{role: role})
    |> Repo.update()
    |> EventBus.ok(fn user -> %RoleAssigned{id: user.id, role: user.role} end)
  end

  def update_changeset(user, attrs) do
    user
    |> cast(attrs, [:role])
    |> validate_required([:role])
  end

  @doc "Registers a user."
  def register_user(attrs) do
    %__MODULE__{}
    |> registration_changeset(attrs)
    |> Repo.insert()
    |> EventBus.ok(fn user -> %UserCreated{id: user.id} end)
  end

  @doc "Deletes a user."
  def delete_user(user) do
    user
    |> Repo.delete()
    |> EventBus.ok(fn user -> %UserDeleted{id: user.id} end)
  end

  @doc "Returns an `%Ecto.Changeset{}` for tracking user changes."
  def change_user_registration(%__MODULE__{} = user, attrs \\ %{}) do
    registration_changeset(user, attrs, hash_password: false, validate_email: false)
  end

  @doc """
  A user changeset for registration.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.

    * `:validate_email` - Validates the uniqueness of the email, in case
      you don't want to validate the uniqueness of the email (like when
      using this changeset for validations on a LiveView form before
      submitting the form), this option can be set to `false`.
      Defaults to `true`.
  """
  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:name, :email, :password])
    |> validate_email(opts)
    |> validate_password(opts)
  end

  defp validate_email(changeset, opts) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> maybe_validate_unique_email(opts)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 12, max: 72)
    # |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    # |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    # |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/, message: "at least one digit or punctuation character")
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      |> validate_length(:password, max: 72, count: :bytes)
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  defp maybe_validate_unique_email(changeset, opts) do
    if Keyword.get(opts, :validate_email, true) do
      changeset
      |> unsafe_validate_unique(:email, TwitchStory.Repo)
      |> unique_constraint(:email)
    else
      changeset
    end
  end

  @doc """
  A user changeset for changing the email.

  It requires the email to change otherwise an error is added.
  """
  def email_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email])
    |> validate_email(opts)
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end

  @doc """
  A user changeset for changing the password.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(user) do
    NaiveDateTime.utc_now()
    |> NaiveDateTime.truncate(:second)
    |> then(fn now -> change(user, confirmed_at: now) end)
  end

  @doc """
  Verifies the password.

  If there is no user or the user doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%TwitchStory.Accounts.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  def validate_current_password(changeset, password) do
    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end
end
