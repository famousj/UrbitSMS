# README #


## Installation

### Get the API setup

[Register at Twilio](https://www.twilio.com/console)

While you're there [get yourself a phone number](https://www.twilio.com/console/phone-numbers/incoming)

### Copy the app files

Make sure you have your home desk mounted, as per [the setup instructions](https://urbit.org/docs/using/setup/).

`git clone` all the files for this repo.  

It's not mandatory, but you might consider shutting your urbit down before copying all the files.

In the root directory for the repo run this:

```
cp -r src/* /urbit/path/your-urbit/home/
```

Now edit the file /urbit/path/your-urbit/home/gen/sms/send.hoon 

Change the ACCOUNT to your Twilio account SID and FROM_NUMBER to the Twilio phone number.

### Add auth to the ship

On your ship run this:
```
|init-auth-basic
```

The URL is `api.twilio.com`
The username is the Account SID you can find in [the account console dashboard](https://www.twilio.com/user/account)
The password is the Account Token.

In the dojo, run this:
```
+https://api.twilio.com/2010-04-01/Accounts
```

Make sure this works and doesn't give you an error.

### Fire it up!

Run this:
```
|start %sms
```

Assuming everything went well, you can now send a text, like so:
```
:sms|send '+13145554242' 'Here is your text, buddy'
```

Please note the single quotes.  Also, Twilio specifies that format for numbers,
with the plus and no dashes.

### Troubleshooting

- If you try to send a text and get this:
```
[! gall: %sms: sigh: no /tang/request  [%ap-lame %sms %sigh]]
```

This means you need to setup your authentication.
```
|init-auth-basic
```

If you get a message about "Your AccountSid or AuthToken was incorrect.", then
apparently you ran `|init-auth-basic` with a bad password. 


## J's Dev Notes

- A quick note before talking about how I got this thing up and running.  If you've read [The Little Schemer](https://mitpress.mit.edu/books/little-schemer), the Sixth Commandment states: "Simplfy only
  after the function is correct".  If you're new to this, my suggestion is: go slowly.  Start with something that already works, some bit of sample code,
  maybe.  Change something small, and make sure it works.  Refactor, make sure you didn't break anything.  Then change something else.
- The docs are good and improving, but less thorough than one might hope.  If you're reading through source and you're wondering what `epur` is, head over to google and search for `epur site:urbit.org/docs`.  You can find uses in the reference docs and see if it's used in some example code.
- This can work for glyphs as well, if you know the six-letter encoded version of it. So you're reading some source and you come across `:+` ask Mr. Google
  for `collus site:urbit.org/docs`, and it'll take you right to it.  Otherwise, you can put the glyph itself in quotes: `":+" site:urbit.org/docs`, which you
  might have to do on occasion, since sometimes you'll see two characters that aren't a "proper" glyph.
- For digging through the actual code, ask grep to find it for you.  So if you want to know how `epur` is used in the wild, `cd` into your
  home directory and run `grep -r epur *`.  (Note: if you're searching for something like `$hiss`, make sure you add a `bas` to it: `"\$hiss"`, otherwise grep
  will get confused.)

## Stuff I Did to Get It Working

- First thing, we'll need a security driver.  Read through Twilio documentation about their [REST API](https://www.twilio.com/docs/api/rest) to figure out what they're using.
- They're using HTTP Basic auth.  So I copied sec/com/github.hoon to sec/com/twilio.hoon.
- There's really only one thing that needs to change in this file, which is the test URL.  I dug through the documentation to figure out something generic that would work if you're authenticated and fail otherwise.  In this case `+https://api.twilio.com/2010-04-01/Accounts`
- Then I spent some time familiarizing myself with API by sending some POSTs
  via curl and Postman and referring to the docs about [sending
  messages](https://www.twilio.com/docs/api/rest/sending-messages).
- I tested out sending POSTs to the Twilio REST endpoint from dojo.  This did not work particularly well.  I tried JSON.  Status 400.  I tried sending as a 
URL-encoded string.  Status 400.  
- Since it was working in Postman, I looked at what that was sending in the headers.  Turns out I needed to set the content-type to "application/x-www-form-urlencoded".  
- There didn't seem to be any obvious way of doing that from dojo.  Inspecting the code, it looked like it was expecting JSON, which Twilio wasn't interested
  in.  Since I was going to have to move this functionality into an app at some point, I switched over to developing that.
- I copied out the `up.hoon` app from [the HTTP request docs](https://urbit.org/docs/arvo/http/).  I used that to try to send the request to the [account
  info](https://api.twilio.com/2010-04-01/Accounts) page.
- Problem: I couldn't figure out how to make an authenticated request.
I ended up asking on `:talk`  and got pointed in the right direction.  The `%hiss` call needs a `(unit identity)`.  My copy/pasted code for `up.hoon` was using `~`, which eyre interprets as "no authentication.  The person on talk (sorry, I can't credit) noted that the gmail app was using `\`~` (`tecsic`), which is shorthand for `[~ ~]`.  It seems that eyre intreprets that as "go lookup auth for me".
- I tried using `\`~` and got a `nest-fail`, which means I needed to update the
  signature (is this the "moss"?) for `++card` in the core, since `up.hoon` had written "no authentication" into the `++card` definition.
- Once I updated that, everything worked fine and I got the authenticated request sent.  Then I ran around the room giving random people high-fives.
- Now it was time to figure out how to actually send a post.  There wasn't anything specific in the docs about sending a post, which meant digging through
  source, puzzling through what was going on, and making something happen.
- The GET command was sending a `$purl`, but this didn't have any space for the actual body, and the header part where I specify that the contents are
  x-www-form-urlencoded.
- I grepped around the source to figure out which apps were doing a `%post`.  I discovered that gh.hoon, gmail.hoon, et al. were doing a post.  I also discovered that most of the code doing a POST was using JSON, so for at least some of this, I'd have to roll my own solution.
- Apparently gh.hoon and gmail.hoon were using the mark `%hiss`.  So I had to figure out how a `%hiss` works.
- Ultimately, I ended up looking at `arvo/zuse.hoon`.  All the code in `arvo` is very clean and streamlined and also somewhat opaque.  It's easy to read once
  you get your head around it, but if you're looking for something to copy/paste to get started, it's not the first place to look.
- Anyway, in `zuse.hoon` I discover that the moss for hiss is a purl and a moth.  (A moth?)  A `moth` is `{p/meth q/math r/(unit octs)}`.  `meth` is the
  method.  (Being from Oklahoma, when I read `meth`, I tend to think of something else...)  `math` is "semiparsed headers".  And the body apparently gets
  shunted into a `(unit octs)`.
- The good news here is that I could now grep for `math` and see where that's being used.  This sent me back to app/gmail.hoon, where it constructs a `moth`.  in `poke-gmail-req`.  So I copied that over to text.hoon, and set about getting it to work.
- Again the copy-pasted moss for up.hoon was assuming we'd send a GET request, which only needs a `$purl`.  `nest-fail`.  Once I changed the mark for the cage to `$hiss`, things started working just fine.  The post went through, my phone received a text, and again I ran around the room high-fiving strangers and kissing babies.
- (Alternately, I could have increased the genericity of the moss, so it's just expecting a `$cage`, but decided to keep things specific and let the compiler know if I've screwed up anything.  This is the eternal tradeoff of functional programming, between keeping things defined specifically and working through spurious failures or making things generic and dealing with types you weren't expecting.  Usually best to err toward being more specific.)
- Now it was time for some serious refactoring, since the app still had all the `%on` and `%off` logic.  Then I decided to make the message something you
  passed in.  At this point, I had a `nest-fail`, and fixed this by changing the type passed in to @.  (Note: I actually changed up a couple of things, which made debugging the `nest-fail` tricky.  Hence my note above about going slow.)
- I had been assigning a few variables, which worked fine, but didn't seem to be "idiomatic" hoon, so I refactored those out to call functions inline.  I
  used the rad `%-` syntax and even a `%+`.  Like a boss.
- I created a mark for an SMS message, which was mar/sms.hoon.  Pretty straightforward.
- Then I created a generator to send a message from dojo without having to do any nonsense with the `&atom` or even `&sms`.  
- Note on gen: make sure your parameter list ends in `$~`, otherwise you'll get
  some `nest-fail` for your debugging enjoyment. 
- In retrospect, I should have done the gen and mark thing way sooner, since generally this makes executing the app easier.
- Twilio forces you to use the account number as part of the SMS sending URL.  Since I don't want to commit my Twilio account info to github, I added that as a part of the SMS mark.  Then, in another "should have done this sooner", I added the account and the "from" phone number  to the generator, since they're really unlikely to change for me (or anyone else using this for that matter).  So now I only have to provide the "to" number and the message.  
- And at this point, it's pretty much usable as-is, other than the bit of editing you'd need to do on the generator.
- Time to publish to github, cleanup this doc, and let people know what's up.

## Up next

- Right now we can make a text message.  What happens if someone writes back? Well, it goes in a black hole.  To actually get replies and maybe do something
  with them, we'd need an API connector with a webhook setup.
- Once that's setup, we can read the account number and the phone number from within the account info, and won't need to pass that into the app directly
  (necessarily).  Although asking people to hack one file isn't exactly the Spanish Inquisition, but still.

## Notes

- Development is slow and somewhat painful.  The reason, I've decided, is the feedback loops are very long.  This is probably a lack of experience and the overall weirdness of the system/language/etc.
- For instance, when I was trying to do a POST from the command line, it occurred to me that I might need to be passing in a JSON object, not just a string `%s` as the [docs were doing](https://urbit.org/docs/using/shell/).

However, testing this theory took a very long time, digging through docs to find the right standard library command to convert from text JSON to urbit-ified JSON.  

I got that to build, but got a `nest-fail`, because I needed to pass that through `need`, because I was getting back a `unit`. (Which is not to be confused with Unit in scala, which is what I write code in during my day job.)

Having gone through all that, it posted to Twilio and... didn't work. 400.

This is fine, and to some extent this is how all development works.  It's just each of these steps might take an hour of eading and trying stuff out.


