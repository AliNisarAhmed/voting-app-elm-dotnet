module Page.PollDetails exposing (..)

import Browser exposing (..)
import Browser.Navigation as Nav
import Decoders.Json exposing (..)
import Element as E exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Input as Input
import Element.Keyed as Keyed
import Error exposing (buildErrorMessage, viewError)
import Html exposing (Html)
import Html.Events exposing (on)
import Http
import Json.Decode as Decode
import Json.Encode as Encode exposing (Value)
import RemoteData as RD exposing (WebData)
import Route
import Url exposing (Url)



---- TYPES ----


type Msg
    = PollDetailsReceived (WebData PollDetails)
    | NoOp



---- MODEL ----


type alias Model =
    { pollDetails : WebData PollDetails }


init : Int -> ( Model, Cmd Msg )
init pollId =
    ( { pollDetails = RD.NotAsked }
    , getPollDetails pollId
    )



---- COMMANDS ----


getPollDetails : Int -> Cmd Msg
getPollDetails pollId =
    Http.get
        { url = "http://localhost:56678/api/polls/" ++ String.fromInt pollId
        , expect = Http.expectJson (RD.fromResult >> PollDetailsReceived) pollDetailsDecoder
        }



---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PollDetailsReceived res ->
            ( { model | pollDetails = res }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )



---- VIEWS ----


view : Model -> Html Msg
view model =
    let
        content =
            case model.pollDetails of
                RD.NotAsked ->
                    E.text ""

                RD.Failure err ->
                    viewError (buildErrorMessage err)

                RD.Loading ->
                    E.text "Loading..."

                RD.Success pollDetails ->
                    viewPollDetails pollDetails
    in
    E.layout [] <|
        E.column []
            [ E.row [] [ E.text "Poll Details Page" ]
            , content
            ]


viewPollDetails : PollDetails -> Element Msg
viewPollDetails pollDetails =
    E.column []
        [ E.row [] <| [ E.text <| "Name: " ++ pollDetails.description ]
        , E.row [] <| [ E.text <| "Created by: " ++ pollDetails.creator.firstName ++ " " ++ pollDetails.creator.lastName ]
        ]
