defmodule TwitchStoryWeb.AdminLive.FeatureFlags do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  alias TwitchStory.FeatureFlag

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(feature_flags: FeatureFlag.status(TwitchStory.feature_flags()))
    |> then(fn socket -> {:ok, socket} end)
  end

  @impl true
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
    |> assign(feature_flags: FeatureFlag.status(TwitchStory.feature_flags()))
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
    |> assign(feature_flags: FeatureFlag.status(TwitchStory.feature_flags()))
    |> then(fn socket -> {:noreply, socket} end)
  end
end
