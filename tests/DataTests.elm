module DataTests exposing (..)

import Test exposing (..)
import Expect
import Fuzz exposing (list, int, tuple, string)
import String
import Location exposing (Location)
import Json.Decode
import Data


all : Test
all =
    describe "Data"
        [ describe "locationDecoder"
            [ test "example" <|
                \() ->
                    Expect.equal (Ok { latitude = -33, longitude = 150 }) (Json.Decode.decodeString Data.locationDecoder """{ "latitude": -33, "longitude": 150 }""")
            ]
        ]
