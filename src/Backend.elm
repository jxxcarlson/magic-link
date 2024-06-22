module Backend exposing (app)

import AssocList
import Auth.Common
import Auth.Flow
import Dict
import Lamdera exposing (ClientId, SessionId)
import LocalUUID
import MagicLink.Auth
import MagicLink.Backend
import MagicLink.Helper as Helper
import Process
import Reconnet as Reconnect
import Task
import Time
import Types exposing (BackendModel, BackendMsg(..), ToBackend(..), ToFrontend(..))
import User


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

      -- kfasdkfd;
      , randomAtmosphericNumbers = Nothing
      , localUuidData = Nothing

      -- MAGICLINK
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

        GotAtmosphericRandomNumbers tryRandomAtmosphericNumbers ->
            let
                ( numbers, data_ ) =
                    case tryRandomAtmosphericNumbers of
                        Err _ ->
                            ( model.randomAtmosphericNumbers, model.localUuidData )

                        Ok rns ->
                            let
                                parts =
                                    rns
                                        |> String.split "\t"
                                        |> List.map String.trim
                                        |> List.filterMap String.toInt

                                data =
                                    LocalUUID.initFrom4List parts
                            in
                            ( Just parts, data )
            in
            ( { model
                | randomAtmosphericNumbers = numbers
                , localUuidData = data_
                , users =
                    if Dict.isEmpty model.users then
                        Helper.testUserDictionary

                    else
                        model.users
                , userNameToEmailString =
                    if Dict.isEmpty model.userNameToEmailString then
                        Dict.fromList [ ( "jxxcarlson", "jxxcarlson@gmail.com" ), ( "aristotle", "jxxcarlson@mac.com" ) ]

                    else
                        model.userNameToEmailString
              }
            , Cmd.none
            )

        GotFastTick time ->
            ( { model | time = time }
            , Cmd.none
            )

        -- MAGICLINK
        AuthBackendMsg authMsg ->
            Auth.Flow.backendUpdate (MagicLink.Auth.backendConfig model) authMsg

        AutoLogin sessionId loginData ->
            ( model, Lamdera.sendToFrontend sessionId (AuthToFrontend <| Auth.Common.AuthSignInWithTokenResponse <| Ok <| loginData) )

        OnConnected sessionId clientId ->
            ( model
            , Cmd.batch
                [ Helper.getAtmosphericRandomNumbers
                , Reconnect.reconnect model sessionId clientId
                , case AssocList.get sessionId model.sessionDict of
                    Just username ->
                        case Dict.get username model.users of
                            Just user ->
                                Process.sleep 60 |> Task.perform (always (AutoLogin sessionId (User.signinDataOfUser user)))

                            Nothing ->
                                Lamdera.sendToFrontend clientId (AuthToFrontend <| Auth.Common.AuthSignInWithTokenResponse (Err 0))

                    Nothing ->
                        Lamdera.sendToFrontend clientId (AuthToFrontend <| Auth.Common.AuthSignInWithTokenResponse (Err 1))
                ]
            )



-- MAGICLINK STUFF BELOW


updateFromFrontend : SessionId -> ClientId -> ToBackend -> BackendModel -> ( BackendModel, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        ToBackendNoOp ->
            ( model, Cmd.none )

        GetBackendModel ->
            ( model, Lamdera.sendToFrontend clientId (GotBackendModel model) )

        -- MAGICLINK
        AuthToBackend authMsg ->
            Auth.Flow.updateFromFrontend (MagicLink.Auth.backendConfig model) clientId sessionId authMsg model

        AddUser realname username email ->
            MagicLink.Backend.addUser model clientId email realname username

        RequestSignup realname username email ->
            MagicLink.Backend.requestSignUp model clientId realname username email

        AdminInspect maybeUser ->
            ( model, Lamdera.sendToFrontend clientId (AdminInspectResponse model) )
