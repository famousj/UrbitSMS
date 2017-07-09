::  Set the Twilio account number
::
::::  /hoon/set-number/sms/gen
  ::
/?    310
:-  %say
|=  {^ {acct/@t $~} $~}
[%sms-acct acct]
