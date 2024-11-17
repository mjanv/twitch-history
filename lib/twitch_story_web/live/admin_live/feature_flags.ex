defmodule TwitchStoryWeb.AdminLive.FeatureFlags do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  alias TwitchStory.Accounts.User
  alias TwitchStory.FeatureFlag

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(feature_flags: FeatureFlag.status())
    |> then(fn socket -> {:ok, socket} end)
  end

  @impl true
  def handle_params(params, _url, %{assigns: assigns} = socket) do
    assigns.live_action
    |> case do
      :index ->
        socket
        |> assign(feature_flags: FeatureFlag.status())

      :users ->
        feature_flag =
          assigns[:feature_flags]
          |> Enum.find([], fn flag -> flag.name == String.to_atom(params["name"]) end)

        socket
        |> assign(feature_flag: feature_flag)
    end
    |> then(fn socket -> {:noreply, socket} end)
  end

  @impl true
  def handle_event("default", _params, socket) do
    for flag <- TwitchStory.feature_flags() do
      FeatureFlag.enable(flag)
    end

    socket
    |> put_flash(:info, "Feature flags enabled")
    |> assign(feature_flags: FeatureFlag.status())
    |> then(fn socket -> {:noreply, socket} end)
  end

  def handle_event("enable", %{"feature" => feature}, socket) do
    feature
    |> String.to_atom()
    |> FeatureFlag.enable()
    |> case do
      :ok ->
        socket
        |> put_flash(:info, "Feature #{feature} enabled")

      :error ->
        socket
        |> put_flash(:error, "Cannot enable feature #{feature}")
    end
    |> assign(feature_flags: FeatureFlag.status())
    |> then(fn socket -> {:noreply, socket} end)
  end

  def handle_event("disable", %{"feature" => feature}, socket) do
    feature
    |> String.to_atom()
    |> FeatureFlag.disable()
    |> case do
      :ok ->
        socket
        |> put_flash(:info, "Feature #{feature} disabled")

      :error ->
        socket
        |> put_flash(:error, "Cannot disable feature #{feature}")
    end
    |> assign(feature_flags: FeatureFlag.status())
    |> then(fn socket -> {:noreply, socket} end)
  end

  def handle_event("clear", %{"feature" => feature}, socket) do
    feature
    |> String.to_atom()
    |> FeatureFlag.clear()
    |> case do
      :ok ->
        socket
        |> put_flash(:info, "Feature #{feature} cleared")

      :error ->
        socket
        |> put_flash(:error, "Cannot clear feature #{feature}")
    end
    |> assign(feature_flags: FeatureFlag.status())
    |> then(fn socket -> {:noreply, socket} end)
  end

  def handle_event("enable_user", %{"user" => user, "feature" => feature}, socket) do
    feature
    |> String.to_atom()
    |> FeatureFlag.enable(User.get_user!(user))
    |> case do
      :ok ->
        socket
        |> put_flash(:info, "User #{user} enabled for feature #{feature}")

      :error ->
        socket
        |> put_flash(:error, "Cannot enable user #{user} for feature #{feature}")
    end
    |> assign(feature_flags: FeatureFlag.status())
    |> then(fn socket -> {:noreply, socket} end)
  end

  def handle_event("disable_user", %{"user" => user, "feature" => feature}, socket) do
    feature
    |> String.to_atom()
    |> FeatureFlag.disable(User.get_user!(user))
    |> case do
      :ok ->
        socket
        |> put_flash(:info, "User #{user} disabled for feature #{feature}")

      :error ->
        socket
        |> put_flash(:error, "Cannot disable user #{user} for feature #{feature}")
    end
    |> assign(feature_flags: FeatureFlag.status())
    |> then(fn socket -> {:noreply, socket} end)
  end
end
