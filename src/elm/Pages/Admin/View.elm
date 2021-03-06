module Pages.Admin.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Pages.Admin.Update exposing (..)
import Pages.Admin.Model exposing (..)
import Dict exposing (Dict)
import Campsite exposing (Campsite)
import App.ViewHelpers exposing (link)
import App.Model exposing (Page(..))
import Pages.Admin.Update exposing (..)


view : Model -> Html Msg
view model =
    div [ class "content" ]
        [ div [ class "container" ]
            [ h2 [] [ text "Database admin page" ]
            , p [] [ text "Here you can do actions on the local PouchDB database" ]
            , div [ class "btn-group-vertical" ]
                [ button [ class "btn btn-default", onClick Destroy ] [ text "Destroy local database" ]
                , button [ class "btn btn-default", onClick LoadData ] [ text "Load local database campsite data from Github" ]
                , button [ class "btn btn-default", onClick ToggleLaneCoveName ]
                    [ text
                        ((if Maybe.withDefault False (Maybe.map laneCoveNameChanged (getLaneCove model.campsites)) then
                            "Reset"
                          else
                            "Change"
                         )
                            ++ " name of Lane Cover River campsite"
                        )
                    ]
                ]
            , p [] [ text "Or you can go ", link CampsitesPage [] [ text "back to the main campsites list" ] ]
            , p [] [ text (Maybe.withDefault "" model.text) ]
            ]
        ]
