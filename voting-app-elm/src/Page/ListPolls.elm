module Page.ListPolls exposing (..)

import Browser exposing (..)
import Browser.Navigation as Nav
import Color
import Decoders.Json exposing (..)
import Element as E exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Input as Input
import Error exposing (buildErrorMessage, viewError)
import Html exposing (Html)
import Http
import RemoteData as RD exposing (WebData)
import Url exposing (Url)



---- TYPES ----


type Msg
    = NoOp
    | DataReceived (WebData (List PollWithVoteCount))
    | SearchPolls String



---- MODEL ----


type alias Model =
    { polls : WebData (List PollWithVoteCount)
    , errorMessage : Maybe String
    , searchTerm : String
    }


init : ( Model, Cmd Msg )
init =
    ( { polls = RD.Loading
      , errorMessage = Nothing
      , searchTerm = ""
      }
    , fetchPolls
    )



---- COMMANDS ----


fetchPolls : Cmd Msg
fetchPolls =
    Http.get
        { url = "http://localhost:56678/api/polls"
        , expect = Http.expectJson (RD.fromResult >> DataReceived) pollsWithVoteCountDecoder
        }



---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DataReceived res ->
            ( { model | polls = res }, Cmd.none )

        SearchPolls searchTerm ->
            ( { model | searchTerm = searchTerm }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )



---- VIEW ----


view : Model -> Element Msg
view model =
    currentView model


currentView : Model -> Element Msg
currentView model =
    E.column [ E.width E.fill, E.centerX, E.height E.fill ]
        [ viewPollsOrError model ]


viewPollsOrError : Model -> Element Msg
viewPollsOrError model =
    case model.polls of
        RD.NotAsked ->
            E.text ""

        RD.Loading ->
            E.text "Loading..."

        RD.Failure httpError ->
            viewError (Just <| buildErrorMessage httpError)

        RD.Success pollList ->
            viewPolls <|
                List.filter
                    (\p ->
                        String.contains
                            (String.toLower model.searchTerm)
                            (String.toLower p.description)
                    )
                    pollList


viewPolls : List PollWithVoteCount -> Element Msg
viewPolls polls =
    E.column
        [ E.width E.fill
        , E.height E.fill
        , E.centerX
        , E.paddingXY 40 0
        ]
    <|
        [ E.wrappedRow [] <|
            List.map viewPoll polls
        ]


viewPoll : PollWithVoteCount -> Element Msg
viewPoll poll =
    E.link
        [ E.spacingXY 10 0
        , E.width E.fill
        ]
        { url = "/poll/" ++ String.fromInt poll.id
        , label =
            E.row
                [ E.paddingXY 0 30
                , Border.color <| E.rgb255 0 0 0
                , Border.solid
                , Border.width 1
                , Border.rounded 10
                , E.spacingXY 10 0
                ]
            <|
                [ E.column [ E.paddingXY 50 50 ]
                    [ E.row [] [ E.text poll.description ]
                    , E.row [] [ viewVoteCount poll.votes ]
                    ]
                ]
        }


viewVoteCount : Int -> Element Msg
viewVoteCount voteCount =
    E.row [] [ E.text <| "Votes: " ++ String.fromInt voteCount ]
