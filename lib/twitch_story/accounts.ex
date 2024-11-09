defmodule TwitchStory.Accounts do
  @moduledoc false

  alias TwitchStory.Accounts.{Identity, User}

  ## User
  defdelegate get_or_register_user(attrs), to: User
  defdelegate get_user_by_email(email), to: User
  defdelegate get_user_by_email_and_password(email, password), to: User
  defdelegate get_user!(id), to: User
  defdelegate register_user(attrs), to: User
  defdelegate change_user_registration(user, attrs \\ %{}), to: User

  ## Session
  defdelegate generate_user_session_token(user), to: TwitchStory.Accounts.UserToken
  defdelegate get_user_by_session_token(token), to: TwitchStory.Accounts.UserToken
  defdelegate delete_user_session_token(token), to: TwitchStory.Accounts.UserToken

  ## Settings
  defdelegate change_user_email(user, attrs \\ %{}), to: Identity.Settings
  defdelegate apply_user_email(user, password, attrs), to: Identity.Settings
  defdelegate update_user_email(user, token), to: Identity.Settings

  defdelegate deliver_user_update_email_instructions(user, email, update_email_url_fun),
    to: Identity.Settings

  defdelegate change_user_password(user, attrs \\ %{}), to: Identity.Settings
  defdelegate update_user_password(user, password, attrs), to: Identity.Settings

  ## Confirmation
  defdelegate deliver_user_confirmation_instructions(user, confirmation_url_fun),
    to: Identity.Confirmation

  defdelegate confirm_user(token), to: Identity.Confirmation

  ## Reset password
  defdelegate deliver_user_reset_password_instructions(user, reset_password_url_fun),
    to: Identity.ResetPassword

  defdelegate get_user_by_reset_password_token(token), to: Identity.ResetPassword
  defdelegate reset_user_password(user, attrs), to: Identity.ResetPassword
end
