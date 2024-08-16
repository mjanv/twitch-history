defmodule TwitchStory.Twitch.Requests.RequestTest do
  use TwitchStory.DataCase

  alias TwitchStory.Twitch.Requests.{Metadata, Request}

  @zip ~c"priv/static/request-1.zip"

  setup do
    {:ok, %{metadata: Metadata.read(@zip)}}
  end

  describe "create/1" do
    test "valid metadata", %{metadata: metadata} do
      {:ok, request} = Request.create(metadata)

      assert %TwitchStory.Twitch.Requests.Request{
               user_id: "441903922",
               username: "lanfeust313",
               request_id: "MYCoARYOyQp7Kcwajqn3CmIo9PoFOQ8n",
               start_time: ~U[2019-06-14 22:01:14Z],
               end_time: ~U[2024-01-06 23:00:00Z]
             } = request
    end

    test "already exists", %{metadata: metadata} do
      {:ok, request_1} = Request.create(metadata)
      {:ok, request_2} = Request.create(metadata)

      assert Map.drop(request_1, [:id]) == Map.drop(request_2, [:id])
    end
  end

  describe "get/1" do
    test "with valid request_id", %{metadata: metadata} do
      {:ok, _} = Request.create(metadata)

      {:ok, request} = Request.get(request_id: metadata.request_id)

      assert %TwitchStory.Twitch.Requests.Request{
               user_id: "441903922",
               username: "lanfeust313",
               request_id: "MYCoARYOyQp7Kcwajqn3CmIo9PoFOQ8n",
               start_time: ~U[2019-06-14 22:01:14Z],
               end_time: ~U[2024-01-06 23:00:00Z]
             } = request
    end

    test "with invalid request_id" do
      {:error, :not_found} = Request.get(request_id: "invalid")
    end
  end

  describe "update/2" do
    test "with stats", %{metadata: metadata} do
      {:ok, request} = Request.create(metadata)

      stats = %{follows: 121, chat_messages: 435, hours_watched: 120, subscriptions: 5}

      {:ok, request} = Request.update(request, stats: stats)

      assert %TwitchStory.Twitch.Requests.Request{
               user_id: "441903922",
               username: "lanfeust313",
               request_id: "MYCoARYOyQp7Kcwajqn3CmIo9PoFOQ8n",
               start_time: ~U[2019-06-14 22:01:14Z],
               end_time: ~U[2024-01-06 23:00:00Z],
               stats: %{follows: 121, chat_messages: 435, hours_watched: 120, subscriptions: 5}
             } = request
    end
  end

  describe "delete/1" do
    test "with valid request_id", %{metadata: metadata} do
      {:ok, _request} = Request.create(metadata)

      :ok = Request.delete(metadata.request_id)

      {:error, :not_found} = Request.get(request_id: metadata.request_id)
    end

    test "with invalid request_id" do
      :error = Request.delete("oops")
    end
  end

  describe "all/1" do
    setup do
      metadatas = [
        %Metadata{
          user_id: "441903922",
          username: "lanfeust313",
          request_id: "wajqn3CmIo9PoFOQ8nMYCoARYOyQp7Kc",
          start_time: ~U[2019-06-14 22:01:14.843812Z],
          end_time: ~U[2024-01-06 23:00:00Z]
        },
        %Metadata{
          user_id: "441903922",
          username: "lanfeust313",
          request_id: "MYCoARYOyQp7Kcwajqn3CmIo9PoFOQ8n",
          start_time: ~U[2019-06-14 22:01:14.843812Z],
          end_time: ~U[2024-01-06 23:00:00Z]
        },
        %Metadata{
          user_id: "392244190",
          username: "313lanfeust",
          request_id: "MYCoARYOn3CmIo9PoFOQ8nyQp7Kcwajq",
          start_time: ~U[2019-06-14 22:01:14.843812Z],
          end_time: ~U[2024-01-06 23:00:00Z]
        }
      ]

      for metadata <- metadatas do
        {:ok, _} = Request.create(metadata)
      end

      {:ok, user_id: "441903922"}
    end

    test "with valid user_id", %{user_id: user_id} do
      {:ok, requests} = Request.all(user_id)

      assert length(requests) == 2

      for request <- requests do
        assert %TwitchStory.Twitch.Requests.Request{
                 user_id: "441903922",
                 username: "lanfeust313",
                 start_time: ~U[2019-06-14 22:01:14Z],
                 end_time: ~U[2024-01-06 23:00:00Z]
               } = request
      end
    end

    test "with invalid user_id" do
      {:ok, requests} = Request.all("invalid")

      assert Enum.empty?(requests)
    end
  end
end
