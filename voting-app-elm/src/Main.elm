module Main exposing (..)

import Browser exposing (..)
import Browser.Navigation as Nav
import Color exposing (..)
import Element as E exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html exposing (..)
import Page.ListPolls as ListPolls
import Page.NewPoll as NewPoll
import Page.PollDetails as PollDetails
import Route exposing (Route)
import Url exposing (Url)



---- TYPES ----


type Page
    = NotFoundPage
    | ListPollsPage ListPolls.Model
    | NewPollPage NewPoll.Model
    | PollDetailsPage PollDetails.Model


type Msg
    = ListPollsPageMsg ListPolls.Msg
    | NewPollPageMsg NewPoll.Msg
    | PollDetailsPageMsg PollDetails.Msg
    | LinkClicked UrlRequest
    | UrlChanged Url
    | Search String



---- MODEL ----


type alias Model =
    { route : Route
    , page : Page
    , navKey : Nav.Key
    , searchTerm : String
    }


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        model =
            { route = Route.parseUrl url
            , page = NotFoundPage
            , navKey = navKey
            , searchTerm = ""
            }
    in
    initCurrentPage ( model, Cmd.none )


initCurrentPage : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
initCurrentPage ( model, existingCmds ) =
    let
        ( currentPage, mappedPageCmds ) =
            case model.route of
                Route.LandingPage ->
                    let
                        ( pageModel, pageCmds ) =
                            ListPolls.init
                    in
                    ( ListPollsPage pageModel, Cmd.map ListPollsPageMsg pageCmds )

                Route.NewPollPage ->
                    let
                        ( pageModel, pageCmds ) =
                            NewPoll.init model.navKey
                    in
                    ( NewPollPage pageModel, Cmd.map NewPollPageMsg pageCmds )

                Route.PollDetails pollId ->
                    let
                        ( pageModel, pageCmds ) =
                            PollDetails.init pollId
                    in
                    ( PollDetailsPage pageModel, Cmd.map PollDetailsPageMsg pageCmds )

                _ ->
                    ( NotFoundPage, Cmd.none )
    in
    ( { model | page = currentPage }
    , Cmd.batch [ existingCmds, mappedPageCmds ]
    )



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }



---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( ListPollsPageMsg pageMsg, ListPollsPage pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    ListPolls.update pageMsg pageModel
            in
            ( { model | page = ListPollsPage updatedPageModel }
            , Cmd.map ListPollsPageMsg updatedCmd
            )

        ( NewPollPageMsg pageMsg, NewPollPage pageModel ) ->
            let
                ( updatedPageModel, updatedCmds ) =
                    NewPoll.update pageMsg pageModel
            in
            ( { model | page = NewPollPage updatedPageModel }
            , Cmd.map NewPollPageMsg updatedCmds
            )

        ( PollDetailsPageMsg pageMsg, PollDetailsPage pageModel ) ->
            let
                ( updatedPageModel, updatedCmds ) =
                    PollDetails.update pageMsg pageModel
            in
            ( { model | page = PollDetailsPage updatedPageModel }
            , Cmd.map PollDetailsPageMsg updatedCmds
            )

        ( LinkClicked urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl model.navKey (Url.toString url)
                    )

                Browser.External url ->
                    ( model
                    , Nav.load url
                    )

        ( UrlChanged url, _ ) ->
            let
                newRoute =
                    Route.parseUrl url
            in
            ( { model | route = newRoute }
            , Cmd.none
            )
                |> initCurrentPage

        ( Search term, ListPollsPage pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    ListPolls.update (ListPolls.SearchPolls term) pageModel
            in
            ( { model | page = ListPollsPage updatedPageModel, searchTerm = term }
            , Cmd.map ListPollsPageMsg updatedCmd
            )

        ( _, _ ) ->
            ( model, Cmd.none )



---- VIEW ----


view : Model -> Document Msg
view model =
    { title = "Vote App"
    , body =
        [ E.layout [ E.height E.fill ] <|
            E.column [ E.width E.fill, E.height E.fill ]
                [ navbar model
                , E.row [ E.height E.fill, E.paddingXY 0 50 ] [ currentView model ]
                ]
        ]
    }


currentView : Model -> Element Msg
currentView model =
    case model.page of
        ListPollsPage pageModel ->
            ListPolls.view pageModel
                |> E.map ListPollsPageMsg

        NewPollPage pageModel ->
            E.map NewPollPageMsg <| NewPoll.view pageModel

        PollDetailsPage pageModel ->
            E.map PollDetailsPageMsg <| PollDetails.view pageModel

        _ ->
            notFoundView


navbar : Model -> Element Msg
navbar model =
    E.row
        [ E.width E.fill
        , E.height E.fill
        , E.alignTop
        , E.spacingXY 20 0
        , Border.color Color.darkGreen
        , Border.width 2
        , Background.color Color.green
        , E.spacingXY 10 0
        , Border.shadow
            { offset = ( 0, 0.2 )
            , size = 0.5
            , blur = 5
            , color = Color.darkCharcoal
            }
        ]
        [ E.el [ E.alignLeft ] <|
            E.link []
                { url = "/"
                , label = E.text "You Vote!"
                }
        , searchBar model
        , E.link
            [ E.alignRight
            , E.paddingEach { top = 0, right = 20, bottom = 0, left = 0 }
            , Border.width 1
            , Border.rounded 10
            , Border.color <| E.rgb255 23 230 23
            , E.padding 20
            ]
            { url = "/poll/new"
            , label = E.text "Create New Poll"
            }
        ]


searchBar : Model -> Element Msg
searchBar model =
    let
        bar =
            E.el [ E.width (E.px 300), E.centerX ] <|
                Input.text []
                    { onChange = Search
                    , placeholder = Just <| Input.placeholder [] <| E.text "Search..."
                    , text = model.searchTerm
                    , label = Input.labelHidden "Search"
                    }
    in
    case model.page of
        ListPollsPage _ ->
            bar

        _ ->
            E.none


notFoundView : Element Msg
notFoundView =
    E.el [ Font.bold ] <|
        E.text "Oops! The page you requested was not found!"
