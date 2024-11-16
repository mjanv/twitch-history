defmodule TwitchStory.FileStorage do
  @moduledoc """
  S3-compatible file storage

  Reference: https://www.tigrisdata.com/docs/sdks/s3/aws-elixir-sdk/
  """

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
    |> ExAws.request()
    |> case do
      {:ok, %{body: %{contents: contents}}} -> {:ok, contents}
      {:error, reason} -> {:error, reason}
    end
  end

  @spec put(String.t(), String.t(), String.t()) :: :ok | :error
  def put(bucket_name, origin, dest) do
    with {:ok, content} <- File.read(origin),
         request <- ExAws.S3.put_object(bucket_name, dest, content),
         {:ok, _response} <- ExAws.request(request) do
      :ok
    else
      {:error, _reason} -> :error
    end
  end

  @spec get(String.t(), String.t(), String.t()) :: :ok | :error
  def get(bucket_name, from, dest) do
    with request <- ExAws.S3.get_object(bucket_name, from),
         {:ok, %{body: body}} <- ExAws.request(request),
         :ok <- File.write(dest, body) do
      :ok
    else
      {:error, _reason} -> :error
    end
  end
end
