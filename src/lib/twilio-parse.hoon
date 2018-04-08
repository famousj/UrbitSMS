::  This library includes parsing functions for the json objects
::  that Twilio's API produces.  In general, the conversion from
::  JSON to urbit types should be performed in marks, so those
::  marks should include this library.
:: 
::
/-  twilio
|%
++  account
  ^-  $-(json (unit account:twilio))
  =+  jo
  %-  ot  :~
     'sid'^so
     :: TODO use dates here
     'date_created'^so
     'date_updated'^so
     'friendly_name'^so
     'type'^so
     'status'^so
     'auth_token'^so
     'uri'^so
     'subresource_uris'^ot
     'owner_account_sid'^so
  ==
++  user
  ^-  $-(json (unit user:gh))
  =+  jo
  %-  ot  :~
      'login'^so
      'id'^id
      'avatar_url'^so
      'gravatar_id'^so
      'url'^so
      'html_url'^so
      'followers_url'^so
      'following_url'^so
      'gists_url'^so
      'starred_url'^so
      'subscriptions_url'^so
      'organizations_url'^so
      'repos_url'^so
      'events_url'^so
      'received_events_url'^so
      'type'^so
      'site_admin'^bo
  ==
++  issue
  ^-  $-(json (unit issue:gh))
  |=  jon/json
  =-  (bind - |*(issue/* `issue:gh`[jon issue]))
  %.  jon
  =+  jo
  %-  ot  :~
      'url'^so
      'labels_url'^so
      'comments_url'^so
      'events_url'^so
      'html_url'^so
      'id'^id
      'number'^ni
      'title'^so
      'user'^user::|+(* (some *user:gh))
      'labels'^(ar label)::|+(* (some *(list label:gh)))::(ar label)
      'state'^so
      'locked'^bo
      'assignee'^(mu user)::|+(* (some *(unit user:gh)))::(mu user)
      'milestone'^some
      'comments'^ni
      'created_at'^so
      'updated_at'^so
      'closed_at'^(mu so)
      'body'^so
  ==
++  label
  ^-  $-(json (unit label:gh))
  =+  jo
  %-  ot  :~
      'url'^so
      'name'^so
      'color'^so
  ==
++  comment
  ^-  $-(json (unit comment:gh))
  =+  jo
  %-  ot  :~
      'url'^so
      'html_url'^so
      'issue_url'^so
      'id'^id
      'user'^user
      'created_at'^so
      'updated_at'^so
      'body'^so
  ==
++  id  no:jo
++  print-issue
  |=  issue:gh
  ^-  wain
  =+  c=(cury cat 3)
  :*  :(c 'title: ' title ' (#' (rsh 3 2 (scot %ui number)) ')')
      (c 'state: ' state)
      (c 'creator: ' login.user)
      (c 'created-at: ' created-at)
      (c 'assignee: ' ?~(assignee 'none' login.u.assignee))
    ::
      %+  c  'labels: '
      ?~  labels  ''
      |-  ^-  @t
      ?~  t.labels  name.i.labels
      :(c name.i.t.labels ', ' $(t.labels t.t.labels))
    ::
      (c 'comments: ' (rsh 3 2 (scot %ui comments)))
      (c 'url: ' url)
      ''
      %+  turn  (lore body)  ::  strip carriage returns
      |=  l/@t
      ?:  =('' l)
        l
      ?.  =('\0d' (rsh 3 (dec (met 3 l)) l))
        l
      (end 3 (dec (met 3 l)) l)
  ==
--
