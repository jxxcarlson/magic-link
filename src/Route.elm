module Route exposing (Route(..), decode, encode)

import Url exposing (Url)
import Url.Builder
import Url.Parser


type Route
    = HomepageRoute
    | TermsOfServiceRoute
    | Notes
    | SignInRoute
    | AdminRoute


decode : Url -> Route
decode url =
    Url.Parser.oneOf
        [ Url.Parser.top |> Url.Parser.map HomepageRoute
        , Url.Parser.s "admin" |> Url.Parser.map AdminRoute
        , Url.Parser.s "notes" |> Url.Parser.map Notes
        , Url.Parser.s "signin" |> Url.Parser.map SignInRoute
        ]
        |> (\a -> Url.Parser.parse a url |> Maybe.withDefault HomepageRoute)


encode : Route -> String
encode route =
    Url.Builder.absolute
        (case route of
            HomepageRoute ->
                []

            TermsOfServiceRoute ->
                [ "terms" ]

            Notes ->
                [ "notes" ]

            SignInRoute ->
                [ "signin" ]

            AdminRoute ->
                [ "admin" ]
        )
        (case route of
            HomepageRoute ->
                []

            TermsOfServiceRoute ->
                []

            Notes ->
                []

            SignInRoute ->
                []

            AdminRoute ->
                []
        )
