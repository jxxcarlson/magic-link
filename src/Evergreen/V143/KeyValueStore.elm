module Evergreen.V143.KeyValueStore exposing (..)

import Time


type alias KVDatum =
    { key : String
    , value : String
    , curator : String
    , created_at : Time.Posix
    , updated_at : Time.Posix
    }


type KVViewType
    = KVRaw
    | KVVSummary
    | KVVKey


type KVVerbosity
    = KVVerbose
    | KVQuiet
