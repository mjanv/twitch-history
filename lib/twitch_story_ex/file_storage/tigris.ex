defmodule TwitchStory.FileStorage.Tigris do
  @moduledoc """
  S3-compatible file storage

  Reference: https://www.tigrisdata.com/docs/sdks/s3/aws-elixir-sdk/
  """

  @behaviour TwitchStory.FileStorage.Behaviour

  @type bucket() :: %{
          name: String.t(),
          creation_date: String.t()
        }

  defp bucket, do: Application.get_env(:twitch_story, :bucket)

  @impl true
  def create(origin, destination), do: put(bucket(), origin, destination)

  @impl true
  def read(origin, destination), do: get(bucket(), origin, destination)

  @impl true
  def delete(origin), do: delete(bucket(), origin)

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

  @spec delete(String.t(), String.t()) :: :ok | :error
  def delete(bucket_name, from) do
    with request <- ExAws.S3.delete_object(bucket_name, from),
         {:ok, _response} <- ExAws.request(request) do
      :ok
    else
      {:error, _reason} -> :error
    end
  end
end
