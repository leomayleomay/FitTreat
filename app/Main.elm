port module Main exposing (..)

import NativeUi as Ui exposing (Node)
import NativeUi.Style as Style exposing (defaultTransform)
import NativeUi.Elements as Elements exposing (..)
import NativeUi.Events exposing (..)
import NativeUi.Image as Image exposing (..)
import Json.Decode as Decode exposing (..)


-- MODEL


type Error
    = HealthDataUnavailable String
    | HealthDataNotFound String


type StepCount
    = StepCount Int


type HealthData
    = Loading
    | Failure Error
    | Success StepCount


type alias Model =
    HealthData


model : Model
model =
    Loading



-- UPDATE


type Msg
    = DidRequestAccessWithError String
    | DidGetStepCount Int
    | DidGetStepCountWithError String
    | GrantAccess


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DidRequestAccessWithError error ->
            ( Failure (HealthDataUnavailable error), Cmd.none )

        DidGetStepCount stepCount ->
            ( Success (StepCount stepCount), Cmd.none )

        DidGetStepCountWithError error ->
            ( Failure (HealthDataNotFound error), Cmd.none )

        GrantAccess ->
            ( model, grantAccess () )



-- VIEW


view : Model -> Node Msg
view model =
    let
        imageSource =
            { uri = "https://raw.githubusercontent.com/futurice/spiceprogram/master/assets/img/logo/chilicorn_no_text-128.png"
            , cache = Just ForceCache
            }
    in
        Elements.view
            [ Ui.style [ Style.alignItems "center" ]
            ]
            [ image
                [ Ui.style
                    [ Style.height 64
                    , Style.width 64
                    , Style.marginBottom 30
                    , Style.marginTop 30
                    ]
                , source imageSource
                ]
                []
            , Elements.view
                [ Ui.style
                    [ Style.flexDirection "row"
                    , Style.justifyContent "space-between"
                    ]
                ]
                [ viewStepCount model
                ]
            ]


viewStepCount : Model -> Node Msg
viewStepCount model =
    case model of
        Loading ->
            text
                []
                [ Ui.string "Loading"
                ]

        Failure (HealthDataUnavailable error) ->
            text
                []
                [ Ui.string "Health Data is unavailable on your device"
                ]

        Failure (HealthDataNotFound error) ->
            Elements.view
                []
                [ text [] [ Ui.string "You have not taken any walk today" ]
                , button GrantAccess "#5d5" ", or you deny access to Health Data"
                ]

        Success (StepCount stepCount) ->
            text
                [ Ui.style
                    [ Style.textAlign "center"
                    , Style.marginBottom 30
                    ]
                ]
                [ Ui.string ("Step Count: " ++ toString stepCount)
                ]


button : Msg -> String -> String -> Node Msg
button msg color content =
    text
        [ Ui.style
            [ Style.color "white"
            , Style.textAlign "center"
            , Style.backgroundColor color
            , Style.paddingTop 5
            , Style.paddingBottom 5
            , Style.fontWeight "bold"
            , Style.shadowColor "#000"
            , Style.shadowOpacity 0.25
            , Style.shadowOffset 1 1
            , Style.shadowRadius 5
            ]
        , onPress msg
        ]
        [ Ui.string content ]



-- PORT


port requestAccess : () -> Cmd msg


port didRequestAccessWithError : (String -> msg) -> Sub msg


port grantAccess : () -> Cmd msg


port didGetStepCount : (Int -> msg) -> Sub msg


port didGetStepCountWithError : (String -> msg) -> Sub msg



-- SUBSCRIPTION


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ didRequestAccessWithError DidRequestAccessWithError
        , didGetStepCount DidGetStepCount
        , didGetStepCountWithError DidGetStepCountWithError
        ]



-- PROGRAM


main : Program Never Model Msg
main =
    Ui.program
        { init = ( model, requestAccess () )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
