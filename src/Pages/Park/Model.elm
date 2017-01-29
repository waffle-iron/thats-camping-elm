module Pages.Park.Model exposing (Model)

import App.Model exposing (Park, Campsite, Location)
import Dict exposing (Dict)


type alias Model =
    { park : Park
    , campsites : List Campsite
    , parks : Dict Int Park
    , location : Maybe Location
    }
