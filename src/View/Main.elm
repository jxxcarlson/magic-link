module View.Main exposing (view)

import Browser
import Element exposing (Element)
import Element.Font
import MarkdownThemed
import Pages.Admin
import Pages.Home
import Pages.Notes
import Pages.Parts
import Pages.SignIn
import Pages.TermsOfService
import Route exposing (Route(..))
import Theme
import Types exposing (FrontendModel(..), FrontendMsg, LoadedModel)
import User


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


loadedView : LoadedModel -> Element FrontendMsg
loadedView model =
    case model.route of
        HomepageRoute ->
            Pages.Parts.generic model Pages.Home.view

        TermsOfServiceRoute ->
            Pages.Parts.generic model Pages.TermsOfService.view

        Notes ->
            Pages.Parts.generic model Pages.Notes.view

        SignInRoute ->
            Pages.Parts.generic model Pages.SignIn.view

        AdminRoute ->
            if User.isAdmin model.currentUserData || True then
                Pages.Parts.generic model Pages.Admin.view

            else
                Pages.Parts.generic model Pages.Home.view
