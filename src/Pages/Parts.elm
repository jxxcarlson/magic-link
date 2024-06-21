module Pages.Parts exposing (generic)

import Element exposing (Element)
import Element.Background
import Element.Font
import Pages.SignIn
import Route exposing (Route(..))
import Theme
import Types
import View.Color


generic : Types.LoadedModel -> (Types.LoadedModel -> Element Types.FrontendMsg) -> Element Types.FrontendMsg
generic model view =
    Element.column
        [ Element.width Element.fill, Element.height Element.fill ]
        [ Pages.SignIn.headerView model model.route { window = model.window, isCompact = True }
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
