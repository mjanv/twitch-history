defmodule TwitchStory.Accounts.UserTokenTest do
  use TwitchStory.DataCase

  alias TwitchStory.Accounts.UserToken

  describe "generate_user_session_token/1" do
    setup do
      %{user: user_fixture()}
    end

    test "generates a token", %{user: user} do
      token = UserToken.generate_user_session_token(user)

      user_token = Repo.get_by(UserToken, token: token)

      assert user_token.context == "session"
      # Creating the same token for another user should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%UserToken{
          token: user_token.token,
          user_id: user_fixture().id,
          context: "session"
        })
      end
    end
  end

  describe "get_user_by_session_token/1" do
    setup do
      user = user_fixture()
      token = UserToken.generate_user_session_token(user)
      %{user: user, token: token}
    end

    test "returns user by token", %{user: user, token: token} do
      assert session_user = UserToken.get_user_by_session_token(token)
      assert session_user.id == user.id
    end

    test "does not return user for invalid token" do
      refute UserToken.get_user_by_session_token("oops")
    end

    test "does not return user for expired token", %{token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])

      refute UserToken.get_user_by_session_token(token)
    end
  end

  describe "delete_user_session_token/1" do
    test "deletes the token" do
      user = user_fixture()

      token = UserToken.generate_user_session_token(user)

      assert UserToken.delete_user_session_token(token) == :ok
      refute UserToken.get_user_by_session_token(token)
    end
  end
end
