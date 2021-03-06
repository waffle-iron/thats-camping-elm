module Pages.Campsites.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import App.Update exposing (Msg)
import Pages.Campsites.Model exposing (..)
import App.ViewHelpers exposing (navBar, link)
import Dict


view : Model -> Html Msg
view model =
    div [ class "campsite-list" ]
        [ navBar "Camping near you" False True
        , if List.isEmpty model.campsites then
            div [ class "container" ]
                [ div [ class "centering-box" ]
                    [ h2 [ class "text-center" ] [ text "Getting some lovely campsites for you" ]
                    ]
                ]
          else
            div [ class "content" ]
                [ errorsView model.errors
                , App.ViewHelpers.campsiteListView model.location model.campsites model.parks True model.starredCampsites
                ]
        ]


errorsView : List String -> Html msg
errorsView errors =
    div [] (List.map (\error -> (p [] [ text error ])) errors)
