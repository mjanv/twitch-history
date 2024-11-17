defmodule TwitchStory.Accounts.Services.FeatureFlags do
  @moduledoc false

  require Logger

  alias TwitchStory.Accounts.User
  alias TwitchStory.FeatureFlag

  @doc "Activate a feature flag for a user"
  @spec enable(String.t(), atom()) :: :ok | :error
  def enable(email, feature) do
    with {:ok, user} <- User.get_user_by_email(email),
         :ok <- FeatureFlag.enable(feature, user) do
      :ok
    else
      {:error, reason} ->
        Logger.error("Cannot activate feature #{feature} for user #{email}: #{inspect(reason)}")
        :error

      :error ->
        Logger.error("Cannot activate feature #{feature} for user #{email}: feature not found")
        :error
    end
  end

  @doc "Deactivate a feature flag for a user"
  @spec disable(String.t(), atom()) :: :ok | :error
  def disable(email, feature) do
    with {:ok, user} <- User.get_user_by_email(email),
         :ok <- FeatureFlag.disable(feature, user) do
      :ok
    else
      {:error, reason} ->
        Logger.error("Cannot deactivate feature #{feature} for user #{email}: #{inspect(reason)}")
        :error

      :error ->
        Logger.error("Cannot deactivate feature #{feature} for user #{email}: feature not found")
        :error
    end
  end
end
