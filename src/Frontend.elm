module Frontend exposing (app)

import Auth.Common
import Browser exposing (UrlRequest(..))
import Browser.Dom
import Browser.Events
import Browser.Navigation
import Json.Decode
import Lamdera
import MagicLink.Auth
import MagicLink.Frontend
import MagicLink.Types
import Pages.SignIn
import Route
import Task
import Time
import Types
    exposing
        ( AdminDisplay(..)
        , FrontendModel(..)
        , FrontendMsg(..)
        , LoadedModel
        , LoadingModel
        , ToFrontend(..)
        )
import Url
import View.Main


app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = subscriptions
        , view = View.Main.view
        }


subscriptions : FrontendModel -> Sub FrontendMsg
subscriptions _ =
    Sub.batch
        [ Browser.Events.onResize GotWindowSize
        , Browser.Events.onMouseUp (Json.Decode.succeed MouseDown)
        , Time.every 1000 Tick
        ]


init : Url.Url -> Browser.Navigation.Key -> ( FrontendModel, Cmd FrontendMsg )
init url key =
    let
        route =
            Route.decode url
    in
    ( Loading
        { key = key
        , initUrl = url
        , now = Time.millisToPosix 0
        , window = Nothing
        , route = route
        }
    , Cmd.batch
        [ Browser.Dom.getViewport
            |> Task.perform (\{ viewport } -> GotWindowSize (round viewport.width) (round viewport.height))
        ]
    )


update : FrontendMsg -> FrontendModel -> ( FrontendModel, Cmd FrontendMsg )
update msg model =
    case model of
        Loading loading ->
            case msg of
                GotWindowSize width height ->
                    tryLoading { loading | window = Just { width = width, height = height } }

                _ ->
                    ( model, Cmd.none )

        Loaded loaded ->
            updateLoaded msg loaded |> Tuple.mapFirst Loaded


tryLoading : LoadingModel -> ( FrontendModel, Cmd FrontendMsg )
tryLoading loadingModel =
    Maybe.map
        (\window ->
            case loadingModel.route of
                _ ->
                    let
                        authRedirectBaseUrl =
                            let
                                initUrl =
                                    loadingModel.initUrl
                            in
                            { initUrl | query = Nothing, fragment = Nothing }
                    in
                    ( Loaded
                        { key = loadingModel.key
                        , now = loadingModel.now
                        , window = window
                        , showTooltip = False
                        , magicLinkModel = Pages.SignIn.init authRedirectBaseUrl
                        , authRedirectBaseUrl = authRedirectBaseUrl
                        , adminDisplay = ADUser
                        , route = loadingModel.route
                        , backendModel = Nothing
                        , message = "Starting up ..."
                        }
                    , Cmd.none
                    )
        )
        loadingModel.window
        |> Maybe.withDefault ( Loading loadingModel, Cmd.none )


updateLoaded : FrontendMsg -> LoadedModel -> ( LoadedModel, Cmd FrontendMsg )
updateLoaded msg model =
    case msg of
        NoOp ->
            let
                _ =
                    Debug.log "NO Op" True
            in
            ( model, Cmd.none )

        AuthFrontendMsg authFrontendMsg ->
            --case authFrontendMsg of
            --MagicLink.Types.CancelSignIn ->
            --    ( { model | route = Route.HomepageRoute }, Cmd.none )
            --
            --MagicLink.Types.OpenSignUp ->
            --    let
            --        magicLinkModel_ =
            --            MagicLink.Auth.updateFrontend MagicLink.Types.OpenSignUp model.magicLinkModel |> Tuple.first
            --    in
            --    ( { model | magicLinkModel = magicLinkModel_ }, Cmd.none )
            --
            --MagicLink.Types.CancelSignUp ->
            --    let
            --        magicLinkModel_ =
            --            MagicLink.Auth.updateFrontend MagicLink.Types.CancelSignUp model.magicLinkModel |> Tuple.first
            MagicLink.Auth.update authFrontendMsg model.magicLinkModel
                |> Tuple.mapFirst (\magicLinkModel -> { model | magicLinkModel = magicLinkModel })

        UrlClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model
                    , Browser.Navigation.pushUrl model.key (Url.toString url)
                    )

                External url ->
                    ( model
                    , Browser.Navigation.load url
                    )

        UrlChanged url ->
            ( { model | route = Route.decode url }, scrollToTop )

        Tick now ->
            ( { model | now = now }, Cmd.none )

        GotWindowSize width height ->
            ( { model | window = { width = width, height = height } }, Cmd.none )

        PressedShowTooltip ->
            ( { model | showTooltip = True }, Cmd.none )

        MouseDown ->
            ( { model | showTooltip = False }, Cmd.none )

        SetAdminDisplay adminDisplay ->
            ( { model | adminDisplay = adminDisplay }, Cmd.none )

        SetViewport ->
            ( model, Cmd.none )

        ChildMsg msg_ ->
            ( model, Cmd.none )

        SetRoute_ route ->
            ( { model | route = route }, Cmd.none )

        SignInUser userData ->
            let
                oldMagicLinkModel =
                    model.magicLinkModel
            in
            ( { model
                | magicLinkModel = { oldMagicLinkModel | currentUserData = Just userData, signInStatus = MagicLink.Types.SignedIn }
              }
            , Cmd.none
            )


scrollToTop : Cmd FrontendMsg
scrollToTop =
    Browser.Dom.setViewport 0 0 |> Task.perform (\() -> SetViewport)


updateFromBackend : ToFrontend -> FrontendModel -> ( FrontendModel, Cmd FrontendMsg )
updateFromBackend msg model =
    case model of
        Loading loading ->
            ( model, Cmd.none )

        Loaded loaded ->
            updateFromBackendLoaded msg loaded |> Tuple.mapFirst Loaded


updateFromBackendLoaded : ToFrontend -> LoadedModel -> ( LoadedModel, Cmd FrontendMsg )
updateFromBackendLoaded msg model =
    let
        updateMagicLinkModelInModel =
            \magicLinkModel -> { model | magicLinkModel = magicLinkModel }
    in
    case msg of
        AuthToFrontend authToFrontendMsg ->
            MagicLink.Auth.updateFromBackend authToFrontendMsg model.magicLinkModel
                |> Tuple.mapFirst updateMagicLinkModelInModel

        GotBackendModel beModel ->
            ( { model | backendModel = Just beModel }, Cmd.none )

        -- MAGICLINK
        AuthSuccess userInfo ->
            -- TODO (placholder)
            case userInfo.username of
                Just username ->
                    let
                        magicLinkModel_ =
                            model.magicLinkModel

                        magicLinkModel =
                            { magicLinkModel_ | authFlow = Auth.Common.Authorized userInfo.email username }
                    in
                    ( { model | magicLinkModel = magicLinkModel }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        UserInfoMsg _ ->
            -- TODO (placholder)
            ( model, Cmd.none )

        SignInError message ->
            MagicLink.Frontend.handleSignInError model.magicLinkModel message
                |> Tuple.mapFirst updateMagicLinkModelInModel

        RegistrationError str ->
            MagicLink.Frontend.handleRegistrationError model.magicLinkModel str
                |> Tuple.mapFirst updateMagicLinkModelInModel

        CheckSignInResponse _ ->
            ( model, Cmd.none )

        GetLoginTokenRateLimited ->
            ( model, Cmd.none )

        UserRegistered user ->
            MagicLink.Frontend.userRegistered model.magicLinkModel user
                |> Tuple.mapFirst updateMagicLinkModelInModel

        --|> Tuple.mapFirst updateMagicLinkModel
        UserSignedIn maybeUser ->
            let
                magicLinkModel_ =
                    model.magicLinkModel

                magicLinkModel =
                    case maybeUser of
                        Nothing ->
                            { magicLinkModel_ | signInStatus = MagicLink.Types.NotSignedIn } |> Debug.log "USER NOT SIGNED IN (1)"

                        Just _ ->
                            { magicLinkModel_ | signInStatus = MagicLink.Types.SignedIn } |> Debug.log "USER SIGNED IN (2)"
            in
            ( updateMagicLinkModelInModel magicLinkModel, Cmd.none )

        GotMessage message ->
            ( { model | message = message }, Cmd.none )

        AdminInspectResponse backendModel ->
            ( { model | backendModel = Just backendModel }, Cmd.none )
