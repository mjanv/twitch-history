defmodule TwitchStory.Apis.TwitchApiTest do
  use ExUnit.Case

  alias TwitchStory.Apis.TwitchApi

  test "emotes/1" do
    assert TwitchApi.emotes(468_884_133) == [
             %{"name" => "flonflFCana"},
             %{"name" => "flonflMichal"},
             %{"name" => "flonflLenie"},
             %{"name" => "flonflMimolette"},
             %{"name" => "flonflBretsmeh"},
             %{"name" => "flonflAna"},
             %{"name" => "flonflBriquet"},
             %{"name" => "flonflPamal"},
             %{"name" => "flonflDance"},
             %{"name" => "flonflMaitreSimonin"},
             %{"name" => "flonflFCRaph"},
             %{"name" => "flonflMichaelshocked"},
             %{"name" => "flonflClapclap"},
             %{"name" => "flonflExcellent"},
             %{"name" => "flonflViolet"},
             %{"name" => "flonflMescacahuetes"},
             %{"name" => "flonflBretsyeah"},
             %{"name" => "flonflStarAc"},
             %{"name" => "flonflScream"},
             %{"name" => "flonflDutronc"},
             %{"name" => "flonflModered"},
             %{"name" => "flonflHeyoh"},
             %{"name" => "flonflSexophone"},
             %{"name" => "flonflTiburce"},
             %{"name" => "flonflBretsno"},
             %{"name" => "flonflLeq"},
             %{"name" => "flonflMercibigflo"},
             %{"name" => "flonflPopstars"},
             %{"name" => "flonflBlas"},
             %{"name" => "flonflGA"},
             %{"name" => "flonflYeah"},
             %{"name" => "flonflBeaufdefrance"},
             %{"name" => "flonflBZH"},
             %{"name" => "flonflNoel"},
             %{"name" => "flonflDroite"},
             %{"name" => "flonflNikos"},
             %{"name" => "flonflIncroyable"}
           ]
  end
end
