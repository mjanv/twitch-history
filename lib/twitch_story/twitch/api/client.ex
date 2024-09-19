defmodule TwitchStory.Twitch.Api.Client do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      @type ok(a) :: {:ok, a}
      @type result(a, b) :: {:ok, a} | {:error, b}

      @type cursor() :: String.t() | nil

      @type token() :: %{
              required(:twitch_user_id) => String.t(),
              required(:access_token) => String.t(),
              required(:user) => %{
                required(:twitch_id) => String.t()
              }
            }

      defp ok(data), do: {:ok, data}
      defp error(data), do: {:error, data}

      defp unwrap(data, keys) when is_list(data) do
        Enum.map(data, fn d -> unwrap(d, keys) end)
      end

      defp unwrap(data, keys) do
        data
        |> Map.take(keys)
        |> string_to_atom_keys()
      end

      defp string_to_atom_keys(m) do
        for {k, v} <- m, into: %{}, do: {String.to_atom(k), v}
      end

      defp as_date(data, keys) when is_list(data) do
        Enum.map(data, fn d -> as_date(d, keys) end)
      end

      defp as_date(data, keys) do
        Enum.reduce(keys, data, fn k, d ->
          Map.update!(d, k, fn v ->
            v |> DateTime.from_iso8601() |> elem(1)
          end)
        end)
      end

      def nest_keys(map, keys_to_nest, key) do
        {head, tail} = Map.split(map, keys_to_nest)
        Map.put(tail, key, head)
      end
    end
  end
end
