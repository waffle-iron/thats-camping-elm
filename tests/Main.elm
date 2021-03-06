port module Main exposing (..)

import Test exposing (..)
import Test.Runner.Node
import Json.Encode exposing (Value)
import App.TestsDecoder
import TestsLocation
import Libs.SimpleFormat.Tests
import Pages.Campsite.Tests


main : Test.Runner.Node.TestProgram
main =
    Test.Runner.Node.run emit all


all : Test
all =
    describe "Test Suite"
        [ App.TestsDecoder.all
        , TestsLocation.all
        , Libs.SimpleFormat.Tests.all
        , Pages.Campsite.Tests.all
        ]


port emit : ( String, Value ) -> Cmd msg
