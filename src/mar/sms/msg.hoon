:: An SMS message
::
::::  /hoon/msg/sms/mar
  ::
/?    310
|_  {from/@t to/@t txt/@t}
::
++  grab                                                ::  convert from
  |%
  ++  noun  {@t @t @t}                                  ::  clam from %noun
  --
--
