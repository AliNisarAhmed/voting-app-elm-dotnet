module Page.NewPoll exposing (..)

import Browser exposing (..)
import Browser.Navigation as Nav
import Decoders.Json exposing (..)
import Element as E exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Input as Input
import Element.Keyed as Keyed
import Error exposing (buildErrorMessage)
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
    = UpdatePollDescription String
    | UpdateCurrentOption String
    | AddCurrentOption
    | RemoveOption String
    | SubmitPoll
    | PollSubmitted (Result Http.Error ())


type alias PollOption =
    String



---- MODEL ----


type alias Model =
    { description : String
    , pollOptions : List PollOption
    , currentOption : String
    , navKey : Nav.Key
    , clientId : Int
    }


init : Nav.Key -> ( Model, Cmd Msg )
init navKey =
    ( { description = ""
      , pollOptions = []
      , currentOption = ""
      , navKey = navKey
      , clientId = 1
      }
    , Cmd.none
    )



---- COMMANDS ----


submitPoll : Model -> Cmd Msg
submitPoll model =
    Http.post
        { url = "http://localhost:56678/api/polls/new"
        , body = Http.jsonBody (pollEncoder model)
        , expect = Http.expectWhatever PollSubmitted
        }


pollEncoder : Model -> Value
pollEncoder model =
    Encode.object
        [ ( "description", Encode.string model.description )
        , ( "options", Encode.list Encode.string model.pollOptions )
        , ( "clientId", Encode.int model.clientId )
        ]



---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateCurrentOption text ->
            ( { model | currentOption = text }
            , Cmd.none
            )

        UpdatePollDescription text ->
            ( { model | description = text }
            , Cmd.none
            )

        AddCurrentOption ->
            ( { model
                | pollOptions = model.pollOptions ++ [ model.currentOption ]
                , currentOption = ""
              }
            , Cmd.none
            )

        RemoveOption opt ->
            ( { model | pollOptions = List.filter ((/=) opt) model.pollOptions }
            , Cmd.none
            )

        SubmitPoll ->
            ( model, submitPoll model )

        PollSubmitted (Ok _) ->
            ( model, Route.pushUrl Route.LandingPage model.navKey )

        PollSubmitted (Err err) ->
            ( model, Cmd.none )



---- VIEWS ----


view : Model -> Element Msg
view model =
    E.column []
        [ E.row [] [ E.text "Create a new poll" ]
        , E.row []
            [ Input.text []
                { onChange = UpdatePollDescription
                , text = model.description
                , placeholder = Just <| Input.placeholder [] <| E.text "Poll description"
                , label = Input.labelAbove [] <| E.text "Description"
                }
            ]
        , E.column [] <| viewOptions model.pollOptions
        , E.row []
            [ Input.text
                [ onEnter AddCurrentOption
                ]
                { onChange = UpdateCurrentOption
                , text = model.currentOption
                , placeholder = Just <| Input.placeholder [] <| E.text "Add an option"
                , label = Input.labelBelow [] <| E.text "Add an option"
                }
            ]
        , E.row []
            [ Input.button []
                { onPress = Just SubmitPoll
                , label = E.text "Submit"
                }
            ]
        ]


viewOptions : List PollOption -> List (Element Msg)
viewOptions options =
    case options of
        [] ->
            [ E.text "No options yet, add an option below" ]

        _ ->
            List.map viewOption options


viewOption : PollOption -> Element Msg
viewOption opt =
    E.row [] [ E.text opt, E.el [ Events.onClick <| RemoveOption opt ] <| E.text " X" ]


onEnter : msg -> E.Attribute msg
onEnter msg =
    E.htmlAttribute
        (on "keyup"
            (Decode.field "key" Decode.string
                |> Decode.andThen
                    (\key ->
                        if key == "Enter" then
                            Decode.succeed msg

                        else
                            Decode.fail "Not the enter key"
                    )
            )
        )
