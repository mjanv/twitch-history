defmodule TwitchStory.FeatureFlag do
  @moduledoc false

  @type flag() :: atom()
  @type user() :: TwitchStory.Accounts.User.t()

  @doc "Enable a feature flag globally"
  @spec enable(flag()) :: :ok | :error
  def enable(feature) do
    feature
    |> FunWithFlags.enable()
    |> case do
      {:ok, true} -> :ok
      {:error, _} -> :error
    end
  end

  @doc "Enable a feature flag for a specific user"
  @spec enable(flag(), user()) :: :ok | :error
  def enable(feature, user) do
    feature
    |> FunWithFlags.enable(for_actor: user)
    |> case do
      {:ok, true} -> :ok
      {:error, _} -> :error
    end
  end

  @doc "Disable a feature flag"
  @spec disable(flag()) :: :ok | :error
  def disable(feature) do
    feature
    |> FunWithFlags.disable()
    |> case do
      {:ok, false} -> :ok
      {:error, _} -> :error
    end
  end

  @doc "Disable a feature flag for a specific user"
  @spec disable(flag(), user()) :: :ok | :error
  def disable(feature, user) do
    feature
    |> FunWithFlags.disable(for_actor: user)
    |> case do
      {:ok, false} -> :ok
      {:error, _} -> :error
    end
  end

  @doc "Clear a feature flag"
  @spec clear(flag()) :: :ok | :error
  def clear(feature) do
    feature
    |> FunWithFlags.clear()
    |> case do
      :ok -> :ok
      {:error, _} -> :error
    end
  end

  @doc "Checks if a feature flag is enabled"
  @spec enabled?(flag()) :: boolean()
  def enabled?(feature), do: FunWithFlags.enabled?(feature)

  @doc "Checks if a feature flag is enabled for a specific user"
  @spec enabled?(flag(), user()) :: boolean()
  def enabled?(feature, user), do: FunWithFlags.enabled?(feature, for: user)

  @doc "Checks if a feature flag is disabled"
  @spec disabled?(flag()) :: boolean()
  def disabled?(feature), do: not enabled?(feature)

  @doc "Checks if a feature flag is disabled for a specific user"
  @spec disabled?(flag(), user()) :: boolean()
  def disabled?(feature, user), do: not enabled?(feature, user)
end
