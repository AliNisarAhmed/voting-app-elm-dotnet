module Main exposing (..)

import Browser exposing (..)
import Browser.Navigation as Nav
import Html exposing (..)
import Page.ListPolls as ListPolls
import Page.NewPoll as NewPoll
import Route exposing (Route)
import Url exposing (Url)



---- TYPES ----


type Page
    = NotFoundPage
    | ListPollsPage ListPolls.Model
    | NewPollPage NewPoll.Model


type Msg
    = ListPollsPageMsg ListPolls.Msg
    | NewPollPageMsg NewPoll.Msg
    | LinkClicked UrlRequest
    | UrlChanged Url



---- MODEL ----


type alias Model =
    { route : Route
    , page : Page
    , navKey : Nav.Key
    }


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        model =
            { route = Route.parseUrl url
            , page = NotFoundPage
            , navKey = navKey
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

        ( _, _ ) ->
            ( model, Cmd.none )



---- VIEW ----


view : Model -> Document Msg
view model =
    { title = "Vote App"
    , body = [ currentView model ]
    }


currentView : Model -> Html Msg
currentView model =
    case model.page of
        ListPollsPage pageModel ->
            ListPolls.view pageModel
                |> Html.map ListPollsPageMsg

        NewPollPage pageModel ->
            Html.map NewPollPageMsg <| NewPoll.view pageModel

        _ ->
            notFoundView


notFoundView : Html Msg
notFoundView =
    h3 [] [ text "Oops! The page you requested was not found!" ]
