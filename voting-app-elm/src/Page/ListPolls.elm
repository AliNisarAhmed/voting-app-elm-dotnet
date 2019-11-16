module Page.ListPolls exposing (..)

import Browser exposing (..)
import Browser.Navigation as Nav
import Decoders.Json exposing (..)
import Element as E exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Input as Input
import Error exposing (buildErrorMessage)
import Html exposing (Html)
import Http
import RemoteData as RD exposing (WebData)
import Url exposing (Url)



---- TYPES ----


type Msg
    = NoOp
    | DataReceived (WebData (List PollWithVoteCount))
    | SearchPolls String
    | OnPollClick Int Nav.Key



---- MODEL ----


type alias Model =
    { polls : WebData (List PollWithVoteCount)
    , errorMessage : Maybe String
    , searchTerm : String
    , navKey : Nav.Key
    }


init : Nav.Key -> ( Model, Cmd Msg )
init navKey =
    ( { polls = RD.Loading
      , errorMessage = Nothing
      , searchTerm = ""
      , navKey = navKey
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


changeRoute : Int -> Nav.Key -> Cmd Msg
changeRoute pollId navKey =
    Nav.pushUrl navKey ("/poll/" ++ String.fromInt pollId)



---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DataReceived res ->
            ( { model | polls = res }, Cmd.none )

        SearchPolls searchTerm ->
            ( { model | searchTerm = searchTerm }, Cmd.none )

        OnPollClick pollId navKey ->
            ( model, changeRoute pollId navKey )

        NoOp ->
            ( model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    currentView model


currentView : Model -> Html Msg
currentView model =
    E.layout [] <|
        E.column [ E.width E.fill, E.centerX, E.height E.fill ]
            [ navbar model
            , viewPollsOrError model
            ]


navbar : Model -> Element Msg
navbar model =
    E.row [ E.width E.fill, E.alignTop ]
        [ E.el [ E.alignLeft ] <| E.text "YOU VOTE!"
        , E.el [ E.alignRight, E.width (E.px 300) ] <| searchBar model.searchTerm
        ]


searchBar : String -> Element Msg
searchBar searchTerm =
    E.el [] <|
        Input.text []
            { onChange = SearchPolls
            , placeholder = Just <| Input.placeholder [] <| E.text "Search..."
            , text = searchTerm
            , label = Input.labelHidden "Search"
            }


viewPollsOrError : Model -> Element Msg
viewPollsOrError model =
    case model.polls of
        RD.NotAsked ->
            E.text ""

        RD.Loading ->
            E.text "Loading..."

        RD.Failure httpError ->
            viewError (buildErrorMessage httpError)

        RD.Success pollList ->
            viewPolls model.navKey <|
                List.filter
                    (\p ->
                        String.contains
                            (String.toLower model.searchTerm)
                            (String.toLower p.description)
                    )
                    pollList


viewError : String -> Element Msg
viewError err =
    E.row [] [ E.text err ]


viewPolls : Nav.Key -> List PollWithVoteCount -> Element Msg
viewPolls navKey polls =
    E.column [ E.width (E.px 1200), E.height E.fill, E.height E.fill, E.centerX ] <|
        [ E.wrappedRow [] <|
            List.map (viewPoll navKey) polls
        ]


viewPoll : Nav.Key -> PollWithVoteCount -> Element Msg
viewPoll navKey poll =
    E.row
        [ E.paddingXY 0 30
        , Border.color <| E.rgb255 0 0 0
        , Border.solid
        , Border.width 1
        , Border.rounded 10
        , Events.onClick <| OnPollClick poll.id navKey
        ]
    <|
        [ E.column [ E.paddingXY 50 50 ]
            [ E.row [] [ E.text poll.description ]
            , E.row [] [ viewVoteCount poll.votes ]
            ]
        ]


viewVoteCount : Int -> Element Msg
viewVoteCount voteCount =
    E.row [] [ E.text <| "Votes: " ++ String.fromInt voteCount ]
