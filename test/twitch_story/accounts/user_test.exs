defmodule TwitchStory.Accounts.UserTest do
  use TwitchStory.DataCase

  import TwitchStory.AccountsFixtures

  alias TwitchStory.Accounts.User

  describe "get_or_register_user/1" do
    test "returns an existing user when the user is already registered" do
      existing_user = user_fixture()

      assert {:ok, user} =
               User.get_or_register_user(%{
                 name: "name",
                 email: existing_user.email,
                 provider: "twitch",
                 twitch_id: "12345",
                 twitch_avatar: "avatar_url"
               })

      assert user.id == existing_user.id
    end

    test "creates a new user when the user is not registered" do
      assert is_nil(User.get_user_by_email("email@twitch.com"))

      {:ok, user} =
        User.get_or_register_user(%{
          name: "name",
          email: "email@twitch.com",
          provider: "twitch",
          role: :viewer,
          twitch_id: "12345",
          twitch_avatar: "avatar_url"
        })

      new_user = User.get_user_by_email("email@twitch.com")

      assert new_user.id == user.id
      assert new_user.role == :viewer
    end
  end

  describe "get_user_by_email/1" do
    test "does not return the user if the email does not exist" do
      refute User.get_user_by_email("unknown@example.com")
    end

    test "returns the user if the email exists" do
      %{id: id} = user = user_fixture()
      assert %User{id: ^id} = User.get_user_by_email(user.email)
    end
  end

  describe "get_user_by_email_and_password/2" do
    test "does not return the user if the email does not exist" do
      refute User.get_user_by_email_and_password("unknown@example.com", "hello world!")
    end

    test "does not return the user if the password is not valid" do
      user = user_fixture()
      refute User.get_user_by_email_and_password(user.email, "invalid")
    end

    test "returns the user if the email and password are valid" do
      %{id: id} = user = user_fixture()

      assert %User{id: ^id} =
               User.get_user_by_email_and_password(user.email, valid_user_password())
    end
  end

  describe "get_user!/1" do
    test "raises if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        User.get_user!("48ba4926-19d3-41ed-bedf-c217e9060f82")
      end
    end

    test "returns the user with the given id" do
      %{id: id} = user = user_fixture()
      assert %User{id: ^id} = User.get_user!(user.id)
    end
  end

  describe "register_user/1" do
    test "requires email and password to be set" do
      {:error, changeset} = User.register_user(%{})

      assert %{
               password: ["can't be blank"],
               email: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates email and password when given" do
      {:error, changeset} = User.register_user(%{email: "not valid", password: "not valid"})

      assert %{
               email: ["must have the @ sign and no spaces"],
               password: ["should be at least 12 character(s)"]
             } = errors_on(changeset)
    end

    test "validates maximum values for email and password for security" do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = User.register_user(%{email: too_long, password: too_long})
      assert "should be at most 160 character(s)" in errors_on(changeset).email
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates email uniqueness" do
      %{email: email} = user_fixture()
      {:error, changeset} = User.register_user(%{email: email, password: valid_user_password()})
      assert "has already been taken" in errors_on(changeset).email

      # Now try with the upper cased email too, to check that email case is ignored.
      {:error, changeset} = User.register_user(%{email: String.upcase(email)})
      assert "has already been taken" in errors_on(changeset).email
    end

    test "registers users with a hashed password" do
      email = unique_user_email()
      {:ok, user} = User.register_user(valid_user_attributes(email: email))
      assert user.email == email
      assert is_binary(user.hashed_password)
      assert is_nil(user.confirmed_at)
      assert is_nil(user.password)
    end

    test "dispatch a CreatedUser event in case of success" do
      {:ok, user} = User.register_user(valid_user_attributes(email: unique_user_email()))

      {:ok, events} = TwitchStory.EventStore.all(user.id)

      assert events == [%UserCreated{id: user.id}]
    end
  end

  describe "delete_user/1" do
    test "deletes the user" do
      user = user_fixture()

      {:ok, %User{}} = User.delete_user(user)
      {:ok, events} = TwitchStory.EventStore.all(user.id)

      assert_raise Ecto.NoResultsError, fn -> User.get_user!(user.id) end
      assert events == [%UserCreated{id: user.id}, %UserDeleted{id: user.id}]
    end
  end

  describe "assign_role/1" do
    test "assigns a role to an existing user" do
      before_user = user_fixture()

      {:ok, after_user} = User.assign_role(before_user, :admin)

      assert before_user.role == nil
      assert after_user.role == :admin
    end

    test "dispatch a RoleAssigned event in case of success" do
      {:ok, user} = User.assign_role(user_fixture(), :admin)

      {:ok, events} = TwitchStory.EventStore.all(user.id)

      assert %RoleAssigned{id: user.id, role: "admin"} in events
    end
  end

  describe "change_user_registration/2" do
    test "returns a changeset" do
      assert %Ecto.Changeset{} = changeset = User.change_user_registration(%User{})
      assert changeset.required == [:password, :email]
    end

    test "allows fields to be set" do
      email = unique_user_email()
      password = valid_user_password()

      changeset =
        User.change_user_registration(
          %User{},
          valid_user_attributes(email: email, password: password)
        )

      assert changeset.valid?
      assert get_change(changeset, :email) == email
      assert get_change(changeset, :password) == password
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "inspect/2 for the User module" do
    test "does not include password" do
      refute inspect(%User{password: "123456"}) =~ "password: \"123456\""
    end
  end
end
