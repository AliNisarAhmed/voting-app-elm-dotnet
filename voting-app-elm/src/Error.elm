module Error exposing (..)

import Element exposing (Element, row, text)
import Http


buildErrorMessage : Http.Error -> String
buildErrorMessage httpError =
    case httpError of
        Http.BadUrl m ->
            m

        Http.Timeout ->
            "Timeout"

        Http.NetworkError ->
            "Network Unavailable"

        Http.BadStatus statusCode ->
            "Request failed with code: " ++ String.fromInt statusCode

        Http.BadBody m ->
            m


viewError : String -> Element msg
viewError err =
    row [] [ text err ]
