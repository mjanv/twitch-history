defmodule TwitchStory.FileStorageTest do
  use ExUnit.Case, async: true

  alias TwitchStory.FileStorage

  @moduletag :s3
  @moduletag :wip

  test "buckets/0" do
    {:ok, buckets} = FileStorage.buckets()

    assert buckets == [
             %{name: "exchess", creation_date: "2024-06-14T23:10:33Z"},
             %{name: "twitch-story-data", creation_date: "2024-11-09T15:18:23Z"}
           ]
  end

  test "bucket/1" do
    {:ok, contents} = FileStorage.bucket("twitch-story-data")

    assert [
             %{
               owner: %{id: "", display_name: ""},
               size: "4",
               key: "test/test.txt",
               last_modified: _,
               storage_class: "STANDARD",
               e_tag: "\"098f6bcd4621d373cade4e832627b4f6\""
             }
           ] = contents
  end

  @tag :tmp_dir
  test "put/3", %{tmp_dir: tmp_dir} do
    # generate a random file in tmp_dir
    origin = Path.join(tmp_dir, "test.txt")
    dest = "/test/test.txt"
    File.write!(origin, "test")

    :ok = FileStorage.put("twitch-story-data", origin, dest)
  end

  @tag :tmp_dir
  test "get/3", %{tmp_dir: tmp_dir} do
    # generate a random file in tmp_dir
    origin = Path.join(tmp_dir, "test.txt")
    dest = "/test/test.txt"
    File.write!(origin, "test")

    :ok = FileStorage.put("twitch-story-data", origin, dest)

    :ok = FileStorage.get("twitch-story-data", dest, origin)
    assert File.read!(origin) == "test"
  end
end
