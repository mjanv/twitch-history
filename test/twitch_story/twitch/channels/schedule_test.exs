defmodule TwitchStory.Twitch.Channels.ScheduleTest do
  @moduledoc false

  use TwitchStory.DataCase

  import TwitchStory.TwitchFixtures

  alias TwitchStory.Twitch.Channels.Schedule

  describe "save/2" do
    test "saves a schedule" do
      channel = channel_fixture()

      entries = [
        %{
          entry_id: "1",
          title: "title",
          category: "category",
          start_time: ~U[2022-01-01 00:00:00Z],
          end_time: ~U[2022-01-01 01:00:00Z],
          is_canceled: true,
          is_recurring: false
        },
        %{
          entry_id: "2",
          title: "title",
          category: "category2",
          start_time: ~U[2022-01-02 00:00:00Z],
          end_time: ~U[2022-01-02 01:00:00Z],
          is_canceled: false,
          is_recurring: true
        }
      ]

      {:ok, schedule} = Schedule.save(channel, entries)

      assert schedule.channel_id == channel.id

      assert Enum.map(schedule.entries, fn e -> Map.put(e, :id, nil) end) == [
               %Schedule.Entry{
                 entry_id: "1",
                 title: "title",
                 category: "category",
                 start_time: ~U[2022-01-01 00:00:00Z],
                 end_time: ~U[2022-01-01 01:00:00Z],
                 is_canceled: true,
                 is_recurring: false
               },
               %Schedule.Entry{
                 entry_id: "2",
                 title: "title",
                 category: "category2",
                 start_time: ~U[2022-01-02 00:00:00Z],
                 end_time: ~U[2022-01-02 01:00:00Z],
                 is_canceled: false,
                 is_recurring: true
               }
             ]
    end

    test "replaces all existing entries when saving a new schedule" do
      channel = channel_fixture()

      old_entries = [
        %{
          entry_id: "1",
          title: "title",
          category: "category",
          start_time: ~U[2022-01-01 00:00:00Z],
          end_time: ~U[2022-01-01 01:00:00Z],
          is_canceled: true,
          is_recurring: false
        },
        %{
          entry_id: "2",
          title: "title",
          category: "category2",
          start_time: ~U[2022-01-02 00:00:00Z],
          end_time: ~U[2022-01-02 01:00:00Z],
          is_canceled: false,
          is_recurring: true
        }
      ]

      new_entries = [
        %{
          entry_id: "1",
          title: "title",
          category: "category",
          start_time: ~U[2023-01-01 00:00:00Z],
          end_time: ~U[2023-01-01 01:00:00Z],
          is_canceled: true,
          is_recurring: false
        },
        %{
          entry_id: "2",
          title: "title",
          category: "category2",
          start_time: ~U[2023-01-02 00:00:00Z],
          end_time: ~U[2023-01-02 01:00:00Z],
          is_canceled: false,
          is_recurring: true
        },
        %{
          entry_id: "3",
          title: "title",
          category: "category3",
          start_time: ~U[2023-01-03 00:00:00Z],
          end_time: ~U[2023-01-03 01:00:00Z],
          is_canceled: false,
          is_recurring: true
        }
      ]

      {:ok, schedule1} = Schedule.save(channel, old_entries)
      {:ok, schedule2} = Schedule.save(channel, new_entries)

      assert schedule1.id == schedule2.id
      assert schedule2.channel_id == channel.id

      assert Enum.map(schedule2.entries, fn e -> Map.put(e, :id, nil) end) == [
               %Schedule.Entry{
                 entry_id: "1",
                 title: "title",
                 category: "category",
                 start_time: ~U[2023-01-01 00:00:00Z],
                 end_time: ~U[2023-01-01 01:00:00Z],
                 is_canceled: true,
                 is_recurring: false
               },
               %Schedule.Entry{
                 entry_id: "2",
                 title: "title",
                 category: "category2",
                 start_time: ~U[2023-01-02 00:00:00Z],
                 end_time: ~U[2023-01-02 01:00:00Z],
                 is_canceled: false,
                 is_recurring: true
               },
               %Schedule.Entry{
                 entry_id: "3",
                 title: "title",
                 category: "category3",
                 start_time: ~U[2023-01-03 00:00:00Z],
                 end_time: ~U[2023-01-03 01:00:00Z],
                 is_canceled: false,
                 is_recurring: true
               }
             ]
    end

    test "no entries wipes the schedule entries" do
      channel = channel_fixture()

      old_entries = [
        %{
          entry_id: "1",
          title: "title",
          category: "category",
          start_time: ~U[2022-01-01 00:00:00Z],
          end_time: ~U[2022-01-01 01:00:00Z],
          is_canceled: true,
          is_recurring: false
        },
        %{
          entry_id: "2",
          title: "title",
          category: "category2",
          start_time: ~U[2022-01-02 00:00:00Z],
          end_time: ~U[2022-01-02 01:00:00Z],
          is_canceled: false,
          is_recurring: true
        }
      ]

      new_entries = []

      {:ok, _} = Schedule.save(channel, old_entries)
      {:ok, schedule} = Schedule.save(channel, new_entries)

      assert schedule.channel_id == channel.id
      assert schedule.entries == []
    end

    test "does not save a schedule with invalid data" do
      channel = channel_fixture()

      entries = [
        %{
          entry_id: "1"
        }
      ]

      assert {:error, %Ecto.Changeset{}} = Schedule.save(channel, entries)
    end
  end

  describe "count/0" do
    test "returns the number of schedules" do
      for _ <- 1..10 do
        {:ok, _} = Schedule.save(channel_fixture(), [])
      end

      assert Schedule.count() == 10
    end
  end

  describe "get!/1" do
    test "returns the schedule for a given channel" do
      channel = channel_fixture()

      entries = [
        %{
          entry_id: "1",
          title: "title",
          category: "category",
          start_time: ~U[2022-01-01 00:00:00Z],
          end_time: ~U[2022-01-01 01:00:00Z],
          is_canceled: true,
          is_recurring: false
        },
        %{
          entry_id: "2",
          title: "title",
          category: "category2",
          start_time: ~U[2022-01-02 00:00:00Z],
          end_time: ~U[2022-01-02 01:00:00Z],
          is_canceled: false,
          is_recurring: true
        }
      ]

      {:ok, _} = Schedule.save(channel, entries)
      %Schedule{channel_id: channel_id, entries: entries} = Schedule.get!(channel.id)

      assert channel_id == channel.id

      assert Enum.map(entries, fn e -> Map.put(e, :id, nil) end) == [
               %Schedule.Entry{
                 entry_id: "1",
                 title: "title",
                 category: "category",
                 start_time: ~U[2022-01-01 00:00:00Z],
                 end_time: ~U[2022-01-01 01:00:00Z],
                 is_canceled: true,
                 is_recurring: false
               },
               %Schedule.Entry{
                 entry_id: "2",
                 title: "title",
                 category: "category2",
                 start_time: ~U[2022-01-02 00:00:00Z],
                 end_time: ~U[2022-01-02 01:00:00Z],
                 is_canceled: false,
                 is_recurring: true
               }
             ]
    end
  end
end
