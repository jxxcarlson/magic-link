module Backend exposing (app)

import AssocList
import Atmospheric
import Auth.Common
import Auth.Flow
import Dict
import Lamdera exposing (ClientId, SessionId)
import MagicLink.Auth
import MagicLink.Backend
import MagicLink.Helper as Helper
import Reconnect
import Task
import Time
import Types exposing (BackendModel, BackendMsg(..), ToBackend(..), ToFrontend(..))


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = subscriptions
        }


init : ( BackendModel, Cmd BackendMsg )
init =
    ( { users = Dict.empty
      , userNameToEmailString = Dict.empty
      , sessions = Dict.empty
      , sessionInfo = Dict.empty
      , time = Time.millisToPosix 0
      , randomAtmosphericNumbers = Nothing
      , localUuidData = Nothing
      , pendingAuths = Dict.empty
      , pendingEmailAuths = Dict.empty
      , secretCounter = 0
      , sessionDict = AssocList.empty
      , pendingLogins = AssocList.empty
      , log = []

      -- EXPERIMENTAL
      }
    , Cmd.batch
        [ Time.now |> Task.perform GotFastTick
        , Helper.getAtmosphericRandomNumbers
        ]
    )


subscriptions : BackendModel -> Sub BackendMsg
subscriptions _ =
    Sub.batch
        [ Time.every 1000 GotFastTick
        , Lamdera.onConnect OnConnected
        ]


update : BackendMsg -> BackendModel -> ( BackendModel, Cmd BackendMsg )
update msg model =
    -- Replace existing randomAtmosphericNumber with a new one if possible
    case msg of
        NoOpBackendMsg ->
            ( model, Cmd.none )

        -- MAGICLINK
        GotAtmosphericRandomNumbers tryRandomAtmosphericNumbers ->
            Atmospheric.gotNumbers model tryRandomAtmosphericNumbers

        GotFastTick time ->
            ( { model | time = time }, Cmd.none )

        AuthBackendMsg authMsg ->
            Auth.Flow.backendUpdate (MagicLink.Auth.backendConfig model) authMsg

        AutoLogin sessionId loginData ->
            ( model, Lamdera.sendToFrontend sessionId (AuthToFrontend <| Auth.Common.AuthSignInWithTokenResponse <| Ok <| loginData) )

        OnConnected sessionId clientId ->
            Reconnect.connect model sessionId clientId



-- MAGICLINK STUFF BELOW


updateFromFrontend : SessionId -> ClientId -> ToBackend -> BackendModel -> ( BackendModel, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        ToBackendNoOp ->
            ( model, Cmd.none )

        GetUserDictionary ->
            ( model, Lamdera.sendToFrontend clientId (GotUserDictionary model.users) )

        -- MAGICLINK
        AuthToBackend authMsg ->
            Auth.Flow.updateFromFrontend (MagicLink.Auth.backendConfig model) clientId sessionId authMsg model

        AddUser realname username email ->
            MagicLink.Backend.addUser model clientId email realname username

        RequestSignup realname username email ->
            MagicLink.Backend.requestSignUp model clientId realname username email
