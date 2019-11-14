module Main exposing (..)

import Browser exposing (..)
import Decoders.Json exposing (..)
import Element as E exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Input as Input
import Error exposing (buildErrorMessage)
import Html exposing (Html)
import Http
import RemoteData as RD exposing (WebData)
import Url exposing (Url)



---- TYPES ----
---- MODEL ----


type alias Model =
    { posts : WebData (List Poll)
    , errorMessage : Maybe String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { posts = RD.Loading, errorMessage = Nothing }, fetchPolls )



---- COMMANDS ----


fetchPolls : Cmd Msg
fetchPolls =
    Http.get
        { url = "http://localhost:56678/api/polls"
        , expect = Http.expectJson (RD.fromResult >> DataReceived) pollsDecoder
        }



---- UPDATE ----


type Msg
    = NoOp
    | DataReceived (WebData (List Poll))
    | UrlChange Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DataReceived res ->
            ( { model | posts = res }, Cmd.none )

        UrlChange _ ->
            ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )



---- VIEW ----
-- view : Model -> Document Msg


view : Model -> Html Msg
view model =
    currentView model



-- { title = "Voting App"
-- , body = [ currentView model ]
-- }


currentView : Model -> Html Msg
currentView model =
    E.layout [] <|
        E.column []
            [ E.row []
                [ E.text "Voting App" ]
            , E.row [] [ E.text "Built with Elm & .Net Core" ]
            , viewPollsOrError model
            ]


viewPollsOrError : Model -> Element Msg
viewPollsOrError model =
    case model.posts of
        RD.NotAsked ->
            E.text ""

        RD.Loading ->
            E.text "Loading..."

        RD.Failure httpError ->
            viewError (buildErrorMessage httpError)

        RD.Success polls ->
            viewPolls polls


viewError : String -> Element Msg
viewError err =
    E.row [] [ E.text err ]


viewPolls : List Poll -> Element Msg
viewPolls polls =
    E.column []
        [ E.row [] <|
            List.map
                viewPoll
                polls
        ]


viewPoll : Poll -> Element Msg
viewPoll poll =
    E.row [] <|
        [ E.row [] [ E.text poll.description ]
        ]
            ++ List.map viewOption poll.options


viewOption : Option -> Element Msg
viewOption option =
    E.row [] [ E.text option.optionText ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }



-- main : Program Flags Model Msg
-- main =
--     Browser.application
--         { init = init
--         , view = view
--         , update = update
--         , subscriptions = always Sub.none
--         , onUrlRequest = NoOp
--         , onUrlChange = UrlChange
--         }
