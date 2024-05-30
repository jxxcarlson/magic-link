module Pages.Home exposing (view)

import Element exposing (Element)
import MarkdownThemed
import Theme
import Types exposing (FrontendMsg(..), LoadedModel)


view : LoadedModel -> Element FrontendMsg
view model =
    Element.column [ Element.paddingXY 0 30 ]
        [ Element.column Theme.contentAttributes [ content ]
        , Element.row
            ([ Element.spacing 20
             ]
                ++ Theme.contentAttributes
            )
            []
        ]


content : Element msg
content =
    """
# Magic Link Authentication

This is app demonstrates magic link authentication for Lamdera apps.
The repo is at  [github.com/jxxcarlson/magic-link](https://github.com/jxxcarlson/magic-link).




        """
        |> MarkdownThemed.renderFull
