module Pages.Campsite.View
    exposing
        ( view
        , haveAndHaveNotSentence
        , listAsText
        , facilitiesText
        , accessText
        )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Pages.Campsite.Model exposing (..)
import App.ViewHelpers
import App.Update exposing (Msg(..))
import Libs.SimpleFormat.Format
import App.Model exposing (Page(..))
import Location exposing (Location)
import Campsite
    exposing
        ( Facilities
        , Toilets(..)
        , PicnicTables(..)
        , Barbecues(..)
        , Showers(..)
        , DrinkingWater(..)
        , Access
        , Caravans(..)
        , Trailers(..)
        , Cars(..)
        )


view : Model -> Html Msg
view model =
    div [ class "campsite-detail-page" ]
        [ App.ViewHelpers.navBar model.campsite.shortName True False
        , div [ class "content" ]
            [ div [ class "container" ]
                [ div [ class "campsite-detail" ]
                    [ App.ViewHelpers.star model.starred (Just (ToggleStarCampsite model.campsite.id))
                    , h2 []
                        [ text model.campsite.longName ]
                    , p []
                        (case model.park of
                            Just park ->
                                [ text "in "
                                , App.ViewHelpers.link (ParkPage park.id) [] [ text park.longName ]
                                , text "."
                                ]

                            Nothing ->
                                []
                        )
                    , Libs.SimpleFormat.Format.format model.campsite.description
                    , h2 [] [ text "Facilities" ]
                    , p [] [ text (facilitiesText model.campsite.facilities) ]
                    , h2 [] [ text "Access" ]
                    , p [] [ text (accessText model.campsite.access) ]
                    , a
                        ([ href (Maybe.withDefault "#" (Maybe.map mapUrl model.campsite.location))
                         , class "directions btn btn-default"
                         ]
                            ++ -- TODO: It's not actually valid HTML (I think) to disable a link with disabled
                               if directionsDisabled model.campsite.location model.online then
                                [ attribute "disabled" "disabled" ]
                               else
                                []
                        )
                        [ text "Directions to campsite" ]
                    ]
                ]
            ]
        ]


facilitiesText : Facilities -> String
facilitiesText facilities =
    Maybe.withDefault ""
        (haveAndHaveNotSentence
            "has"
            (listAsText (facilitiesList True facilities))
            "but"
            "no"
            (listAsText (facilitiesList False facilities))
        )


accessText : Access -> String
accessText access =
    Maybe.withDefault ""
        (haveAndHaveNotSentence
            "for"
            (listAsText (accessList True access))
            "but"
            "not for"
            (listAsText (accessList False access))
        )


mapUrl : Location -> String
mapUrl location =
    "https://maps.google.com/maps?daddr="
        ++ (toString location.latitude)
        ++ ","
        ++ (toString location.longitude)


directionsDisabled : Maybe Location -> Bool -> Bool
directionsDisabled location online =
    if online then
        -- TODO: Also disable button when we have don't an internet connection
        case location of
            Just _ ->
                False

            Nothing ->
                True
    else
        True


presentToilets : Toilets -> Bool
presentToilets toilets =
    case toilets of
        FlushToilets ->
            True

        NonFlushToilets ->
            True

        NoToilets ->
            False


presentPicnicTables : PicnicTables -> Bool
presentPicnicTables picnicTables =
    case picnicTables of
        PicnicTables ->
            True

        NoPicnicTables ->
            False


presentBarbecues : Barbecues -> Bool
presentBarbecues barbecues =
    case barbecues of
        WoodBarbecues ->
            True

        WoodSuppliedBarbecues ->
            True

        WoodBringYourOwnBarbecues ->
            True

        GasElectricBarbecues ->
            True

        NoBarbecues ->
            False


presentShowers : Showers -> Bool
presentShowers showers =
    case showers of
        HotShowers ->
            True

        ColdShowers ->
            True

        NoShowers ->
            False


presentDrinkingWater : DrinkingWater -> Bool
presentDrinkingWater drinkingWater =
    case drinkingWater of
        DrinkingWater ->
            True

        NoDrinkingWater ->
            False


presentCaravans : Caravans -> Bool
presentCaravans caravans =
    case caravans of
        Caravans ->
            True

        NoCaravans ->
            False


presentTrailers : Trailers -> Bool
presentTrailers trailers =
    case trailers of
        Trailers ->
            True

        NoTrailers ->
            False


presentCars : Cars -> Bool
presentCars cars =
    case cars of
        Cars ->
            True

        NoCars ->
            False


descriptionToilets : Toilets -> String
descriptionToilets toilets =
    case toilets of
        FlushToilets ->
            "flush toilets"

        NonFlushToilets ->
            "non-flush toilets"

        NoToilets ->
            "toilets"


descriptionPicnicTables : PicnicTables -> String
descriptionPicnicTables picnicTables =
    "picnic tables"


descriptionBarbecues : Barbecues -> String
descriptionBarbecues barbecues =
    case barbecues of
        WoodBarbecues ->
            "wood BBQs"

        WoodSuppliedBarbecues ->
            "wood BBQs"

        WoodBringYourOwnBarbecues ->
            "wood BBQs"

        GasElectricBarbecues ->
            "gas/electric BBQs"

        NoBarbecues ->
            "BBQs"


descriptionShowers : Showers -> String
descriptionShowers showers =
    case showers of
        HotShowers ->
            "hot showers"

        ColdShowers ->
            "cold showers"

        NoShowers ->
            "showers"


descriptionDrinkingWater : DrinkingWater -> String
descriptionDrinkingWater drinkingWater =
    "drinking water"


descriptionCaravans : Caravans -> String
descriptionCaravans _ =
    "caravans"


descriptionTrailers : Trailers -> String
descriptionTrailers _ =
    "trailers"


descriptionCars : Cars -> String
descriptionCars _ =
    "car camping"


listItem : Bool -> (f -> Bool) -> (f -> String) -> Maybe f -> Maybe String
listItem p present description facility =
    case facility of
        Just facility ->
            if (present facility) == p then
                Just (description facility)
            else
                Nothing

        Nothing ->
            Nothing


facilitiesList : Bool -> Facilities -> List String
facilitiesList p facilities =
    App.ViewHelpers.values
        [ (listItem p presentToilets descriptionToilets facilities.toilets)
        , (listItem p presentPicnicTables descriptionPicnicTables facilities.picnicTables)
        , (listItem p presentBarbecues descriptionBarbecues facilities.barbecues)
        , (listItem p presentShowers descriptionShowers facilities.showers)
        , (listItem p presentDrinkingWater descriptionDrinkingWater facilities.drinkingWater)
        ]


accessList : Bool -> Access -> List String
accessList p access =
    App.ViewHelpers.values
        [ (listItem p presentCaravans descriptionCaravans access.caravans)
        , (listItem p presentTrailers descriptionTrailers access.trailers)
        , (listItem p presentCars descriptionCars access.cars)
        ]


capitalise : String -> String
capitalise text =
    (String.toUpper (String.left 1 text)) ++ (String.dropLeft 1 text)


joinWords : Maybe String -> String -> Maybe String -> Maybe String
joinWords a word b =
    case a of
        Just a ->
            case b of
                Just b ->
                    Just (a ++ " " ++ word ++ " " ++ b)

                Nothing ->
                    Just a

        Nothing ->
            case b of
                Just b ->
                    Just b

                Nothing ->
                    Nothing


haveAndHaveNotSentence : String -> Maybe String -> String -> String -> Maybe String -> Maybe String
haveAndHaveNotSentence haveWord have butWord notHaveWord notHave =
    Maybe.map (\text -> capitalise (text ++ "."))
        (joinWords
            (Maybe.map (\text -> haveWord ++ " " ++ text) have)
            butWord
            (Maybe.map (\text -> notHaveWord ++ " " ++ text) notHave)
        )


insertSeparatingWords : List String -> List String
insertSeparatingWords list =
    -- Hmmm.. Really not sure I've made this code even faintly intelligible
    List.reverse
        (case (List.reverse list) of
            [] ->
                []

            [ a0 ] ->
                [ a0 ]

            a0 :: l ->
                [ a0, " and " ] ++ (List.intersperse ", " l)
        )


listAsText : List String -> Maybe String
listAsText list =
    case list of
        [] ->
            Nothing

        list ->
            Just (List.foldr (++) "" (insertSeparatingWords list))
