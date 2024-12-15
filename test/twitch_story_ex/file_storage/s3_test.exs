defmodule TwitchStory.FileStorage.TigrisTest do
  use ExUnit.Case, async: true

  alias TwitchStory.FileStorage.Tigris

  @moduletag :s3

  test "buckets/0" do
    {:ok, buckets} = Tigris.buckets()

    assert buckets == [
             %{name: "exchess", creation_date: "2024-06-14T23:10:33Z"},
             %{name: "twitch-story-data", creation_date: "2024-11-09T15:18:23Z"}
           ]
  end

  test "bucket/1" do
    {:ok, contents} = Tigris.bucket("twitch-story-data")

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
    origin = Path.join(tmp_dir, "test.txt")
    dest = "/test/test.txt"
    File.write!(origin, "test")

    :ok = Tigris.put("twitch-story-data", origin, dest)
  end

  @tag :tmp_dir
  test "get/3", %{tmp_dir: tmp_dir} do
    origin = Path.join(tmp_dir, "test.txt")
    dest = "/test/test.txt"
    File.write!(origin, "test")

    :ok = Tigris.put("twitch-story-data", origin, dest)

    :ok = Tigris.get("twitch-story-data", dest, origin)
    assert File.read!(origin) == "test"
  end

  @tag :tmp_dir
  test "delete/1", %{tmp_dir: tmp_dir} do
    origin = Path.join(tmp_dir, "test.txt")
    dest = "/test/test.txt"
    File.write!(origin, "test")

    :ok = Tigris.put("twitch-story-data", origin, dest)

    :ok = Tigris.delete("twitch-story-data", dest)

    assert {:error, :enoent} = File.read(origin)
  end
end
