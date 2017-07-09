::  Set the outgoing number for texting
::
::::  /hoon/set-number/sms/gen
  ::
/?    310
:-  %say
|=  {^ {num/@t $~} $~}
[%sms-number num]
