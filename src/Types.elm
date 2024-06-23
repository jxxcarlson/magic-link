module Types exposing
    ( AdminDisplay(..)
    , BackendDataStatus(..)
    , BackendModel
    , BackendMsg(..)
    , FrontendModel(..)
    , FrontendMsg(..)
    , LoadedModel
    , LoadingModel
    , ToBackend(..)
    , ToFrontend(..)
    )

import AssocList
import Auth.Common
import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Dict exposing (Dict)
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
    , authRedirectBaseUrl : Url
    , magicLinkModel : MagicLink.Types.Model
    , adminDisplay : AdminDisplay
    , backendModel : Maybe BackendModel
    , route : Route
    , message : String
    }


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
    , pendingLogins : MagicLink.Types.PendingLogins
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
    | AuthFrontendMsg MagicLink.Types.Msg
    | LiftMsg MagicLink.Types.Msg
    | SignInUser User.SignInData
    | SetAdminDisplay AdminDisplay
    | SetRoute_ Route
    | SetViewport


type ToBackend
    = ToBackendNoOp
      -- MAGICLINK
    | GetBackendModel
    | AdminInspect (Maybe User.User)
    | AuthToBackend Auth.Common.ToBackend
    | AddUser String String String -- realname, username, email
    | RequestSignup String String String -- realname, username, email


type BackendMsg
    = NoOpBackendMsg
      -- MAGICLINK
    | GotFastTick Time.Posix
    | OnConnected SessionId ClientId
    | GotAtmosphericRandomNumbers (Result Http.Error String)
    | AuthBackendMsg Auth.Common.BackendMsg
    | AutoLogin SessionId User.SignInData


type ToFrontend
    = GotMessage String
      -- MAGICLINK
    | AdminInspectResponse BackendModel
    | AuthToFrontend Auth.Common.ToFrontend
    | AuthSuccess Auth.Common.UserInfo
    | UserInfoMsg (Maybe Auth.Common.UserInfo)
    | CheckSignInResponse (Result BackendDataStatus User.SignInData)
    | GetLoginTokenRateLimited
    | RegistrationError String
    | SignInError String
    | UserSignedIn (Maybe User.User)
    | UserRegistered User.User
    | GotBackendModel BackendModel


type BackendDataStatus
    = Sunny
    | LoadedBackendData
