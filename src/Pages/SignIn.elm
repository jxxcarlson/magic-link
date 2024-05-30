module Pages.SignIn exposing (view)

import Element exposing (Element)
import Element.Font
import MagicLink.LoginForm
import MagicLink.Types
import Types exposing (FrontendMsg(..), LoadedModel)
import View.Button
import View.Color
import View.Input


view : LoadedModel -> Element FrontendMsg
view model =
    case model.signInStatus of
        MagicLink.Types.NotSignedIn ->
            signInView model

        MagicLink.Types.SignedIn ->
            signedInView model

        MagicLink.Types.SigningUp ->
            signUp model

        MagicLink.Types.SuccessfulRegistration username email ->
            Element.column []
                [ signInAfterRegisteringView model
                , Element.el [ Element.Font.color (Element.rgb 0 0 1) ] (Element.text <| username ++ ", you are now registered as " ++ email)
                ]

        MagicLink.Types.ErrorNotRegistered message ->
            Element.column []
                [ signUp model
                , Element.el [ Element.Font.color (Element.rgb 1 0 0) ] (Element.text message)
                ]


signedInView : LoadedModel -> Element FrontendMsg
signedInView model =
    case model.currentUserData of
        Nothing ->
            Element.none

        Just userData ->
            View.Button.signOut userData.username


signInView : LoadedModel -> Element FrontendMsg
signInView model =
    Element.column []
        [ Element.el [ Element.Font.semiBold, Element.Font.size 24 ] (Element.text "Sign in")
        , MagicLink.LoginForm.view model model.signinForm

        --, Element.paragraph [ Element.Font.color (Element.rgb 1 0 0) ] [ Element.text (model.loginErrorMessage |> Maybe.withDefault "") ]
        , Element.row
            [ Element.spacing 12
            , Element.paddingEach { left = 18, right = 0, top = 0, bottom = 0 }
            ]
            [ Element.el [] (Element.text "Need to sign up?  "), View.Button.openSignUp ]
        ]


signInAfterRegisteringView : LoadedModel -> Element FrontendMsg
signInAfterRegisteringView model =
    Element.column []
        [ Element.el [ Element.Font.semiBold, Element.Font.size 24 ] (Element.text "Sign in")
        , MagicLink.LoginForm.view model model.signinForm
        ]


signUp : LoadedModel -> Element FrontendMsg
signUp model =
    Element.column [ Element.spacing 18, topPadding ]
        [ Element.el [ Element.Font.semiBold, Element.Font.size 24 ] (Element.text "Sign up")
        , View.Input.template "Real Name" model.realname (AuthFrontendMsg << MagicLink.Types.InputRealname)
        , View.Input.template "User Name" model.username (AuthFrontendMsg << MagicLink.Types.InputUsername)
        , View.Input.template "Email" model.email (AuthFrontendMsg << MagicLink.Types.InputEmail)
        , Element.row [ Element.spacing 18 ]
            [ View.Button.signUp
            , View.Button.cancelSignUp
            ]
        , Element.el [ Element.Font.size 14, Element.Font.italic, Element.Font.color View.Color.darkGray ] (Element.text model.message)
        ]


topPadding =
    Element.paddingEach { left = 0, right = 0, top = 48, bottom = 0 }
