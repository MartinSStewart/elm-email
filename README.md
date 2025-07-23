This package lets you create and send emails using multiple different email services. Currently [SendGrid](https://sendgrid.com/) and [Postmark](https://account.postmarkapp.com) are supported.

*Note that you cannot use this package to send emails from a browser.
You'll be blocked by CORS.
You need to run this server-side or from a stand-alone application.*

### Example code

Once you've completed the previous step you can write something like this to send out emails (again, this will not work in a browser client due to CORS).

```elm
import SendGrid
import String.Nonempty exposing (NonemptyString)
import List.Nonempty

-- Make sure to install `MartinSStewart/elm-nonempty-string` and `mgold/elm-nonempty-list`.

email : (Result SendGrid.Error () -> msg) -> EmailAddress -> SendGrid.ApiKey -> Cmd msg
email msg recipient apiKey =
    SendGrid.textEmail
        { subject = NonemptyString 'S' "ubject" 
        , to = List.Nonempty.fromElement recipient
        , content = NonemptyString 'H' "i!"
        , nameOfSender = "Sender Name"
        , emailAddressOfSender = senderEmailAddress
        }
        |> SendGrid.sendEmail msg apiKey
```

### Postmark tool

If you are using Postmark, you can use this tool I've made https://postmark-email-client.lamdera.app/ to test sending emails and seeing what they look like for the end user.