module View.Main exposing (view)

import Browser
import Element exposing (Element)
import Element.Background
import Element.Font
import MagicLink.Types
import Pages.Admin
import Pages.Home
import Pages.Notes
import Pages.SignIn
import Pages.TermsOfService
import Route exposing (Route(..))
import Types exposing (FrontendModel(..), FrontendMsg, LoadedModel)
import User
import View.Color
import View.Common
import View.MarkdownThemed as MarkdownThemed
import View.Theme as Theme


noFocus : Element.FocusStyle
noFocus =
    { borderColor = Nothing
    , backgroundColor = Nothing
    , shadow = Nothing
    }


view : FrontendModel -> Browser.Document FrontendMsg
view model =
    { title = "Lamdera Kitchen Sink"
    , body =
        [ Theme.css
        , Element.layoutWith { options = [ Element.focusStyle noFocus ] }
            [ Element.width Element.fill
            , Element.Font.color MarkdownThemed.lightTheme.defaultText
            , Element.Font.size 16
            , Element.Font.medium
            ]
            (case model of
                Loading _ ->
                    Element.column [ Element.width Element.fill, Element.padding 20 ]
                        [ "Loading..."
                            |> Element.text
                            |> Element.el [ Element.centerX ]
                        ]

                Loaded loaded ->
                    loadedView loaded
            )
        ]
    }


loadedView : Types.LoadedModel -> Element FrontendMsg
loadedView model =
    case model.route of
        HomepageRoute ->
            generic model Pages.Home.view

        TermsOfServiceRoute ->
            generic model Pages.TermsOfService.view

        Notes ->
            generic model Pages.Notes.view

        SignInRoute ->
            generic
                model
                (\model_ -> Pages.SignIn.view Types.LiftMsg model_.magicLinkModel |> Element.map Types.AuthFrontendMsg)

        AdminRoute ->
            if User.isAdmin model.magicLinkModel.currentUserData then
                generic model Pages.Admin.view

            else
                generic model Pages.Home.view


headerView : LoadedModel -> Route.Route -> { window : { width : Int, height : Int }, isCompact : Bool } -> Element FrontendMsg
headerView model route config =
    Element.el
        [ Element.Background.color View.Color.blue
        , Element.paddingXY 24 16

        --, Element.width (Element.px config.window.width)
        --, Element.alignTop
        ]
        (Element.wrappedRow
            [ Element.alignLeft
            , Element.spacing 24
            , Element.Background.color View.Color.blue
            , Element.Font.color (Element.rgb 1 1 1)
            ]
            [ Element.link
                (View.Common.linkStyle route Route.Notes)
                { url = Route.encode Route.Notes, label = Element.text "Notes" }
            ]
        )



---


generic : Types.LoadedModel -> (Types.LoadedModel -> Element Types.FrontendMsg) -> Element Types.FrontendMsg
generic model view_ =
    Element.column
        [ Element.width Element.fill, Element.height Element.fill ]
        [ Element.row [ Element.width (Element.px model.window.width), Element.Background.color View.Color.blue ]
            [ ---
              Pages.SignIn.headerView model.magicLinkModel
                model.route
                { window = model.window, isCompact = True }
                |> Element.map Types.AuthFrontendMsg
            , headerView model model.route { window = model.window, isCompact = True }
            ]
        , Element.column
            (Element.padding 20
                :: Element.scrollbarY
                :: Element.height (Element.px <| model.window.height - 95)
                :: Theme.contentAttributes
            )
            [ view_ model -- |> Element.map Types.AuthFrontendMsg
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
