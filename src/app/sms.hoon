::  Send a text via Twilio
::  
:::: /hoon/sms/app
  ::
/?   310
|%  
++  move  {bone card}
++  card
  $%  {$hiss wire unit-iden/{$~ $~} mark/$httr cage/{mark/$hiss vase/$hiss}}
      {$hiss wire unit-iden/{$~ $~} mark/$httr cage/{mark/$purl vase/$purl}}
  ==
++  command
  $?  $log   :: Show the message log
  ==
--
|%
++  sms-msg-wire  ^-  wir/wire  /sms-msg
++  log-wire  ^-  wir/wire  /sms-log
++  url-prefix  |=  {acct/cord}  ^-  tape
    "https://api.twilio.com/2010-04-01/Accounts/{(trip acct)}/"
++  sms-url  |=  {acct/cord}  ^-  purl
  (need (epur (crip (weld (url-prefix acct) "Messages.json"))))
++  msg-from-body
    |=  {body/(unit octs)}  ^-  cord
    =+  jon=(need (de-json:html q:(need body)))
    =+  obj=(need ((dejs-soft:format some) jon))
    =+  bod=(~(got by obj) 'body')
    (need (so:jo bod))
--
|_  {hid/bowl acct/@t from/@t}
++  poke-sms-acct
  |=  acct/@t  ^-  (quip move _+>)
  ~&  [%set-acct acct]
  [~ +>.$(acct acct)]
++  poke-sms-number
  |=  num/@t  ^-  (quip move _+>)
  ~&  [%set-from num]
  [~ +>.$(from num)]
++  poke-sms-msg
  |=  {$~ to/@t txt/@t}  ^-  (quip move _+>)
  :: TODO Make sure we've setup the account before we try to set the 
  :: URL
  =+  ^=  header  ^-  math
      %-  malt 
      ~[content-type+['application/x-www-form-urlencoded']~] 
  :-  :_  ~
      :*  ost.hid  %hiss  sms-msg-wire  `~  %httr  %hiss  (sms-url acct)
          :+  %post
             header
          :: encode the body as though it's a query and drop the first
          :: char, i.e. the ?
          %-  some  %-  tact  %+  slag  1
          %-  tail:earn
              :~  'To'^to
                  'From'^from
                  'Body'^txt
              ==
      ==
  +>.$
++  poke-atom
  |=  cmd/@t  ^-  (quip move _+>)
  ~&  [%cmdatom cmd]  
  =+  purl=`purl`(sms-url acct)
  ~!  purl
  =+  move=`move`[ost.hid %hiss /log `~ %httr %purl purl]
  [[move ~] +>.$]
++  sigh-sms-msg
  |=  {code/@ud headers/mess body/(unit octs)}
  ^-  (quip move _+>)
  ?:  =(code 201)
    ~&  [%text-sent (msg-from-body body)]
    [~ +>.$]
  ~&  [%we-had-a-problem code]
  ~&  [%headers headers]
  ~&  [%body body]
  [~ +>.$]
++  sigh-httr
  |=  {wir/wire code/@ud headers/mess body/(unit octs)}
  ^-  (quip move _+>)
  ?:  =(wir sms-msg-wire)  
    (sigh-sms-msg code headers body)
  ~&  [%code code]
  ~&  [%headers headers]
  ~&  [%body body]
  [~ +>.$]
::  ++  prep  _`.  :: computed when the source file changes;
--
