module App exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Geolocation
import Task
import Location
import Campsite
import Http
import Decoder
import Dict exposing (Dict)
import RouteUrl
import RouteUrl.Builder
import Navigation
import Pages.About.View
import App.Model exposing (..)
import App.Update exposing (..)
import App.View exposing (..)


type alias Error =
    -- We could have more kind of errors here
    Geolocation.Error


type alias Model =
    { campsites : List Campsite
    , parks : Dict Int Park
    , location : Maybe Location
    , error : Maybe Error
    , page : Page
    }


init : ( Model, Cmd Msg )
init =
    ( { campsites = [], parks = Dict.empty, location = Nothing, error = Nothing, page = Campsites }
      -- On startup immediately try to get the location and the campsite data
    , Cmd.batch [ Task.attempt UpdateLocation Geolocation.now, syncData ]
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main =
    RouteUrl.program { delta2url = delta2hash, location2messages = hash2messages, init = init, view = view, update = update, subscriptions = subscriptions }


hash2messages : Navigation.Location -> List Msg
hash2messages location =
    let
        hash =
            RouteUrl.Builder.path (RouteUrl.Builder.fromHash location.href)
    in
        if hash == [ "campsites" ] then
            [ ChangePage Campsites ]
        else if hash == [ "about" ] then
            [ ChangePage About ]
        else
            -- TODO: Show a 404 page here instead of doing nothing
            []


delta2hash : Model -> Model -> Maybe RouteUrl.UrlChange
delta2hash previous current =
    Just (RouteUrl.UrlChange RouteUrl.NewEntry (page2url current.page))


view : Model -> Html Msg
view model =
    case model.page of
        Campsites ->
            campsitesView model

        About ->
            Pages.About.View.view


campsitesView : Model -> Html Msg
campsitesView model =
    div [ id "app" ]
        [ div [ class "campsite-list" ]
            [ navBar "Camping near you" False True
            , div [ class "content" ]
                [ div [] [ text (formatError model.error) ]
                , div [ class "list-group" ]
                    (List.map (campsiteListItem model.location model.parks) (sortCampsites model.location model.campsites))
                ]
            ]
        ]


sortCampsites : Maybe Location -> List Campsite -> List Campsite
sortCampsites location campsites =
    List.sortWith (Campsite.compareCampsite location) campsites


formatError : Maybe Error -> String
formatError error =
    case error of
        Just (Geolocation.PermissionDenied text) ->
            "Permission denied: " ++ text

        Just (Geolocation.LocationUnavailable text) ->
            "Location unavailable: " ++ text

        Just (Geolocation.Timeout text) ->
            "Timeout: " ++ text

        Nothing ->
            ""


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewCampsite campsite ->
            ( { model | campsites = campsite :: model.campsites }, Cmd.none )

        UpdateLocation (Err error) ->
            ( { model | error = Just error }, Cmd.none )

        UpdateLocation (Ok location) ->
            ( { model | location = Just (Location location.latitude location.longitude) }, Cmd.none )

        NewData (Err error) ->
            -- TODO: Make it show the error. For the time being does nothing
            ( model, Cmd.none )

        NewData (Ok data) ->
            -- Replace the current campsites with the new ones
            ( { model | campsites = data.campsites, parks = (transformParks data.parks) }, Cmd.none )

        ChangePage page ->
            ( { model | page = page }, Cmd.none )

        PageBack ->
            ( model, Navigation.back 1 )


transformParks : List Park -> Dict Int Park
transformParks parks =
    Dict.fromList (List.map (\park -> ( park.id, park )) parks)


campsiteListItem : Maybe Location -> Dict Int Park -> Campsite -> Html msg
campsiteListItem location parks campsite =
    a [ href "#", class "list-group-item" ]
        [ div [ class "campsite" ]
            [ div [ class "pull-right distance" ] [ text (bearingAndDistanceAsText location campsite.location) ]
            , div [ class "name" ] [ text campsite.name ]
            , div [ class "park" ] [ text (parkNameFromId campsite.parkId parks) ]
            ]
        ]


parkNameFromId : Int -> Dict Int Park -> String
parkNameFromId id parks =
    case Dict.get id parks of
        Just park ->
            park.name

        Nothing ->
            ""


bearingAndDistanceAsText : Maybe Location -> Maybe Location -> String
bearingAndDistanceAsText from to =
    case (Maybe.map2 Location.bearingAndDistanceText from to) of
        Just text ->
            text

        Nothing ->
            ""


syncData =
    let
        -- Just load the json data from github for the time being. Should do something
        -- more sensible than this in the longer term but it's good enough for now
        url =
            "https://raw.githubusercontent.com/mlandauer/thats-camping-react/master/data.json"

        request =
            Http.get url Decoder.parksAndCampsites
    in
        Http.send NewData request
