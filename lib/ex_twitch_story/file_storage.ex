defmodule ExTwitchStory.FileStorage do
  @moduledoc false

  @type bucket() :: %{
          name: String.t(),
          creation_date: String.t()
        }

  @spec buckets() :: {:ok, [bucket()]} | {:error, any()}
  def buckets do
    ExAws.S3.list_buckets()
    |> ExAws.request()
    |> case do
      {:ok, %{body: %{buckets: buckets}}} -> {:ok, buckets}
      {:error, reason} -> {:error, reason}
    end
  end

  @spec bucket(String.t()) :: {:ok, [map()]} | {:error, any()}
  def bucket(bucket_name) do
    bucket_name
    |> ExAws.S3.list_objects()
    |> ExAws.request!()
    |> get_in([:body, :contents])
  end
end
