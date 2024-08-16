defmodule TwitchStoryWeb.AuthController do
  @moduledoc false

  use TwitchStoryWeb, :controller

  plug Ueberauth

  alias TwitchStory.{Accounts, Twitch}

  def callback(%{assigns: %{ueberauth_auth: %Ueberauth.Auth{} = auth}} = conn, _params) do
    auth
    |> Twitch.Auth.Callback.user_attrs()
    |> Accounts.get_or_register_user()
    |> tap(fn
      {:ok, user} ->
        auth
        |> Twitch.Auth.Callback.oauth_token_attrs()
        |> Twitch.Auth.OauthToken.create(user)
      {:error, _} ->
        :ok
    end)
    |> case do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Successfully authenticated")
        |> put_session(:user_return_to, ~p"/account")
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
