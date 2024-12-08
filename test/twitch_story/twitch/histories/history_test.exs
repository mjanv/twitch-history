defmodule TwitchStory.Twitch.Histories.HistoryTest do
  use TwitchStory.DataCase

  alias TwitchStory.Twitch.Histories.{History, Metadata, Summary}

  setup do
    metadata = %Metadata{
      user_id: "441903922",
      username: "lanfeust313",
      history_id: "MYCoARYOyQp7Kcwajqn3CmIo9PoFOQ8n",
      start_time: ~U[2019-06-14 22:01:14Z],
      end_time: ~U[2024-01-06 23:00:00Z]
    }

    summary = %{follows: 121, chat_messages: 435, hours_watched: 120, subscriptions: 5}

    {:ok, %{metadata: metadata, summary: summary}}
  end

  describe "create/1" do
    test "valid metadata", %{metadata: metadata} do
      {:ok, history} = History.create(metadata)

      assert %History{
               user_id: "441903922",
               username: "lanfeust313",
               history_id: "MYCoARYOyQp7Kcwajqn3CmIo9PoFOQ8n",
               start_time: ~U[2019-06-14 22:01:14Z],
               end_time: ~U[2024-01-06 23:00:00Z]
             } = history
    end

    test "already exists", %{metadata: metadata} do
      {:ok, history_1} = History.create(metadata)
      {:ok, history_2} = History.create(metadata)

      assert Map.drop(history_1, [:id]) == Map.drop(history_2, [:id])
    end
  end

  describe "get/1" do
    test "with valid history_id", %{metadata: metadata} do
      {:ok, _} = History.create(metadata)

      {:ok, history} = History.get(history_id: metadata.history_id)

      assert %History{
               user_id: "441903922",
               username: "lanfeust313",
               history_id: "MYCoARYOyQp7Kcwajqn3CmIo9PoFOQ8n",
               start_time: ~U[2019-06-14 22:01:14Z],
               end_time: ~U[2024-01-06 23:00:00Z]
             } = history
    end

    test "with invalid history_id" do
      {:error, :not_found} = History.get(history_id: "invalid")
    end
  end

  describe "update/2" do
    test "with summary", %{metadata: metadata, summary: summary} do
      {:ok, history} = History.create(metadata)
      {:ok, history} = History.update(history, summary: summary)

      assert %History{
               user_id: "441903922",
               username: "lanfeust313",
               history_id: "MYCoARYOyQp7Kcwajqn3CmIo9PoFOQ8n",
               start_time: ~U[2019-06-14 22:01:14Z],
               end_time: ~U[2024-01-06 23:00:00Z],
               summary: %Summary{
                 follows: 121,
                 chat_messages: 435,
                 hours_watched: 120,
                 subscriptions: 5
               }
             } = history
    end
  end

  describe "delete/1" do
    test "with valid history_id", %{metadata: metadata} do
      {:ok, _request} = History.create(metadata)

      :ok = History.delete(metadata.history_id)

      {:error, :not_found} = History.get(history_id: metadata.history_id)
    end

    test "with invalid history_id" do
      :error = History.delete("oops")
    end
  end

  describe "all/1" do
    setup do
      metadatas = [
        %Metadata{
          user_id: "441903922",
          username: "lanfeust313",
          history_id: "wajqn3CmIo9PoFOQ8nMYCoARYOyQp7Kc",
          start_time: ~U[2019-06-14 22:01:14.843812Z],
          end_time: ~U[2024-01-06 23:00:00Z]
        },
        %Metadata{
          user_id: "441903922",
          username: "lanfeust313",
          history_id: "MYCoARYOyQp7Kcwajqn3CmIo9PoFOQ8n",
          start_time: ~U[2019-06-14 22:01:14.843812Z],
          end_time: ~U[2024-01-06 23:00:00Z]
        },
        %Metadata{
          user_id: "392244190",
          username: "313lanfeust",
          history_id: "MYCoARYOn3CmIo9PoFOQ8nyQp7Kcwajq",
          start_time: ~U[2019-06-14 22:01:14.843812Z],
          end_time: ~U[2024-01-06 23:00:00Z]
        }
      ]

      for metadata <- metadatas do
        {:ok, _} = History.create(metadata)
      end

      {:ok, user_id: "441903922"}
    end

    test "with valid user_id", %{user_id: user_id} do
      histories = History.all(user_id)

      assert length(histories) == 2

      for history <- histories do
        assert %History{
                 user_id: "441903922",
                 username: "lanfeust313",
                 start_time: ~U[2019-06-14 22:01:14Z],
                 end_time: ~U[2024-01-06 23:00:00Z]
               } = history
      end
    end

    test "with invalid user_id" do
      histories = History.all("invalid")

      assert Enum.empty?(histories)
    end
  end
end
