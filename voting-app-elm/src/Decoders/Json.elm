module Decoders.Json exposing (..)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (..)
import Json.Encode as Encode


type alias Vote =
    { pollId : Int
    , clientId : Int
    , optionId : Int
    }


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


type alias PollWithVoteCount =
    { id : Int
    , description : String
    , clientId : Int
    , votes : Int
    }


type alias Client =
    { id : Int
    , firstName : String
    , lastName : String
    , email : String
    }


type alias OptionWithVote =
    { votes : Int
    , id : Int
    , pollId : Int
    , optionText : String
    }


type alias PollDetails =
    { options : List OptionWithVote
    , creator : Client
    , id : Int
    , description : String
    , clientId : Int
    }


encodeVote : Vote -> Encode.Value
encodeVote v =
    Encode.object
        [ ( "pollId", Encode.int v.pollId )
        , ( "clientId", Encode.int v.clientId )
        , ( "optionId", Encode.int v.optionId )
        ]


pollDetailsDecoder : Decode.Decoder PollDetails
pollDetailsDecoder =
    Decode.succeed PollDetails
        |> required "Options" (Decode.list optionWithVoteDecoder)
        |> required "Creator" clientDecoder
        |> required "Id" Decode.int
        |> required "Description" Decode.string
        |> required "ClientId" Decode.int


optionWithVoteDecoder : Decode.Decoder OptionWithVote
optionWithVoteDecoder =
    Decode.succeed OptionWithVote
        |> required "Votes" Decode.int
        |> required "Id" Decode.int
        |> optional "PollId" Decode.int -1
        |> required "OptionText" Decode.string


clientDecoder : Decode.Decoder Client
clientDecoder =
    Decode.succeed Client
        |> required "Id" Decode.int
        |> required "FirstName" Decode.string
        |> required "LastName" Decode.string
        |> required "Email" Decode.string


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


pollWithVoteCountDecoder : Decode.Decoder PollWithVoteCount
pollWithVoteCountDecoder =
    Decode.succeed PollWithVoteCount
        |> required "id" Decode.int
        |> required "Description" Decode.string
        |> required "clientId" Decode.int
        |> required "votes" Decode.int


pollsWithVoteCountDecoder : Decode.Decoder (List PollWithVoteCount)
pollsWithVoteCountDecoder =
    Decode.list pollWithVoteCountDecoder
