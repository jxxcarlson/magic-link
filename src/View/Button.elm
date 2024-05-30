module View.Button exposing
    ( cancelSignUp
    , openSignUp
    , setAdminDisplay
    , signOut
    , signUp
    )

import Element
import Element.Background
import Element.Border as Border
import Element.Font
import Element.Input
import MagicLink.Types
import Types
import View.Color



-- USER


signUp : Element.Element Types.FrontendMsg
signUp =
    button (Types.AuthFrontendMsg MagicLink.Types.SubmitSignUp) "Submit"


signOut : String -> Element.Element Types.FrontendMsg
signOut str =
    button (Types.AuthFrontendMsg MagicLink.Types.SignOut) ("Sign out " ++ str)


cancelSignUp =
    button (Types.AuthFrontendMsg MagicLink.Types.CancelSignUp) "Cancel"


openSignUp =
    button (Types.AuthFrontendMsg MagicLink.Types.OpenSignUp) "Sign up"


setAdminDisplay : Types.AdminDisplay -> Types.AdminDisplay -> String -> Element.Element Types.FrontendMsg
setAdminDisplay currentDisplay newDisplay label =
    highlightableButton (currentDisplay == newDisplay) (Types.SetAdminDisplay newDisplay) label


highlight condition =
    if condition then
        [ Element.Font.color View.Color.yellow ]

    else
        [ Element.Font.color View.Color.white ]



-- EXAMPLES
-- BUTTON FUNCTION


button msg label =
    Element.Input.button
        buttonStyle
        { onPress = Just msg
        , label =
            Element.el buttonLabelStyle (Element.text label)
        }


highlightableButton condition msg label =
    Element.Input.button
        buttonStyle
        { onPress = Just msg
        , label =
            Element.el (buttonLabelStyle ++ highlight condition) (Element.text label)
        }


buttonStyle =
    [ Element.Font.color (Element.rgb 0.2 0.2 0.2)
    , Element.height Element.shrink
    , Element.paddingXY 8 8
    , Border.rounded 8
    , Element.Background.color View.Color.blue
    , Element.Font.color View.Color.white
    , Element.mouseDown
        [ Element.Background.color View.Color.buttonHighlight
        ]
    ]


buttonLabelStyle =
    [ Element.centerX
    , Element.centerY
    , Element.Font.size 15
    ]
