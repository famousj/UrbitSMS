::  Test url +https://api.twilio.com/2010-04-01/Accounts
::
::::  /hoon/twilio/com/sec
  ::
/+    basic-auth
!:
|_  {bal/(bale keys:basic-auth) $~}
++  aut  ~(standard basic-auth bal ~)
++  filter-request  out-adding-header:aut
--
