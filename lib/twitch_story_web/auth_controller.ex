defmodule TwitchStoryWeb.AuthController do
  @moduledoc false

  use TwitchStoryWeb, :controller

  plug Ueberauth

  alias TwitchStory.Accounts
  alias TwitchStory.Accounts.Twitch

  def callback(%{assigns: %{ueberauth_auth: %Ueberauth.Auth{} = auth}} = conn, _params) do
    auth
    |> Twitch.OAuth.user_params()
    |> Accounts.get_or_register_user()
    |> case do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Successfully authenticated.")
        |> put_session(:current_user, user)
        |> configure_session(renew: true)

      {:error, %Ecto.Changeset{errors: [_ | _]}} ->
        conn
        |> put_flash(:error, "Error on changeset")
    end
    |> redirect(to: "/account")
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
