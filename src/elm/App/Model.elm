module App.Model exposing (Page(..), Model)

import Dict exposing (Dict)
import Pages.Admin.Model
import Campsite exposing (Campsite)
import Park exposing (Park)
import Location exposing (Location)


type Page
    = CampsitesPage
    | CampsitePage String
    | ParkPage String
    | AboutPage
    | AdminPage
      -- This is the 404 page
    | UnknownPage


type alias Model =
    { campsites : Dict String Campsite
    , parks : Dict String Park
    , location : Maybe Location
    , errors : List String
    , starredCampsites : List String
    , page : Page
    , adminModel : Pages.Admin.Model.Model
    , standalone : Bool
    , version : String
    , online : Bool
    }
