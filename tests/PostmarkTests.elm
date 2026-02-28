module PostmarkTests exposing (suite)

import Dict
import Email.Html
import Email.Html.Attributes
import EmailAddress exposing (EmailAddress)
import Expect exposing (Expectation)
import Http
import Internal
import Json.Decode as D
import List.Nonempty exposing (Nonempty(..))
import Postmark exposing (PostmarkError_, SendEmailError(..))
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Handle PostmarkTests response"
        [ test "name@gmail.com" <|
            \_ ->
                D.decodeString Internal.decodeEmails "\"name@gmail.com\""
                    |> Expect.equal (Nonempty email [] |> Ok)
        , test "First Last <name@gmail.com>" <|
            \_ ->
                D.decodeString Internal.decodeEmails "\"First Last <name@gmail.com>\""
                    |> Expect.equal (Nonempty email [] |> Ok)
        ]


email : EmailAddress
email =
    case EmailAddress.fromString "name@gmail.com" of
        Just email2 ->
            email2

        Nothing ->
            Debug.todo "Invalid email"
