module Pages.Admin exposing (Window, view)

import AssocList
import Dict
import Element exposing (Element, column, fill, height, px, spacing, text, width)
import Element.Font
import EmailAddress
import Types exposing (AdminDisplay(..), BackendModel, FrontendMsg, LoadedModel)
import User
import View.Button
import View.Geometry
import View.MarkdownThemed as MarkdownThemed
import View.Theme as Theme


type alias Window =
    { width : Int
    , height : Int
    }


view : LoadedModel -> Element FrontendMsg
view model =
    Element.column []
        [ Element.row [ Element.spacing 24, Element.paddingEach { left = 0, right = 0, top = 0, bottom = 24 } ]
            [ View.Button.setAdminDisplay model.adminDisplay ADUser "Users"
            , View.Button.setAdminDisplay model.adminDisplay ADSession "Sessions"
            ]
        , case model.backendModel of
            Nothing ->
                text ""

            Just backendModel ->
                case model.adminDisplay of
                    ADUser ->
                        viewUserData model.window backendModel

                    ADSession ->
                        viewSessions model.window backendModel

                    ADKeyValues ->
                        viewKeyValuePairs model.window backendModel
        ]


viewKeyValuePairs : Window -> BackendModel -> Element msg
viewKeyValuePairs window backendModel =
    column
        [ width fill
        , spacing 12
        , height (px <| window.height - 2 * View.Geometry.headerFooterHeight)
        ]
        [ Element.column Theme.contentAttributes [ content ]
        , Element.el [ Element.Font.bold ] (text "Key-Value Store")
        ]


content =
    """
### RPC Example

Add key-value pairs to the key-value store by sending this
POST request:

```
curl -X POST -d '{ "key": "foo", "value": "1234" }' \\
   -H 'content-type: application/json' \\
   https://elm-kitchen-sink.lamdera.app/_r/putKeyValuePair
```

Retrieve key-value pairs from the key-value store by sending
the request

```
curl -X POST -d '{ "key": "foo" }' \\
-H 'content-type: application/json' \\
https://elm-kitchen-sink.lamdera.app/_r/getKeyValuePair
```
"""
        |> MarkdownThemed.renderFull


viewUserData : Window -> BackendModel -> Element msg
viewUserData window backendModel =
    column
        [ width fill
        , spacing 12
        ]
        [ viewUserDictionary window backendModel.users ]


viewUserDictionary : Window -> Dict.Dict String User.User -> Element msg
viewUserDictionary window userDictionary =
    let
        users : List User.User
        users =
            Dict.values userDictionary
    in
    column
        [ width fill
        , Element.height (Element.px <| window.width - 2 * View.Geometry.headerFooterHeight)
        , Element.scrollbarY
        , Element.spacing 24
        ]
        (List.map viewUser users)


viewUser : User.User -> Element msg
viewUser =
    \user ->
        column
            [ width fill
            ]
            [ text ("realname: " ++ user.fullname)
            , text ("username: " ++ user.username)
            , text ("email: " ++ EmailAddress.toString user.email)
            , text ("id: " ++ user.id)
            , case user.verified of
                Nothing ->
                    text "not verified"

                Just _ ->
                    text "verified"
            ]


viewSessions : Window -> BackendModel -> Element msg
viewSessions window backendModel =
    column
        [ width fill
        , spacing 12
        ]
        (backendModel.sessionDict
            |> AssocList.toList
            |> List.map viewSession
        )


viewSession : ( String, String ) -> Element msg
viewSession ( key, value ) =
    column
        [ width fill
        ]
        [ text key
        , text value
        ]
