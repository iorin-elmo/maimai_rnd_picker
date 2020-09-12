module Main exposing (main)
import Browser
import Html exposing (Html, text, div, br, button, input)
import Html.Events exposing (onClick)
import Html.Attributes exposing (size, value, type_, checked)
import Debug
import Dict exposing (Dict)
import Random exposing (Generator,generate)
import Data exposing (songData)

main : Program () Model Msg
main =
  Browser.element
    { init = \_ -> ( init, Cmd.none )
    , update = update
    , view = view
    , subscriptions = \_ -> Sub.none
    }

init =
  { songData = songData
  , result = []
  , isFilterMode = False
  , checkList =
    ( ["dx","std"]++
      ( List.range 19 29
        |> List.map intToDifficult
      )
    )
      |> List.map (\k -> (k,True))
      |> Dict.fromList
  }

type alias Model =
  { songData : List Song
  , result : List Song
  , isFilterMode : Bool
  , checkList : Dict String Bool
  }

type alias Song =
  { musicName : String
  , difficult : String
  , isDx : Bool
  }

type Msg
  = PickUp Song
  | Start
  | Clear
  | Toggle
  | Check String

update msg model =
  case msg of
    Start ->
      let
        objectiveSong =
          model.songData
            |> List.filter
              (\s ->
                let
                  keyList =
                    model.checkList
                      |> Dict.toList
                      |> List.filter Tuple.second
                      |> List.map Tuple.first
                in
                  (&&)
                    (List.member s.difficult keyList)
                    (keyList
                      |> List.member
                        (if s.isDx then "dx" else "std")
                    )
              )
        generator =
          case objectiveSong of
            hd::tl ->
              Random.uniform hd tl
            _ ->
              Random.constant
                {musicName = "Error",difficult = "", isDx = False}
      in
        ( model, generate PickUp generator )
    Clear ->
      ( { model
        | result = []
        }
      , Cmd.none )
    PickUp song ->
      ( { model
        | result = model.result ++ [song]
        }
      , Cmd.none )
    Toggle ->
      ( { model
        | isFilterMode = not model.isFilterMode }
      , Cmd.none )
    Check str ->
      ( { model
        | checkList =
          case Dict.get str model.checkList of
            Just bool ->
              Dict.insert str (not bool) model.checkList
            _ -> model.checkList
        }
      , Cmd.none )

intToDifficult n =
  String.fromInt (n//2)++
  ( if modBy 2 n == 0 then "" else "+" )
    |> \s -> if s == "9+" then " 9+" else s

view model =
  if model.isFilterMode
  then
    div []
      ( ( button
          [ onClick Toggle]
          [text "×"]
        )::
        ( model.checkList
          |> Dict.toList
          |> List.concatMap
            (\(k,v) ->
              [ br[][]
              , input
                [ type_ "checkbox"
                , checked v
                , onClick <| Check k ][]
              , text k
              ]
            )
        ))

  else
    div []
      <| List.append
        [ button
          [ onClick Start ]
          [ text "Start" ]
        , button
          [ onClick Clear ]
          [ text "Clear" ]
        , button
          [ onClick Toggle ]
          [ text "Filter" ]
        , br [][]
        ]
        ( model.result
          |> List.map
            (\s ->
              [ s.musicName
              , s.difficult
              , if s.isDx then "でらっくす" else "スタンダード"
              ]
              |> String.join " / "
              |> text
            )
          |> List.intersperse (br[][])
        )