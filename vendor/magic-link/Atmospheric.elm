module Atmospheric exposing (gotNumbers)

import Dict
import LocalUUID
import MagicLink.Helper as Helper


gotNumbers model tryRandomAtmosphericNumbers =
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
