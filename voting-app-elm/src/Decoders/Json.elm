module Decoders.Json exposing (..)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (..)


type alias Option =
    { id : Int
    , pollId : Int
    , optionText : String
    }


type alias Poll =
    { id : Int
    , description : String
    , clientId : Int
    , options : List Option
    }


optionDecoder : Decode.Decoder Option
optionDecoder =
    Decode.succeed Option
        |> optional "Id" Decode.int -1
        |> required "PollId" Decode.int
        |> required "OptionText" Decode.string


optionsDecoder : Decode.Decoder (List Option)
optionsDecoder =
    Decode.list optionDecoder


pollDecoder : Decode.Decoder Poll
pollDecoder =
    Decode.succeed Poll
        |> optional "Id" Decode.int -1
        |> required "Description" Decode.string
        |> required "ClientId" Decode.int
        |> required "Options" optionsDecoder


pollsDecoder : Decode.Decoder (List Poll)
pollsDecoder =
    Decode.list pollDecoder
