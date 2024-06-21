module Pages.SignIn exposing (headerView, view)

import Auth.Common
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font
import Element.Input
import MagicLink.LoginForm
import MagicLink.Types
import Pages.Common
import Route
import Types exposing (FrontendMsg(..), LoadedModel)
import User
import View.Button
import View.Color
import View.Input


type alias Model =
    MagicLink.Types.Model


init : LoadedModel -> Model
init loadedModel =
    { count = 0
    , signInStatus = MagicLink.Types.NotSignedIn
    , currentUserData = Nothing
    , signInForm = MagicLink.LoginForm.init
    , signInState = MagicLink.Types.SisSignedOut
    , realname = ""
    , username = ""
    , email = ""
    , message = ""
    , authFlow = Auth.Common.Idle
    , authRedirectBaseUrl = loadedModel.authRedirectBaseUrl
    }


type Msg
    = Increment


update : Msg -> Model -> Model
update msg model =
    case msg of
        Increment ->
            { model | count = model.count + 1 }



-- VIEW


view : (MagicLink.Types.MLMsg -> msg) -> Model -> Element FrontendMsg
view toSelf model =
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


signedInView : Model -> Element FrontendMsg
signedInView model =
    case model.currentUserData of
        Nothing ->
            Element.none

        Just userData ->
            signOutButton userData.username


signInView : Model -> Element FrontendMsg
signInView model =
    Element.column []
        [ Element.el [ Element.Font.semiBold, Element.Font.size 24 ] (Element.text "Sign in")
        , MagicLink.LoginForm.view model.signInForm

        --, Element.paragraph [ Element.Font.color (Element.rgb 1 0 0) ] [ Element.text (model.loginErrorMessage |> Maybe.withDefault "") ]
        , Element.row
            [ Element.spacing 12
            , Element.paddingEach { left = 18, right = 0, top = 0, bottom = 0 }
            ]
            [ Element.el [] (Element.text "Need to sign up?  "), View.Button.openSignUp ]
        ]


signInAfterRegisteringView : Model -> Element FrontendMsg
signInAfterRegisteringView model =
    Element.column []
        [ Element.el [ Element.Font.semiBold, Element.Font.size 24 ] (Element.text "Sign in")
        , MagicLink.LoginForm.view model.signInForm
        ]


signUp : Model -> Element FrontendMsg
signUp model =
    Element.column [ Element.spacing 18, topPadding ]
        [ Element.el [ Element.Font.semiBold, Element.Font.size 24 ] (Element.text "Sign up")
        , View.Input.template "Real Name" model.realname (AuthFrontendMsg << MagicLink.Types.InputRealname)
        , View.Input.template "User Name" model.username (AuthFrontendMsg << MagicLink.Types.InputUsername)
        , View.Input.template "Email" model.email (AuthFrontendMsg << MagicLink.Types.InputEmail)
        , Element.row [ Element.spacing 18 ]
            [ signUpButton
            , cancelSignUpButton
            ]
        , Element.el [ Element.Font.size 14, Element.Font.italic, Element.Font.color View.Color.darkGray ] (Element.text model.message)
        ]


headerView : Model -> Route.Route -> { window : { width : Int, height : Int }, isCompact : Bool } -> Element Types.FrontendMsg
headerView model route config =
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
             --++ Theme.contentAttributes
            )
            [ Element.link
                (Pages.Common.linkStyle route Route.HomepageRoute)
                { url = Route.encode Route.HomepageRoute, label = Element.text "Magic Link Authentication" }
            , if User.isAdmin model.currentUserData then
                Element.link
                    (Pages.Common.linkStyle route Route.AdminRoute)
                    { url = Route.encode Route.AdminRoute, label = Element.text "Admin" }

              else
                Element.none
            , case model.currentUserData of
                Just currentUserData_ ->
                    signOutButton currentUserData_.username

                Nothing ->
                    Element.link
                        (Pages.Common.linkStyle route Route.SignInRoute)
                        { url = Route.encode Route.SignInRoute
                        , label =
                            Element.el []
                                (case model.currentUserData of
                                    Just currentUserData_ ->
                                        signOutButton currentUserData_.username

                                    Nothing ->
                                        Element.text "Sign in"
                                )
                        }
            ]
        )



-- BUTTON


signUpButton : Element.Element Types.FrontendMsg
signUpButton =
    button (Types.AuthFrontendMsg MagicLink.Types.SubmitSignUp) "Submit"


signOutButton : String -> Element.Element Types.FrontendMsg
signOutButton str =
    button (Types.AuthFrontendMsg MagicLink.Types.SignOut) ("Sign out " ++ str)


cancelSignUpButton =
    button (Types.AuthFrontendMsg MagicLink.Types.CancelSignUp) "Cancel"



-- BUTTON INFRASTRUCTURE


button msg label =
    Element.Input.button
        buttonStyle
        { onPress = Just msg
        , label =
            Element.el buttonLabelStyle (Element.text label)
        }


highlightableButton condition msg label =
    Element.Input.button
        buttonStyle
        { onPress = Just msg
        , label =
            Element.el (buttonLabelStyle ++ highlight condition) (Element.text label)
        }


buttonStyle =
    [ Element.Font.color (Element.rgb 0.2 0.2 0.2)
    , Element.height Element.shrink
    , Element.paddingXY 8 8
    , Element.Border.rounded 8
    , Element.Background.color View.Color.blue
    , Element.Font.color View.Color.white
    , Element.mouseDown
        [ Element.Background.color View.Color.buttonHighlight
        ]
    ]


buttonLabelStyle =
    [ Element.centerX
    , Element.centerY
    , Element.Font.size 15
    ]


highlight condition =
    if condition then
        [ Element.Font.color View.Color.yellow ]

    else
        [ Element.Font.color View.Color.white ]


topPadding =
    Element.paddingEach { left = 0, right = 0, top = 48, bottom = 0 }
