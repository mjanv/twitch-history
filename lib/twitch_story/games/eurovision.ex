defmodule TwitchStory.Games.Eurovision do
  @moduledoc false

  alias TwitchStory.Games.Eurovision.Country

  defdelegate get_country(code), to: Country, as: :get
end
