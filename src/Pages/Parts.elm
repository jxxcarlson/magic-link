module Pages.Parts exposing
    ( generic
    , linkStyle
    )

import Element exposing (Element)
import Element.Background
import Element.Font
import Predicate
import Route exposing (Route(..))
import Theme
import Types
import View.Button
import View.Color


generic : Types.LoadedModel -> (Types.LoadedModel -> Element Types.FrontendMsg) -> Element Types.FrontendMsg
generic model view =
    Element.column
        [ Element.width Element.fill, Element.height Element.fill ]
        [ header model model.route { window = model.window, isCompact = True }
        , Element.column
            (Element.padding 20
                :: Element.scrollbarY
                :: Element.height (Element.px <| model.window.height - 95)
                :: Theme.contentAttributes
            )
            [ view model
            ]
        , footer model.route model
        ]


header : Types.LoadedModel -> Route -> { window : { width : Int, height : Int }, isCompact : Bool } -> Element Types.FrontendMsg
header model route config =
    Element.el
        [ Element.Background.color View.Color.blue
        , Element.paddingXY 24 16
        , Element.width (Element.px config.window.width)
        , Element.alignTop
        ]
        (Element.wrappedRow
            ([ Element.spacing 24
             , Element.Background.color View.Color.blue
             , Element.Font.color (Element.rgb 1 1 1)
             ]
                ++ Theme.contentAttributes
            )
            [ Element.link
                (linkStyle route HomepageRoute)
                { url = Route.encode HomepageRoute, label = Element.text "Magic Link Authentication" }
            , if Predicate.isAdmin model.currentUserData then
                Element.link
                    (linkStyle route AdminRoute)
                    { url = Route.encode AdminRoute, label = Element.text "Admin" }

              else
                Element.none
            , Element.link
                (linkStyle route Notes)
                { url = Route.encode Notes, label = Element.text "Notes" }
            , case model.currentUserData of
                Just currentUserData_ ->
                    View.Button.signOut currentUserData_.username

                Nothing ->
                    Element.link
                        (linkStyle route SignInRoute)
                        { url = Route.encode SignInRoute
                        , label =
                            Element.el []
                                (case model.currentUserData of
                                    Just currentUserData_ ->
                                        View.Button.signOut currentUserData_.username

                                    Nothing ->
                                        Element.text "Sign in"
                                )
                        }
            ]
        )


linkStyle : Route -> Route -> List (Element.Attribute msg)
linkStyle currentRoute route =
    if currentRoute == route then
        [ Element.Font.underline, Element.Font.color View.Color.yellow ]

    else
        [ Element.Font.color View.Color.white ]


footer : Route -> Types.LoadedModel -> Element msg
footer route model =
    Element.el
        [ Element.Background.color View.Color.blue
        , Element.paddingXY 24 16
        , Element.width Element.fill
        , Element.alignBottom
        ]
        (Element.wrappedRow
            ([ Element.spacing 32
             , Element.Background.color View.Color.blue
             , Element.Font.color (Element.rgb 1 1 1)
             ]
                ++ Theme.contentAttributes
            )
            [ Element.el [ Element.Font.color (Element.rgb 1 1 1) ] (Element.text model.message)
            ]
        )
