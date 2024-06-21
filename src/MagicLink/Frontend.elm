module MagicLink.Frontend exposing
    ( enterEmail
    , handleRegistrationError
    , handleSignInError
    , signInWithCode
    , signInWithTokenResponseC
    , signInWithTokenResponseM
    , signOut
    , submitEmailForSignin
    , submitSignUp
    , userRegistered
    )

import Auth.Common
import Dict
import EmailAddress
import Helper
import Lamdera
import MagicLink.LoginForm
import MagicLink.Types exposing (SigninFormState(..))
import Route exposing (Route(..))
import Types
    exposing
        ( AdminDisplay(..)
        , FrontendMsg(..)
        , LoadedModel
        , ToBackend(..)
        )
import User


type alias Model =
    MagicLink.Types.Model


submitEmailForSignin : Model -> ( Model, Cmd FrontendMsg )
submitEmailForSignin model =
    case model.signInForm of
        EnterEmail signInForm_ ->
            case EmailAddress.fromString signInForm_.email of
                Just email ->
                    let
                        model2 =
                            { model | signInForm = EnterSigninCode { sentTo = email, loginCode = "", attempts = Dict.empty } }
                    in
                    ( model2, Helper.trigger <| AuthFrontendMsg <| MagicLink.Types.AuthSigninRequested { methodId = "EmailMagicLink", email = Just signInForm_.email } )

                Nothing ->
                    ( { model | signInForm = EnterEmail { signInForm_ | pressedSubmitEmail = True } }, Cmd.none )

        EnterSigninCode _ ->
            ( model, Cmd.none )


enterEmail : { a | signinForm : SigninFormState } -> String -> ( { a | signinForm : SigninFormState }, Cmd msg )
enterEmail model email =
    case model.signinForm of
        EnterEmail signinForm_ ->
            let
                signinForm =
                    { signinForm_ | email = email }
            in
            ( { model | signinForm = EnterEmail signinForm }, Cmd.none )

        EnterSigninCode loginCode_ ->
            -- TODO: complete this
            --  EnterLoginCode{ sentTo : EmailAddress, loginCode : String, attempts : Dict Int LoginCodeStatus }
            ( model, Cmd.none )


handleRegistrationError : { a | signInStatus : MagicLink.Types.SignInStatus } -> String -> ( { a | signInStatus : MagicLink.Types.SignInStatus }, Cmd msg )
handleRegistrationError model str =
    ( { model | signInStatus = MagicLink.Types.ErrorNotRegistered str }, Cmd.none )


handleSignInError : { a | loginErrorMessage : Maybe String, signInStatus : MagicLink.Types.SignInStatus } -> String -> ( { a | loginErrorMessage : Maybe String, signInStatus : MagicLink.Types.SignInStatus }, Cmd msg )
handleSignInError model message =
    ( { model | loginErrorMessage = Just message, signInStatus = MagicLink.Types.ErrorNotRegistered message }, Cmd.none )


signInWithTokenResponseM : a -> { b | currentUserData : Maybe a, route : Route } -> { b | currentUserData : Maybe a, route : Route }
signInWithTokenResponseM signInData model =
    { model | currentUserData = Just signInData, route = HomepageRoute }


signInWithTokenResponseC : User.SignInData -> Cmd msg
signInWithTokenResponseC signInData =
    if List.member User.AdminRole signInData.roles then
        Lamdera.sendToBackend GetBackendModel

    else
        Cmd.none


signOut :
    { a | showTooltip : Bool, signinForm : SigninFormState, loginErrorMessage : Maybe b, currentUserData : Maybe User.SignInData, currentUser : Maybe c, realname : String, username : String, email : String, adminDisplay : AdminDisplay, backendModel : Maybe d, message : String }
    ->
        ( { a | showTooltip : Bool, signinForm : SigninFormState, loginErrorMessage : Maybe b, signInStatus : MagicLink.Types.SignInStatus, currentUserData : Maybe User.SignInData, currentUser : Maybe c, realname : String, username : String, email : String, adminDisplay : AdminDisplay, backendModel : Maybe d, message : String }
        , Cmd frontendMsg
        )
signOut model =
    ( { model
        | showTooltip = False

        -- TOKEN
        , signinForm = MagicLink.LoginForm.init
        , loginErrorMessage = Nothing
        , signInStatus = MagicLink.Types.NotSignedIn

        -- USER
        , currentUserData = Nothing
        , currentUser = Nothing
        , realname = ""
        , username = ""
        , email = ""
        , signInState = MagicLink.Types.SisSignedOut

        -- ADMIN
        , adminDisplay = ADUser

        --
        , backendModel = Nothing
        , message = ""
      }
    , Cmd.none
    )


submitSignUp : { a | realname : String, username : String, email : String } -> ( { a | realname : String, username : String, email : String }, Cmd frontendMsg )
submitSignUp model =
    ( model, Lamdera.sendToBackend (AddUser model.realname model.username model.email) )


userRegistered : { a | currentUser : Maybe { b | username : String, email : EmailAddress.EmailAddress }, signInStatus : MagicLink.Types.SignInStatus } -> { b | username : String, email : EmailAddress.EmailAddress } -> ( { a | currentUser : Maybe { b | username : String, email : EmailAddress.EmailAddress }, signInStatus : MagicLink.Types.SignInStatus }, Cmd msg )
userRegistered model user =
    ( { model
        | currentUser = Just user
        , signInStatus = MagicLink.Types.SuccessfulRegistration user.username (EmailAddress.toString user.email)
      }
    , Cmd.none
    )



-- HELPERS


signInWithCode : Model -> String -> ( Model, Cmd msg )
signInWithCode model signInCode =
    case model.signInForm of
        MagicLink.Types.EnterEmail _ ->
            ( model, Cmd.none )

        EnterSigninCode enterLoginCode ->
            case MagicLink.LoginForm.validateLoginCode signInCode of
                Ok loginCode ->
                    if Dict.member loginCode enterLoginCode.attempts then
                        ( { model
                            | signInForm =
                                EnterSigninCode
                                    { enterLoginCode | loginCode = String.left MagicLink.LoginForm.loginCodeLength signInCode }
                          }
                        , Cmd.none
                        )

                    else
                        ( { model
                            | signInForm =
                                EnterSigninCode
                                    { enterLoginCode
                                        | loginCode = String.left MagicLink.LoginForm.loginCodeLength signInCode
                                        , attempts =
                                            Dict.insert loginCode MagicLink.Types.Checking enterLoginCode.attempts
                                    }
                          }
                        , Lamdera.sendToBackend ((AuthToBackend << Auth.Common.AuthSigInWithToken) loginCode)
                        )

                Err _ ->
                    ( { model | signInForm = EnterSigninCode { enterLoginCode | loginCode = String.left MagicLink.LoginForm.loginCodeLength signInCode } }
                    , Cmd.none
                    )
