module Route exposing (Route(..), parseUrl, pushUrl)

import Browser.Navigation as Nav
import Url exposing (Url)
import Url.Parser exposing (..)


type Route
    = NotFound
    | LandingPage
    | Poll Int


pushUrl : Route -> Nav.Key -> Cmd msg
pushUrl route navKey =
    routeToString route
        |> Nav.pushUrl navKey


parseUrl : Url -> Route
parseUrl url =
    case parse matchRoute url of
        Just route ->
            route

        Nothing ->
            NotFound


matchRoute : Parser (Route -> a) a
matchRoute =
    oneOf
        [ map LandingPage top
        , map Poll (s "poll" </> int)
        ]


routeToString : Route -> String
routeToString route =
    case route of
        NotFound ->
            "/not-found"

        LandingPage ->
            "/"

        Poll id ->
            "/poll/" ++ String.fromInt id
