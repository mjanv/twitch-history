defmodule TwitchStory.Twitch.Api.BotApi do
  @moduledoc false

  use TwitchStory.Twitch.Api.Client

  require Logger

  alias TwitchStory.Twitch.Api.AuthApi

  def subscriptions do
    [url: "/helix/eventsub/subscriptions"]
    |> AuthApi.get()
    |> case do
      {:ok,
       %Req.Response{
         status: 200,
         body: %{
           "data" => subscriptions,
           "max_total_cost" => _max_total_cost,
           "total" => _total,
           "total_cost" => _total_cost
         }
       }} ->
        {:ok, subscriptions}

      _ ->
        {:error, []}
    end
  end

  def stream_online(broadcaster_id) do
    create("stream.online", "1", %{"broadcaster_user_id" => broadcaster_id})
  end

  def create(type, version \\ "1", condition \\ %{}) do
    body = %{
      "type" => type,
      "version" => version,
      "condition" => condition,
      "transport" => %{
        "method" => "webhook",
        "callback" => "https://localhost:443/events/webhooks",
        "secret" => "secretsecret"
      }
    }

    [url: "/helix/eventsub/subscriptions", body: Jason.encode!(body)]
    |> AuthApi.post()
    |> case do
      {:ok, %Req.Response{status: 202, body: %{"data" => data}}} ->
        {:ok, data}

      {:ok, %Req.Response{status: status, body: body}} ->
        Logger.error("Error creating subscription: #{inspect(status)} - #{inspect(body)}")
        {:error, []}
    end
  end

  def delete(id) do
    [url: "/helix/eventsub/subscriptions?id=#{id}"]
    |> AuthApi.delete()
    |> case do
      {:ok, %Req.Response{status: 204}} ->
        :ok

      {:ok, %Req.Response{status: status, body: body}} ->
        Logger.error("Error deleting subscription: #{inspect(status)} - #{inspect(body)}")
        :error
    end
  end
end
