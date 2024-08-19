defmodule TwitchStory.Games.Eurovision.CountryTest do
  @moduledoc false

  use ExUnit.Case

  alias TwitchStory.Games.Eurovision.Country

  test "?" do
    countries = Country.all()

    assert countries == [
             %TwitchStory.Games.Eurovision.Country{
               name: "Albania",
               code: "AL",
               image: "https://flagsapi.com/AL/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Andorra",
               code: "AD",
               image: "https://flagsapi.com/AD/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Armenia",
               code: "AM",
               image: "https://flagsapi.com/AM/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Australia",
               code: "AU",
               image: "https://flagsapi.com/AU/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Austria",
               code: "AT",
               image: "https://flagsapi.com/AT/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Azerbaijan",
               code: "AZ",
               image: "https://flagsapi.com/AZ/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Belarus",
               code: "BY",
               image: "https://flagsapi.com/BY/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Belgium",
               code: "BE",
               image: "https://flagsapi.com/BE/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Bosnia and Herzegovina",
               code: "BA",
               image: "https://flagsapi.com/BA/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Bulgaria",
               code: "BG",
               image: "https://flagsapi.com/BG/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Croatia",
               code: "HR",
               image: "https://flagsapi.com/HR/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Cyprus",
               code: "CY",
               image: "https://flagsapi.com/CY/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Czech Republic",
               code: "CZ",
               image: "https://flagsapi.com/CZ/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Denmark",
               code: "DK",
               image: "https://flagsapi.com/DK/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Estonia",
               code: "EE",
               image: "https://flagsapi.com/EE/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Finland",
               code: "FI",
               image: "https://flagsapi.com/FI/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               code: "FR",
               image: "https://flagsapi.com/FR/shiny/64.png",
               name: "France"
             },
             %TwitchStory.Games.Eurovision.Country{
               code: "GE",
               image: "https://flagsapi.com/GE/shiny/64.png",
               name: "Georgia"
             },
             %TwitchStory.Games.Eurovision.Country{
               code: "DE",
               image: "https://flagsapi.com/DE/shiny/64.png",
               name: "Germany"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Greece",
               code: "GR",
               image: "https://flagsapi.com/GR/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Hungary",
               code: "HU",
               image: "https://flagsapi.com/HU/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Iceland",
               code: "IS",
               image: "https://flagsapi.com/IS/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Ireland",
               code: "IE",
               image: "https://flagsapi.com/IE/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Israel",
               code: "IL",
               image: "https://flagsapi.com/IL/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Italy",
               code: "IT",
               image: "https://flagsapi.com/IT/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Kazakhstan",
               code: "KZ",
               image: "https://flagsapi.com/KZ/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Latvia",
               code: "LV",
               image: "https://flagsapi.com/LV/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Liechtenstein",
               code: "LI",
               image: "https://flagsapi.com/LI/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Lithuania",
               code: "LT",
               image: "https://flagsapi.com/LT/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Luxembourg",
               code: "LU",
               image: "https://flagsapi.com/LU/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Malta",
               code: "MT",
               image: "https://flagsapi.com/MT/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Moldova",
               code: "MD",
               image: "https://flagsapi.com/MD/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Monaco",
               code: "MC",
               image: "https://flagsapi.com/MC/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Montenegro",
               code: "ME",
               image: "https://flagsapi.com/ME/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Netherlands",
               code: "NL",
               image: "https://flagsapi.com/NL/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "North Macedonia",
               code: "MK",
               image: "https://flagsapi.com/MK/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Norway",
               code: "NO",
               image: "https://flagsapi.com/NO/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Poland",
               code: "PL",
               image: "https://flagsapi.com/PL/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Portugal",
               code: "PT",
               image: "https://flagsapi.com/PT/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Romania",
               code: "RO",
               image: "https://flagsapi.com/RO/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "San Marino",
               code: "SM",
               image: "https://flagsapi.com/SM/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Serbia",
               code: "RS",
               image: "https://flagsapi.com/RS/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Slovakia",
               code: "SK",
               image: "https://flagsapi.com/SK/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Slovenia",
               code: "SI",
               image: "https://flagsapi.com/SI/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               code: "ES",
               image: "https://flagsapi.com/ES/shiny/64.png",
               name: "Spain"
             },
             %TwitchStory.Games.Eurovision.Country{
               code: "SE",
               image: "https://flagsapi.com/SE/shiny/64.png",
               name: "Sweden"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Switzerland",
               code: "CH",
               image: "https://flagsapi.com/CH/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Turkey",
               code: "TR",
               image: "https://flagsapi.com/TR/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "Ukraine",
               code: "UA",
               image: "https://flagsapi.com/UA/shiny/64.png"
             },
             %TwitchStory.Games.Eurovision.Country{
               name: "United Kingdom",
               code: "GB",
               image: "https://flagsapi.com/GB/shiny/64.png"
             }
           ]
  end
end
