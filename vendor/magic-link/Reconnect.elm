module Reconnect exposing (reconnect)

import Auth.Common
import Dict exposing (Dict)
import Lamdera exposing (..)
import Types


reconnect model sessionId clientId =
    let
        userInfo : Maybe Auth.Common.UserInfo
        userInfo =
            Dict.get sessionId model.sessions

        maybeUser =
            case Maybe.map .username userInfo of
                Just mu ->
                    case mu of
                        Just username ->
                            Dict.get username model.users

                        Nothing ->
                            Nothing

                Nothing ->
                    Nothing
    in
    Lamdera.sendToFrontend clientId (Types.UserSignedIn maybeUser)
