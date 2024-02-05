defmodule TwitchStory.Request.Commerce.Subs do
  @moduledoc false

  alias Explorer.{DataFrame, Series}
  alias TwitchStory.Request.Zipfile

  def read(file) do
    file
    |> Zipfile.csv(
      ~c"request/commerce/subs/subscriptions.csv",
      columns: [
        "channel_login",
        "access_start",
        "access_end",
        "is_paid",
        "is_recurring",
        "is_token_sub",
        "is_prime_sub",
        "is_gift",
        "is_community_gift",
        "is_anonymous_gift",
        "is_auto_renewal",
        "is_cancelled_early",
        "is_prime_to_paid",
        "is_gift_to_paid",
        "is_tier_upgrade",
        "subscription_cancelled_at",
        "subscription_cancel_reason",
        "gift_quantity",
        "promotion_name"
      ],
      nil_values: [""],
      dtypes: [
        {"access_start", {:datetime, :microsecond}},
        {"access_end", {:datetime, :microsecond}},
        {"subscription_cancelled_at", {:datetime, :microsecond}}
      ]
    )
    |> DataFrame.mutate_with(
      &[
        is_paid: Series.equal(&1["is_paid"], "t"),
        is_recurring: Series.equal(&1["is_recurring"], "t"),
        is_token_sub: Series.equal(&1["is_token_sub"], "t"),
        is_prime_sub: Series.equal(&1["is_prime_sub"], "t"),
        is_gift: Series.equal(&1["is_gift"], "t"),
        is_community_gift: Series.equal(&1["is_community_gift"], "t"),
        is_anonymous_gift: Series.equal(&1["is_anonymous_gift"], "t"),
        is_auto_renewal: Series.equal(&1["is_auto_renewal"], "t"),
        is_cancelled_early: Series.equal(&1["is_cancelled_early"], "t"),
        is_prime_to_paid: Series.equal(&1["is_prime_to_paid"], "t"),
        is_gift_to_paid: Series.equal(&1["is_gift_to_paid"], "t"),
        is_tier_upgrade: Series.equal(&1["is_tier_upgrade"], "t")
      ]
    )
  end

  def n(file) do
    file
    |> read()
    |> DataFrame.n_rows()
  end
end
