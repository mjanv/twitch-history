defmodule TwitchStory.Games.Eurovision.Country.RepoTest do
  @moduledoc false

  use ExUnit.Case

  alias TwitchStory.Games.Eurovision.Country.Repo

  test "all/0" do
    countries = Repo.all()

    assert countries == [
             %{
               name: "Albania",
               code: "AL"
             },
             %{
               name: "Andorra",
               code: "AD"
             },
             %{
               name: "Armenia",
               code: "AM"
             },
             %{
               name: "Australia",
               code: "AU"
             },
             %{
               name: "Austria",
               code: "AT"
             },
             %{
               name: "Azerbaijan",
               code: "AZ"
             },
             %{
               name: "Belarus",
               code: "BY"
             },
             %{
               name: "Belgium",
               code: "BE"
             },
             %{
               name: "Bosnia and Herzegovina",
               code: "BA"
             },
             %{
               name: "Bulgaria",
               code: "BG"
             },
             %{
               name: "Croatia",
               code: "HR"
             },
             %{
               name: "Cyprus",
               code: "CY"
             },
             %{
               name: "Czech Republic",
               code: "CZ"
             },
             %{
               name: "Denmark",
               code: "DK"
             },
             %{
               name: "Estonia",
               code: "EE"
             },
             %{
               name: "Finland",
               code: "FI"
             },
             %{
               code: "FR",
               name: "France"
             },
             %{
               code: "GE",
               name: "Georgia"
             },
             %{
               code: "DE",
               name: "Germany"
             },
             %{
               name: "Greece",
               code: "GR"
             },
             %{
               name: "Hungary",
               code: "HU"
             },
             %{
               name: "Iceland",
               code: "IS"
             },
             %{
               name: "Ireland",
               code: "IE"
             },
             %{
               name: "Israel",
               code: "IL"
             },
             %{
               name: "Italy",
               code: "IT"
             },
             %{
               name: "Kazakhstan",
               code: "KZ"
             },
             %{
               name: "Latvia",
               code: "LV"
             },
             %{
               name: "Liechtenstein",
               code: "LI"
             },
             %{
               name: "Lithuania",
               code: "LT"
             },
             %{
               name: "Luxembourg",
               code: "LU"
             },
             %{
               name: "Malta",
               code: "MT"
             },
             %{
               name: "Moldova",
               code: "MD"
             },
             %{
               name: "Monaco",
               code: "MC"
             },
             %{
               name: "Montenegro",
               code: "ME"
             },
             %{
               name: "Netherlands",
               code: "NL"
             },
             %{
               name: "North Macedonia",
               code: "MK"
             },
             %{
               name: "Norway",
               code: "NO"
             },
             %{
               name: "Poland",
               code: "PL"
             },
             %{
               name: "Portugal",
               code: "PT"
             },
             %{
               name: "Romania",
               code: "RO"
             },
             %{
               name: "San Marino",
               code: "SM"
             },
             %{
               name: "Serbia",
               code: "RS"
             },
             %{
               name: "Slovakia",
               code: "SK"
             },
             %{
               name: "Slovenia",
               code: "SI"
             },
             %{
               code: "ES",
               name: "Spain"
             },
             %{
               code: "SE",
               name: "Sweden"
             },
             %{
               name: "Switzerland",
               code: "CH"
             },
             %{
               name: "Turkey",
               code: "TR"
             },
             %{
               name: "Ukraine",
               code: "UA"
             },
             %{
               name: "United Kingdom",
               code: "GB"
             }
           ]
  end

  test "codes/0" do
    assert Repo.codes() == [
             "AL",
             "AD",
             "AM",
             "AU",
             "AT",
             "AZ",
             "BY",
             "BE",
             "BA",
             "BG",
             "HR",
             "CY",
             "CZ",
             "DK",
             "EE",
             "FI",
             "FR",
             "GE",
             "DE",
             "GR",
             "HU",
             "IS",
             "IE",
             "IL",
             "IT",
             "KZ",
             "LV",
             "LI",
             "LT",
             "LU",
             "MT",
             "MD",
             "MC",
             "ME",
             "NL",
             "MK",
             "NO",
             "PL",
             "PT",
             "RO",
             "SM",
             "RS",
             "SK",
             "SI",
             "ES",
             "SE",
             "CH",
             "TR",
             "UA",
             "GB"
           ]
  end

  test "names/0" do
    assert Repo.names() == [
             "Albania",
             "Andorra",
             "Armenia",
             "Australia",
             "Austria",
             "Azerbaijan",
             "Belarus",
             "Belgium",
             "Bosnia and Herzegovina",
             "Bulgaria",
             "Croatia",
             "Cyprus",
             "Czech Republic",
             "Denmark",
             "Estonia",
             "Finland",
             "France",
             "Georgia",
             "Germany",
             "Greece",
             "Hungary",
             "Iceland",
             "Ireland",
             "Israel",
             "Italy",
             "Kazakhstan",
             "Latvia",
             "Liechtenstein",
             "Lithuania",
             "Luxembourg",
             "Malta",
             "Moldova",
             "Monaco",
             "Montenegro",
             "Netherlands",
             "North Macedonia",
             "Norway",
             "Poland",
             "Portugal",
             "Romania",
             "San Marino",
             "Serbia",
             "Slovakia",
             "Slovenia",
             "Spain",
             "Sweden",
             "Switzerland",
             "Turkey",
             "Ukraine",
             "United Kingdom"
           ]
  end
end
