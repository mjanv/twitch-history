defmodule TwitchStoryWeb.AuthController do
  @moduledoc false

  use TwitchStoryWeb, :controller

  plug Ueberauth

  # def callback(
  #       %{assigns: %{
  #         ueberauth_auth: auth,
  #         ueberauth_failure: %Ueberauth.Failure{errors: [error | _]}}} = conn,
  #       _params
  #     ) do
  #   conn
  #   |> put_flash(:error, error.message)
  #   |> redirect(to: "/")
  # end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    %{email: auth.info.email, password: auth.credentials.token}
    |> TwitchStory.Accounts.find_or_register()
    |> case do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Successfully authenticated.")
        |> put_session(:current_user, user)
        |> configure_session(renew: true)

      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
    end
    |> redirect(to: "/")
  end
end
