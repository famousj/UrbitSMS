::  Send a text via Twilio
::  Details KM
:::: /hoon/sms/app
  ::
/?   310
|%  
++  move  {bone card}
++  card
  $%  {$hiss wire unit-iden/{$~ $~} mark/$httr cage/{mark/$hiss vase/hiss}}
      {$wait wire @da}
  ==
++  action
  $%  {$on $~}
      {$off $~}
      {$target p/cord}
  ==
--
|%
++  sms-url  |=  {acct/cord}  ^-  cord
    (crip "https://api.twilio.com/2010-04-01/Accounts/{(trip acct)}/Messages.json")
--
|_  {hid/bowl message/@t}
++  poke-sms
  |=  {acct/@t from/@t to/@t msg/@t}  ^-  (quip move +>)
  :-  :_  ~
      =+  pul=`purl`(need (epur (sms-url acct)))
      =+  maf=`math`(malt ~[content-type+['application/x-www-form-urlencoded']~]) 
      :*  ost.hid  %hiss  /request  `~  %httr  %hiss  pul
              :+  %post
                maf
              :: encode the body as though it's a query and drop the first
              :: char, i.e. the ?
              %-  some  %-  tact  %+  slag  1
              %-  tail:earn
                  :~  'To'^to
                      'From'^from
                      'Body'^msg
                  ==
      ==
    +>.$(message msg)
++  sigh-httr
  |=  {wir/wire code/@ud headers/mess body/(unit octs)}
  ^-  {(list move) _+>.$}
  ?:  =(code 201)
    ~&  [%text-sent message]
    [~ +>.$]
  :: TODO: Handle error with authentication.
  ~&  [%we-had-a-problem code]
  ~&  [%headers headers]
  ~&  [%body body]
  [~ +>.$]
++  prep  _`.  :: computed when the source file changes;
--             
