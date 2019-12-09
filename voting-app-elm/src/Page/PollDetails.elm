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
import Toasty as Toasty
import ToastyConfig exposing (toastyConfig)
import Url exposing (Url)



---- TYPES ----


type Msg
    = PollDetailsReceived (WebData PollDetails)
    | ToggleCanVote
    | ChooseOption Int
    | SubmitVote
    | VoteSubmitted (Result Http.Error ())
    | ToastyMsg (Toasty.Msg String)
    | NoOp



---- MODEL ----


type alias Model =
    { pollDetails : WebData PollDetails
    , canVote : Bool
    , selectedOption : Int
    , pollId : Int
    , errorMessage : Maybe String
    , toasties : Toasty.Stack String
    }


init : Int -> ( Model, Cmd Msg )
init pollId =
    ( { pollDetails = RD.NotAsked
      , canVote = False
      , selectedOption = -1
      , pollId = pollId
      , errorMessage = Nothing
      , toasties = Toasty.initialState
      }
    , getPollDetails pollId
    )



---- COMMANDS ----


getPollDetails : Int -> Cmd Msg
getPollDetails pollId =
    Http.get
        { url = "http://localhost:56678/api/polls/" ++ String.fromInt pollId
        , expect = Http.expectJson (RD.fromResult >> PollDetailsReceived) pollDetailsDecoder
        }


submitVoteRequest : Model -> Cmd Msg
submitVoteRequest m =
    let
        pollId =
            String.fromInt <| RD.unwrap -1 .id m.pollDetails

        vote =
            { pollId = m.pollId
            , clientId = RD.unwrap -1 .clientId m.pollDetails
            , optionId = m.selectedOption
            }
    in
    Http.post
        { url = "http://localhost:56678/api/polls/" ++ pollId ++ "/vote"
        , body = Http.jsonBody <| encodeVote vote
        , expect = Http.expectWhatever VoteSubmitted
        }



---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PollDetailsReceived res ->
            ( { model | pollDetails = res }, Cmd.none )

        ToggleCanVote ->
            ( { model | canVote = not model.canVote }
            , Cmd.none
            )

        ChooseOption opt ->
            ( { model | selectedOption = opt }, Cmd.none )

        SubmitVote ->
            ( model, submitVoteRequest model )

        VoteSubmitted (Ok _) ->
            init model.pollId

        VoteSubmitted (Err e) ->
            ( model, Cmd.none )
                |> Toasty.addToast toastyConfig ToastyMsg (buildErrorMessage e)

        ToastyMsg subMsg ->
            Toasty.update toastyConfig ToastyMsg subMsg model

        NoOp ->
            ( model, Cmd.none )



---- VIEWS ----


view : Model -> Element Msg
view model =
    let
        content =
            case model.pollDetails of
                RD.NotAsked ->
                    E.text ""

                RD.Failure err ->
                    viewError (Just <| buildErrorMessage err)

                RD.Loading ->
                    E.text "Loading..."

                RD.Success pollDetails ->
                    viewPollDetails pollDetails model.selectedOption model.canVote
    in
    E.column []
        [ E.row [] [ E.text "Poll Details Page" ]
        , content
        , voteButton model.canVote
        , cancelButton model.canVote
        , E.html <| Toasty.view toastyConfig renderToast ToastyMsg model.toasties
        ]


renderToast : String -> Html Msg
renderToast toast =
    Html.div [] [ Html.text toast ]


voteButton : Bool -> Element Msg
voteButton canVote =
    if canVote then
        Input.button []
            { onPress = Just SubmitVote
            , label = E.text "Submit Vote"
            }

    else
        Input.button []
            { onPress = Just ToggleCanVote
            , label = E.text "Click To Vote"
            }


cancelButton : Bool -> Element Msg
cancelButton canVote =
    if canVote then
        Input.button []
            { onPress = Just ToggleCanVote
            , label = E.text "Cancel"
            }

    else
        E.text ""


viewPollDetails : PollDetails -> Int -> Bool -> Element Msg
viewPollDetails pollDetails selectedOption canVote =
    E.column []
        [ E.row [] [ E.text <| "Name: " ++ pollDetails.description ]
        , E.row [] [ E.text <| "Created by: " ++ pollDetails.creator.firstName ++ " " ++ pollDetails.creator.lastName ]
        , E.column [] <|
            if canVote then
                [ viewVotingButtons selectedOption pollDetails.options ]

            else
                List.map viewOption pollDetails.options
        ]


viewOption : OptionWithVote -> Element Msg
viewOption opv =
    E.column []
        [ E.row []
            [ E.el [] <| E.text opv.optionText
            , E.el [] <| E.text <| " - Votes: " ++ String.fromInt opv.votes
            ]
        ]


viewVotingButtons : Int -> List OptionWithVote -> Element Msg
viewVotingButtons s ops =
    E.column []
        [ E.row []
            [ Input.radio [ E.padding 10, E.spacing 20 ]
                { onChange = ChooseOption
                , selected = Just s
                , label = Input.labelRight [] <| E.text "Vote"
                , options = List.map (\o -> Input.option o.id (E.text o.optionText)) ops
                }
            ]
        ]
