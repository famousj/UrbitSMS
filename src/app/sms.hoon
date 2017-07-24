::  Send a text via Twilio
::  
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
|_  {hid/bowl acct/@t from/@t message/@t}
++  poke-sms-acct
  |=  acct/@t  ^-  (quip move +>)
  ~&  [%set-acct acct]
  [~ +>.$(acct acct)]
++  poke-sms-number
  |=  num/@t  ^-  (quip move +>)
  ~&  [%set-from num]
  [~ +>.$(from num)]
++  poke-sms-msg
  |=  {$~ to/@t txt/@t}  ^-  (quip move +>)
  :-  :_  ~
      :: TODO Make sure we've setup the account before we try to set the 
      :: URL
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
                      'Body'^txt
                  ==
      ==
    +>.$(message txt)
++  sigh-httr
  |=  {wir/wire code/@ud headers/mess body/(unit octs)}
  ^-  {(list move) _+>.$}
  ?:  =(code 201)
    ~&  [%text-sent message]
    [~ +>.$]
  ~&  [%we-had-a-problem code]
  ~&  [%headers headers]
  ~&  [%body body]
  [~ +>.$]
++  prep  _`.  :: computed when the source file changes;
--             
