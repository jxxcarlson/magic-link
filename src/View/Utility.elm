module View.Utility exposing
    ( onEnter
    , roundTo
    )

import Element
import Html.Events
import Json.Decode
import Types exposing (FrontendMsg)


onEnter : FrontendMsg -> Element.Attribute FrontendMsg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                Json.Decode.succeed msg

            else
                Json.Decode.fail "not ENTER"
    in
    Html.Events.on "keydown" (Html.Events.keyCode |> Json.Decode.andThen isEnter)
        |> Element.htmlAttribute



---XXX---


roundTo : Int -> Float -> Float
roundTo n x =
    let
        factor =
            10.0 ^ toFloat n

        x2 =
            x * factor |> round |> toFloat
    in
    x2 / factor
