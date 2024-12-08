defmodule TwitchStoryWeb.TwitchLive.Histories.Overview do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  alias TwitchStory.Twitch.Histories.Commerce
  alias TwitchStory.Twitch.Histories.Community
  alias TwitchStory.Twitch.Histories.History
  alias TwitchStory.Twitch.Histories.SiteHistory
  alias TwitchStoryWeb.TwitchLive.Histories.Components

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, %{assigns: %{current_user: current_user}} = socket) do
    file = TwitchStory.file_storage().bucket(Path.join(current_user.id, id <> ".zip"))

    case History.get(history_id: id) do
      {:ok, history} ->
        socket
        |> assign(:id, id)
        |> assign(:file, file)
        |> assign(:history, history)
        |> assign_async([:hour_watched, :follows, :chat_messages, :subscriptions], fn ->
          graphs = %{
            hour_watched:
              file
              |> SiteHistory.MinuteWatched.read()
              |> SiteHistory.MinuteWatched.group_month_year()
              |> SiteHistory.nominal_date_column(),
            follows:
              file
              |> Community.Follows.read()
              |> Community.Follows.group_month_year()
              |> SiteHistory.nominal_date_column(),
            chat_messages:
              file
              |> SiteHistory.ChatMessages.read()
              |> SiteHistory.ChatMessages.group_month_year()
              |> SiteHistory.nominal_date_column(),
            subscriptions:
              file
              |> Commerce.Subs.read()
              |> Commerce.Subs.group_month_year()
              |> SiteHistory.nominal_date_column()
          }

          {:ok, graphs}
        end)

      {:error, _} ->
        socket
        |> put_flash(:error, "Cannot find history")
        |> redirect(to: ~p"/history")
    end
    |> then(fn socket -> {:noreply, socket} end)
  end

  defp tab(js \\ %JS{}, tab, to) do
    js
    |> JS.remove_class("active-tab", to: "a.active-tab")
    |> JS.add_class("active-tab", to: tab)
    |> JS.hide(to: "div.tab-content")
    |> JS.show(to: to)
  end
end
