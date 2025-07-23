module ReviewConfig exposing (config)

{-| Do not rename the ReviewConfig module or the config function, because
`elm-review` will look for these.

To add packages that contain rules, add them to this review project using

    `elm install author/packagename`

when inside the directory containing this file.

-}

import NoConfusingPrefixOperator
import NoExposingEverything
import NoImportingEverything
import NoMissingTypeAnnotation
import NoMissingTypeExpose
import NoPrematureLetComputation
import NoUnused.Dependencies
import NoUnused.Parameters
import Review.Rule exposing (Rule)


config : List Rule
config =
    [ NoUnused.Dependencies.rule
    , NoUnused.Parameters.rule
    , NoConfusingPrefixOperator.rule
    , NoExposingEverything.rule
    , NoImportingEverything.rule []
    , NoMissingTypeAnnotation.rule
    , NoMissingTypeExpose.rule
    , NoPrematureLetComputation.rule
    ]
