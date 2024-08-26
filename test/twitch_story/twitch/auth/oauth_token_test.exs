defmodule TwitchStory.Twitch.Auth.OauthTokenTest do
  @moduledoc false

  use TwitchStory.DataCase

  import TwitchStory.AccountsFixtures

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

      assert new_token == token
    end
  end

  describe "expiring?/1" do
    test "returns the token with given user" do
      user = user_fixture()

      {:ok, %OauthToken{id: id1}} =
        OauthToken.create(
          %{
            access_token: "abc",
            refresh_token: "def",
            scopes: ["chat:read"],
            expires_at: DateTime.add(DateTime.utc_now(), 45, :second)
          },
          user
        )

      {:ok, %OauthToken{}} =
        OauthToken.create(
          %{
            access_token: "ghi",
            refresh_token: "jkl",
            scopes: ["chat:read"],
            expires_at: DateTime.add(DateTime.utc_now(), 65, :second)
          },
          user
        )

      [%{id: id}] = OauthToken.expiring?(60)

      assert id == id1
    end
  end
end
