module PostmarkTests exposing (suite)

import Dict
import Email.Html
import Email.Html.Attributes
import EmailAddress exposing (EmailAddress)
import Expect exposing (Expectation)
import Http
import Internal
import Json.Decode as D
import List.Nonempty exposing (Nonempty)
import Postmark exposing (PostmarkError_, SendEmailError(..))
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Handle PostmarkTests response"
        [ test "name@gmail.com" <|
            \_ ->
                decodeBody
                    { url = "https://postmark.com"
                    , statusCode = 200
                    , statusText = ""
                    , headers = Dict.empty
                    }
                    """{"ErrorCode":0,"Message":"OK","MessageID":"434ea39f-9e0c-4838-b279-ecacb0800ba8","SubmittedAt":"2026-02-28T13:31:22.3527568Z","To":"name@gmail.com"}"""
                    |> Expect.equal (Ok ())
        , test "First Last <name@gmail.com>" <|
            \_ ->
                decodeBody
                    { url = "https://postmark.com"
                    , statusCode = 200
                    , statusText = ""
                    , headers = Dict.empty
                    }
                    """{"ErrorCode":0,"Message":"OK","MessageID":"434ea39f-9e0c-4838-b279-ecacb0800ba8","SubmittedAt":"2026-02-28T13:31:22.3527568Z","To":"First Last <name@gmail.com>"}"""
                    |> Expect.equal (Ok ())
        ]


decodeBody : Http.Metadata -> String -> Result SendEmailError ()
decodeBody metadata body =
    case D.decodeString decodePostmarkSendResponse body of
        Ok json ->
            if json.errorCode == 0 then
                Ok ()

            else
                PostmarkError json |> Err

        Err _ ->
            UnknownError { statusCode = metadata.statusCode, body = body } |> Err


decodePostmarkSendResponse : D.Decoder PostmarkError_
decodePostmarkSendResponse =
    D.map3 PostmarkError_
        (D.field "ErrorCode" D.int)
        (D.field "Message" D.string)
        (optionalField "To" decodeEmails
            |> D.map
                (\a ->
                    case a of
                        Just nonempty ->
                            List.Nonempty.toList nonempty

                        Nothing ->
                            []
                )
        )


{-| Copied from <https://package.elm-lang.org/packages/elm-community/json-extra/latest/Json-Decode-Extra>
-}
optionalField : String -> D.Decoder a -> D.Decoder (Maybe a)
optionalField fieldName decoder =
    let
        finishDecoding json =
            case D.decodeValue (D.field fieldName D.value) json of
                Ok val ->
                    -- The field is present, so run the decoder on it.
                    D.map Just (D.field fieldName decoder)

                Err _ ->
                    -- The field was missing, which is fine!
                    D.succeed Nothing
    in
    D.value
        |> D.andThen finishDecoding


decodeEmails : D.Decoder (Nonempty EmailAddress)
decodeEmails =
    D.andThen
        (\text ->
            let
                emails : List ( String, Maybe EmailAddress )
                emails =
                    String.split "," text
                        |> List.filterMap
                            (\subtext ->
                                let
                                    trimmed =
                                        String.trim subtext
                                in
                                if trimmed == "" then
                                    Nothing

                                else
                                    Just ( trimmed, EmailAddress.fromString trimmed )
                            )

                invalidEmails : List String
                invalidEmails =
                    List.filterMap
                        (\( subtext, maybeValid ) ->
                            if maybeValid == Nothing then
                                Just subtext

                            else
                                Nothing
                        )
                        emails
            in
            case invalidEmails of
                [] ->
                    let
                        validEmails : List EmailAddress
                        validEmails =
                            List.filterMap Tuple.second emails
                    in
                    case List.Nonempty.fromList validEmails of
                        Just nonempty ->
                            D.succeed nonempty

                        Nothing ->
                            D.fail "Expected at least one email"

                [ invalidEmail ] ->
                    invalidEmail ++ " is not a valid email" |> D.fail

                _ ->
                    invalidEmails
                        |> String.join ", "
                        |> (\a -> a ++ " are not valid emails")
                        |> D.fail
        )
        D.string
