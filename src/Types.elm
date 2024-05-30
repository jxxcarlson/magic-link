module Types exposing
    ( AdminDisplay(..)
    , BackendDataStatus(..)
    , BackendModel
    , BackendMsg(..)
    , FrontendModel(..)
    , FrontendMsg(..)
    , LoadedModel
    , LoadingModel
    , SignInState(..)
    , ToBackend(..)
    , ToFrontend(..)
    )

import AssocList
import Auth.Common
import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Dict exposing (Dict)
import EmailAddress exposing (EmailAddress)
import Http
import Lamdera exposing (ClientId, SessionId)
import LocalUUID
import MagicLink.Types
import Route exposing (Route)
import Session
import Time
import Url exposing (Url)
import User


type FrontendModel
    = Loading LoadingModel
    | Loaded LoadedModel


type alias LoadingModel =
    { key : Key
    , initUrl : Url
    , now : Time.Posix
    , window : Maybe { width : Int, height : Int }
    , route : Route
    }


type alias LoadedModel =
    { key : Key
    , now : Time.Posix
    , window : { width : Int, height : Int }
    , showTooltip : Bool

    -- MAGICLINK
    , authFlow : Auth.Common.Flow
    , authRedirectBaseUrl : Url
    , signinForm : MagicLink.Types.SigninForm
    , loginErrorMessage : Maybe String
    , signInStatus : MagicLink.Types.SignInStatus
    , currentUserData : Maybe User.LoginData

    -- USER
    , currentUser : Maybe User.User
    , signInState : SignInState
    , realname : String
    , username : String
    , email : String
    , password : String
    , passwordConfirmation : String

    -- ADMIN
    , adminDisplay : AdminDisplay
    , backendModel : Maybe BackendModel

    --
    , route : Route
    , message : String

    -- EXAMPLES
    , language : String -- Internationalization of date custom element
    , inputCity : String
    }


type SignInState
    = SignedOut
    | SignUp
    | SignedIn


type AdminDisplay
    = ADUser
    | ADSession
    | ADKeyValues


type alias BackendModel =
    { randomAtmosphericNumbers : Maybe (List Int)
    , localUuidData : Maybe LocalUUID.Data
    , time : Time.Posix

    -- MAGICLINK
    , pendingAuths : Dict Lamdera.SessionId Auth.Common.PendingAuth
    , pendingEmailAuths : Dict Lamdera.SessionId Auth.Common.PendingEmailAuth
    , sessions : Dict SessionId Auth.Common.UserInfo
    , secretCounter : Int
    , sessionDict : AssocList.Dict SessionId String -- Dict sessionId usernames
    , pendingLogins :
        AssocList.Dict
            SessionId
            { loginAttempts : Int
            , emailAddress : EmailAddress
            , creationTime : Time.Posix
            , loginCode : Int
            }
    , log : MagicLink.Types.Log
    , users : Dict.Dict User.EmailString User.User
    , userNameToEmailString : Dict.Dict User.Username User.EmailString
    , sessionInfo : Session.SessionInfo
    }


type FrontendMsg
    = NoOp
    | UrlClicked UrlRequest
    | UrlChanged Url
    | Tick Time.Posix
    | GotWindowSize Int Int
    | PressedShowTooltip
    | MouseDown
      -- MAGICLINK
    | AuthFrontendMsg MagicLink.Types.FrontendMsg
      -- ADMIN
    | SetAdminDisplay AdminDisplay
      --
    | SetViewport
      -- EXAMPLES
    | LanguageChanged String -- for internationalization of date
    | InputCity String


type ToBackend
    = ToBackendNoOp
    | AdminInspect (Maybe User.User)
    | GetBackendModel
      -- MAGICLINK
    | AuthToBackend Auth.Common.ToBackend
      -- USER
    | AddUser String String String -- realname, username, email
    | RequestSignup String String String -- realname, username, email


type BackendMsg
    = NoOpBackendMsg
    | GotFastTick Time.Posix
    | BackendGotTime SessionId ClientId ToBackend Time.Posix
    | OnConnected SessionId ClientId
    | GotAtmosphericRandomNumbers (Result Http.Error String)
      -- MAGICLINK
    | AuthBackendMsg Auth.Common.BackendMsg
      --
    | AutoLogin SessionId User.LoginData


type ToFrontend
    = GotMessage String
    | AdminInspectResponse BackendModel
      -- MAGICLINK
    | AuthToFrontend Auth.Common.ToFrontend
      ---
    | AuthSuccess Auth.Common.UserInfo
    | UserInfoMsg (Maybe Auth.Common.UserInfo)
    | CheckSignInResponse (Result BackendDataStatus User.LoginData)
    | GetLoginTokenRateLimited
    | RegistrationError String
    | SignInError String
      -- USER
    | UserSignedIn (Maybe User.User)
    | UserRegistered User.User
      -- EXAMPLE
    | GotBackendModel BackendModel


type BackendDataStatus
    = Sunny
    | LoadedBackendData
