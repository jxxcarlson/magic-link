module MagicLink.Types exposing
    ( EnterEmail_
    , EnterLoginCode_
    , FrontendMsg(..)
    , Log
    , LogItem(..)
    , LoginCodeStatus(..)
    , PendingLogins
    , SignInStatus(..)
    , SigninForm(..)
    )

import AssocList
import Auth.Common
import Dict exposing (Dict)
import EmailAddress exposing (EmailAddress)
import Lamdera
import Time
import User


type FrontendMsg
    = SubmitEmailForSignIn
    | AuthSigninRequested { methodId : Auth.Common.MethodId, email : Maybe String }
    | ReceivedSigninCode String
    | CancelSignIn
    | CancelSignUp
    | OpenSignUp
    | TypedEmailInSignInForm String
    | SubmitSignUp
    | SignOut
    | InputRealname String
    | InputUsername String
    | InputEmail String


type SigninForm
    = EnterEmail EnterEmail_
    | EnterSigninCode EnterLoginCode_


type SignInStatus
    = NotSignedIn
    | ErrorNotRegistered String
    | SuccessfulRegistration String String
    | SigningUp
    | SignedIn


type LoginCodeStatus
    = Checking
    | NotValid


type alias PendingLogins =
    AssocList.Dict
        Lamdera.SessionId
        { loginAttempts : Int
        , emailAddress : EmailAddress
        , creationTime : Time.Posix
        , loginCode : Int
        }


type LogItem
    = LoginsRateLimited User.Id
    | FailedToCreateLoginCode Int


type alias EnterEmail_ =
    { email : String
    , pressedSubmitEmail : Bool
    , rateLimited : Bool
    }


type alias EnterLoginCode_ =
    { sentTo : EmailAddress, loginCode : String, attempts : Dict Int LoginCodeStatus }


type alias Log =
    List ( Time.Posix, LogItem )
