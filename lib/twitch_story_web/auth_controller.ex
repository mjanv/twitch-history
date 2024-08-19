defmodule TwitchStoryWeb.AuthController do
  @moduledoc false

  use TwitchStoryWeb, :controller

  plug Ueberauth

  alias TwitchStory.Accounts
  alias TwitchStory.Twitch.Auth

  def callback(%{assigns: %{ueberauth_auth: %Ueberauth.Auth{} = auth}} = conn, _params) do
    auth
    |> Auth.Callback.user_attrs()
    |> Accounts.get_or_register_user()
    |> tap(fn
      {:ok, user} ->
        auth
        |> Auth.Callback.oauth_token_attrs()
        |> Auth.OauthToken.create(user)

      {:error, _} ->
        :ok
    end)
    |> case do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Successfully authenticated")
        |> put_session(:user_return_to, ~p"/games/eurovision")
        |> TwitchStoryWeb.UserAuth.log_in_user(user, %{})

      {:error, %Ecto.Changeset{errors: [_ | _]}} ->
        conn
        |> put_flash(:error, "Error on changeset")
        |> redirect(to: ~p"/")
    end
  end

  def callback(
        %{
          assigns: %{
            ueberauth_failure: %Ueberauth.Failure{errors: [error | _]}
          }
        } = conn,
        _params
      ) do
    conn
    |> put_flash(:error, error.message)
    |> redirect(to: "/")
  end
end
