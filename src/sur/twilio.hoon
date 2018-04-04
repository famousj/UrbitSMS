::  https://api.twilio.com/2010-04-01
::
::  These types correspond to the types that Twilio's API produces,
::  so if you're curious what's what, see their docs.
::  For parsing JSON into these types, check out the twilio-parse
::  library.
::
|%
++  account
  $:  sid/@t
      date-create/@t
      date-updated/@t
      friendly-name/@t
      type/@t
      status/@t
      auth-token/@t
      uri/@t
      subresource-uris/(list @t)
      owner-account-sid/@t
  ==
--
