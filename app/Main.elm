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


type alias Response a =
    { error : Maybe String
    , value : a
    }


type StepCount
    = StepCount Int


type HealthData
    = NotAsked
    | Failure Error
    | Success StepCount


type alias Model =
    HealthData


model : Model
model =
    NotAsked



-- UPDATE


type Msg
    = DidRequestAccess Decode.Value
    | DidGetStepCount Decode.Value
    | GrantAccess


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DidRequestAccess value ->
            let
                result =
                    Decode.decodeValue (Decode.maybe (Decode.field "error" Decode.string)) value
            in
                case result of
                    Ok value ->
                        case value of
                            Just error ->
                                ( Failure (HealthDataUnavailable error), Cmd.none )

                            Nothing ->
                                ( model, Cmd.none )

                    Err error ->
                        ( model, Cmd.none )

        DidGetStepCount value ->
            let
                decoder =
                    Decode.map2 Response
                        (Decode.maybe (Decode.field "error" Decode.string))
                        (Decode.maybe (Decode.field "value" Decode.int))

                result =
                    Decode.decodeValue decoder value
            in
                case result of
                    Ok response ->
                        case response.error of
                            Just error ->
                                ( Failure (HealthDataNotFound error), Cmd.none )

                            Nothing ->
                                case response.value of
                                    Just value ->
                                        ( Success (StepCount value), Cmd.none )

                                    Nothing ->
                                        ( model, Cmd.none )

                    Err error ->
                        ( model, Cmd.none )

        GrantAccess ->
            ( model, grantAccess () )



-- VIEW


view : Model -> Node Msg
view count =
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
            , text
                [ Ui.style
                    [ Style.textAlign "center"
                    , Style.marginBottom 30
                    ]
                ]
                [ Ui.string ("Step Count: " ++ toString count)
                ]
            , Elements.view
                [ Ui.style
                    [ Style.width 80
                    , Style.flexDirection "row"
                    , Style.justifyContent "space-between"
                    ]
                ]
                [ button GrantAccess "#5d5" "perm"
                ]
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
            , Style.width 30
            , Style.fontWeight "bold"
            , Style.shadowColor "#000"
            , Style.shadowOpacity 0.25
            , Style.shadowOffset 1 1
            , Style.shadowRadius 5
            , Style.transform { defaultTransform | rotate = Just "10deg" }
            ]
        , onPress msg
        ]
        [ Ui.string content ]



-- PORT


port requestAccess : () -> Cmd msg


port didRequestAccess : (Decode.Value -> msg) -> Sub msg


port grantAccess : () -> Cmd msg


port didGetStepCount : (Decode.Value -> msg) -> Sub msg



-- SUBSCRIPTION


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ didRequestAccess DidRequestAccess
        , didGetStepCount DidGetStepCount
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
