defmodule TwitchStory.Twitch.Auth.OauthTokenTest do
  use TwitchStory.DataCase

  alias TwitchStory.Twitch.Auth.OauthToken

  describe "create/2" do
    test "valid" do
      user = user_fixture()

      attrs = %{
        access_token: "abc",
        refresh_token: "def",
        scopes: ["chat:read"],
        expires_at: DateTime.utc_now()
      }

      {:ok, %OauthToken{} = token} = OauthToken.create(attrs, user)

      assert token.user_id == user.id
      assert token.access_token == "abc"
      assert token.refresh_token == "def"
      assert token.scopes == ["chat:read"]
      assert DateTime.diff(DateTime.utc_now(), token.expires_at) < 1
    end

    test "already existing" do
      user = user_fixture()

      attrs = %{
        access_token: "abc",
        refresh_token: "def",
        scopes: ["chat:read"],
        expires_at: DateTime.utc_now()
      }

      {:ok, %OauthToken{}} = OauthToken.create(attrs, user)

      assert_raise Ecto.ConstraintError, fn -> OauthToken.create(attrs, user) end
    end
  end

  describe "update/2" do
    test "valid" do
      user = user_fixture()

      attrs = %{
        access_token: "abc",
        refresh_token: "def",
        scopes: ["chat:read"],
        expires_at: DateTime.utc_now()
      }

      {:ok, %OauthToken{}} = OauthToken.create(attrs, user)

      attrs = %{
        access_token: "ghi",
        refresh_token: "jkl",
        scopes: ["chat:write"],
        expires_at: DateTime.utc_now()
      }

      {:ok, %OauthToken{} = token} = OauthToken.update(attrs, user)

      assert OauthToken.count() == 1
      assert token.user_id == user.id
      assert token.access_token == "ghi"
      assert token.refresh_token == "jkl"
      assert token.scopes == ["chat:write"]
      assert DateTime.diff(DateTime.utc_now(), token.expires_at) < 1
    end
  end

  describe "create_or_update/1" do
    test "valid" do
      user = user_fixture()

      attrs = %{
        access_token: "abc",
        refresh_token: "def",
        scopes: ["chat:read"],
        expires_at: DateTime.utc_now()
      }

      {:ok, %OauthToken{}} = OauthToken.create_or_update(attrs, user)

      attrs = %{
        access_token: "abc2",
        refresh_token: "def2",
        scopes: ["chat:read", "user:write"],
        expires_at: DateTime.utc_now()
      }

      {:ok, %OauthToken{} = token} = OauthToken.create_or_update(attrs, user)

      assert OauthToken.count() == 1
      assert token.user_id == user.id
      assert token.access_token == "abc2"
      assert token.refresh_token == "def2"
      assert token.scopes == ["chat:read", "user:write"]
      assert DateTime.diff(DateTime.utc_now(), token.expires_at) < 1
    end
  end

  describe "get/1" do
    test "returns the token with given user" do
      user = user_fixture()

      attrs = %{
        access_token: "abc",
        refresh_token: "def",
        scopes: ["chat:read"],
        expires_at: DateTime.utc_now()
      }

      {:ok, %OauthToken{} = token} = OauthToken.create(attrs, user)
      {:ok, %OauthToken{} = new_token} = OauthToken.get(user)

      assert new_token.access_token == token.access_token
      assert new_token.refresh_token == token.refresh_token
      assert new_token.scopes == token.scopes
      assert new_token.expires_at == token.expires_at
    end
  end

  describe "expiring?/1" do
    test "returns the token with given user" do
      {:ok, %OauthToken{id: id1}} =
        OauthToken.create(
          %{
            access_token: "abc",
            refresh_token: "def",
            scopes: ["chat:read"],
            expires_at: DateTime.add(DateTime.utc_now(), 45, :second)
          },
          user_fixture()
        )

      {:ok, %OauthToken{}} =
        OauthToken.create(
          %{
            access_token: "ghi",
            refresh_token: "jkl",
            scopes: ["chat:read"],
            expires_at: DateTime.add(DateTime.utc_now(), 65, :second)
          },
          user_fixture()
        )

      [%{id: id}] = OauthToken.expiring?(60)

      assert id == id1
    end
  end
end
