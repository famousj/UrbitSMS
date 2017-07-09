::  Send text message via Twilio
::
::::  /hoon/sms/gen
  ::
/?    310
:-  %say
|=  {^ {to/@t message/@t $~} $~}
[%sms-msg ~ to message]
