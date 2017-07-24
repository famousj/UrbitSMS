# README #

## Installation

### Get the API setup

[Register at Twilio](https://www.twilio.com/console)

While you're there [get yourself a phone number](https://www.twilio.com/console/phone-numbers/incoming)

### Copy the app files

Make sure you have your home desk mounted, as per [the setup instructions](https://urbit.org/docs/using/setup/).

`git clone` this repo.

It's not mandatory, but you might consider shutting your urbit down before copying all the files.

In the root directory for the repo run this:

```
cp -r src/* /urbit/path/your-urbit/home/
```

Now edit the file /urbit/path/your-urbit/home/gen/sms/send.hoon 

Change the ACCOUNT to your Twilio account SID and FROM_NUMBER to the Twilio phone number.

### Add auth to the ship

On your ship, run this:
```
|init-auth-basic
```

The URL is `api.twilio.com`  
The username is the Account SID you can find in [the account console dashboard](https://www.twilio.com/user/account)  
The password is the Account Token.

In the dojo, run this:
```
+https://api.twilio.com/2010-04-01/Accounts.json
```

Make sure this works and doesn't give you an error.

### Fire it up!

Now start the app:
```
|start %sms
```

Configure the app for your Twilio account.  Of course you should use your
Account SID and your Twilio phone number:
```
:sms|set-acct 'AC2222222'
:sms|set-number '+13145557766'
```

Please note the single quotes.  Also, Twilio specifies that exact format for numbers, with the plus and no dashes.

Assuming everything went well, you should now be able to send a text, like so:
```
:sms|send '+13145554242' 'Here is your text, buddy'
```

### Receiving Texts

Okay, now that you're sending texts, let's set us up for receiving texts.

https://www.twilio.com/console/phone-numbers/incoming



### Troubleshooting

- If you try to send a text and get this:
```
[! gall: %sms: sigh: no /tang/request  [%ap-lame %sms %sigh]]
```

This means you need to setup your authentication.
```
|init-auth-basic
```

- If you get a message about "Your AccountSid or AuthToken was incorrect.", then apparently you ran `|init-auth-basic` with a bad password. Good news is you
can run it again.


## J's Dev Notes

- A quick note before talking about how I got this thing up and running.  If you've read [The Little Schemer](https://mitpress.mit.edu/books/little-schemer), the Sixth Commandment states: "Simplfy only
  after the function is correct".  If you're new to this, my suggestion is: go slowly.  Start with something that already works, some bit of sample code,
  maybe.  Change something small, and make sure it works.  Refactor, make sure you didn't break anything.  Then change something else.
- The docs are good (and improving), but less thorough than one might hope.  If you're reading through source and you're wondering what `epur` is, head over to google and search for `epur site:urbit.org/docs`.  You can find uses in the reference docs and see if it's used in some example code.
- This can work for glyphs as well, especially if you know the six-letter encoded version of it. So you're reading some source and you come across `:+` ask Mr. Google for `collus site:urbit.org/docs`, and it'll take you right to it.  
- Otherwise, you can put the glyph itself in quotes: `":+" site:urbit.org/docs`, which you might have to do on occasion, since sometimes you'll see two characters that aren't a "proper" glyph.
- For digging through the actual code, ask grep to find it for you.  If you want to know how `epur` is used in the wild, `cd` into your home directory and run `grep -r epur *`.  
- If you just want to go straight to the definition of something, `grep` for
  "++  word".  (Please note, this is two spaces).  
- Also, save yourself a lot of time before you get started by learning the
  following:
    - There are two kinds of "strings".  There's a `cord`, which is a string
      constant, and there's a `tape`, which is a string as a list of
      characters.  Tapes can do string interpolation and parsing.  Cords can't. 
    - If you want to make a cord, use `soq`s, i.e. single quotes.  If you want 
      a tape, use `doq`s, i.e. double quotes.
    - I'd say over 50% of my `nest-fail` errors stemmed from not having figured
      this out sooner.
- Although before you get started on something like this, you should really read through [the arvo tutorials](https://urbit.org/docs/arvo/) and make sure you have [the troubleshooting page](https://urbit.org/docs/hoon/troubleshooting/) handy.

## Stuff I Did to Get It Working

- There's surprisingly little code here, which you're welcome to peruse.  If you'd like to learn about the process for getting something working, some of my stumbling blocks, and lessons learned, read on!
- I spent some time familiarizing myself with API by sending some POSTs via curl and Postman and referring to the docs about [sending messages](https://www.twilio.com/docs/api/rest/sending-messages).
- For the app, first thing we'll need is a security driver.  Read through Twilio documentation about their [REST API](https://www.twilio.com/docs/api/rest) to figure out what they're using.
- They're using HTTP Basic auth.  So I copied sec/com/github.hoon to sec/com/twilio.hoon.
- There's really only one thing that needs to change in this file, which is the test URL.  I dug through the documentation to figure out something generic that would work if you're authenticated and fail otherwise.  In this case `+https://api.twilio.com/2010-04-01/Accounts`
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
- Anyway, in `zuse.hoon` I discover that the moss for hiss is a purl and a moth.  (A moth?)  A `moth` is `{p/meth q/math r/(unit octs)}`.  `meth` is the method, in this case `%post`.  (Being from Oklahoma, when I read `meth`, I tend to think of something else...)  `math` is "semiparsed headers".  And the body apparently gets shunted into a `(unit octs)`.
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

### Part II - The API Connector

- Creating an API connector was a bit tough getting starting.  The docs for Twilio are organized
  topically, which is good if you're oriented towards a task, like, "I want to
  receive a call from my web service, how do I do that?"  If you're more
  wondering, "What all data does Twilio expose that I might find useful?"
- As it happens, I already had this.  The "Account Info" page, i.e. `https://api.twilio.com/2010-04-01/Accounts.json`, lists "subresource_uris".  As it happens, I had never really looked at the contents.  I just saw, "Oh, hey!  I'm logged in now!" and stopped reading.
- As a first pass, I tried getting the list of Messages working i.e. `https://api.twilio.com/2010-04-01/Accounts/{account-id}/Messages.json`.  This is the same URL as we use to send a message, only with a GET.  This would be a quick-and-somewhat-dirty way of listening for responses.  Webhooks would certainly be more responsive, but this can get us up and running.
- (NOTE: running this get from the dojo with +https://... was a poor choice.  I
  was worried I'd crashed my ship for a moment.)
- Actually, the first thing I need to do is build up the API tree, sarting with
  `/` directory.
- I added a `++place` for accounts, which is the next level up.  It occurs to
  me that we don't actually need the `++place`s to mirror the Twilio REST
  structure, but I suspect this will make life easier.
- I got a `peek slam fail` for accounts.  I googled the docs and skimmed the `ford` reference.  We have `slam`, `slap`, `maul`, `maim`.  This Urbit is a very violent system.
- Okay, quick rewind here.  I should first make sure the `gh` app is working.
  Let me connect to that...
- Well, that's something.  Getting the same `peek slam fail` for `gh`.

- Spun my tires for a while trying to get the `gh` app running, or at least
  figure out why it's getting the odd `peek slam fail`.  There are many
  moving parts to this app, most of which I don't understand.  And looking at
  the [repo for arvo](https://github.com/urbit/arvo), it would seem there's a
  new version coming soon.  Thus, time to pivot...

- As a revised first pass, I've decided to add some kind of polling system to the sms app that's already written.  Thus I'll read messages from `Messages.json` and write them to `clay`, if we've had any changes.  

- (Note to self: Make sure this exact thing hasn't already been done.  Seems like mirroring a webpage would be a fairly common use-case)

- In preparation for this, I refactored the app.  I made a pair of marks for the account and a phone number, and a matching pair of generators to set these within the app, and updated the app to make these part of its state.
- Updated the setup above so that you run the generators to set your account
  and your "from" phone number.
- I like this solution much better than editing the generator.  Instead of editing files, the only native Unix you have to do is copy files.  After that, it all happens on your ship.

- (Note to self: There's actually a way to do this entirely natively, not even copying files.  Something to do with making a desk and letting people sync from it.  I'd still want to have my files mirrored on github, on the off chance someone fixes something and wants to do a pull-request.)

- But before doing that, I should probably figure out how to parse JSON.  I'm
  already getting JSON back in the body for the reply to the POST.  If I extracted the message text from that, I wouldn't have to be passing it around with the state.  So that's my next step.

- I was struggling trying to figure out how to get the meaty parts of the `(unit octs)` out so I can turn it into a cord so I can run it through `poja` and parse it.  `grep -r` comes to my aid and notes that `lib/oauth1.hoon` was doing exactly that.  It's a hellacious bit of code, and rather than blindly copying and pasting, I thought I'd make sure I knew what it was doing.

#### A Brief Digression

- Since I love you all, I thought I'd tear this line down and discuss it piece by piece.  There are languages you can kind of grope your way towards getting something to work without quite knowing what you're doing.  Hoon really is not one of those.

```
(rash q.u.bod (more pam (plus ;~(less pam prn))))
```

- Let's start at the very beginning; it's a very good place to start.  If you go to the definition of `rash` in `hoon.hoon` you find this:

```
|*({naf/@ sab/rule} (scan (trip naf) sab))
```

The first thing to note here is that the type for `naf` is `@`, which means 
"any atom".  However, in the source, you see `trip naf`.  Since `trip` is used 
to convert a `cord` (string constant) to a `tape` (string as list of characters), this means that you'll end up with a `nest-fail` if you try to pass it anything but a `cord`.  

So however we use this, we'll have to make sure we're sending it a `cord`.

- If we look at the [docs for `++rash`](https://www.urbit.org/~~/docs/hoon/library/4g/), the description reads:

```
Parse a cord with a given ++rule and crash if the ++cord isn't entirely parsed.
```

(The description also notes that you need a `cord` here.  Sometimes it calls these things out and sometimes it doesn't.)

- And what is a `++rule`?  Elsewhere in `hoon.hoon`, we see it defined thusly:

```
++  rule  _|=(nail *edge)                               ::  parsing rule
```

The `cab` (i.e. `_`) here means "the type of the thing that comes after me".
So `rule` is a type of gate.  (Actually, I had forgotten this detail, but I was
able to look it up in the [irregular forms](https://urbit.org/docs/hoon/irregular/) list.  Apparently this is the short version of a [`$_` or `:buccab`](https://urbit.org/docs/hoon/twig/buc-mold/cab-shoe/) which makes a `shoe`.) 

- So, looking a bit further down the rabbit-hole, we see that a nail and edge
  are defined as:

```
++  nail  {p/hair q/tape}                               ::  parsing input
++  edge  {p/hair q/(unit {p/* q/nail})}                ::  parsing output
```

At this point, we can look up what a `hair` is, or take the comments at face value and just accept that they're parsing inputs and outputs, respectively.  Since we're just using a `rule` and not actually writing one, hopefully this will suffice.  If not, we'll dig deeper.

- The last part is the `*` in front of the `edge`.  I am not sure quite what the star does.  The sensible answer would be that it's shorthand for a list, but developing in Urbit has a slightly different version of "sensible".  In any case, let's roll with what we know now.

- Wait, where were we?  Oh, yes.  `rash`.  So our two inputs seem to be an atom (which actually has to be a `cord`) and a `rule`.  

- Back in `oauth1.hoon`, we were sending `rash` `q.u.bod`.  If you're used to a
  C-derived language, this works backwards from what you're expecting.  You can
  read it as "q from in u from in bod".  

- So what are `q` and `u`?  `bod` is a `(unit octs)`.  So if we look up `++unit` in `hoon.hoon` we see this:

```
++  unit  |*  a/mold                                    ::  maybe
          $@($~ {$~ u/a})                               ::
```

- So the `u` is the data part of the `unit`.  This is a more direct way of getting at data than using `need`, and will apparently give you back the correct 
type.  Since it's a `(unit octs)`, `u` will give us our `octs`.  

- `octs` is defined is `zuse.hoon`:

```
++  octs  {p/@ud q/@t}                                  ::  octet-stream
```

In [the page for `taco`](https://urbit.org/~~/docs/hoon/library/zuse/gate/taco/) that `taco`

```
Converts an atom to an octet stream ++octs, which contains a length, to encode trailing zeroes.
```

If we read the example, we see:

```
~zod/try=> (taco 'abc')
[p=3 q=6.513.249]
~zod/try=> `@t`6.513.249
'abc'
```

So apparently the `q` in the `octs` is the encoded data.  

- If you were writing your own parser and you needed to extract the meaty bits of data from a `(unit octs)`, how will you know which letters to use?  You'll just have to dig through `hoon.hoon` and `zuse.hoon` to find it.

- Now that we've got that sorted out, we can start looking at the `rule`.  Starting with `more`.  

The source reads:
```
++  more
  |*  {bus/rule fel/rule}
  ;~(pose (most bus fel) (easy ~))
::
```

Um...  Not particularly helpful.  What's this `;~`?  Apparently it's a [Kleisli arrow](https://urbit.org/~~/docs/hoon/twig/sem-make/sig-dip/).  I've heard this term before once, but couldn't define it at gunpoint.

The [docs for `hoon.hoon`](https://urbit.org/~~/docs/hoon/library/4f/) describe it as:

```
++more
Parse list with delimiter

Parser modifier: Parse a list of matches using a delimiter ++rule.
```

It also notes that it takes two rules and returns another rule.  Okay, let's move on and see what else we have.  Then we'll loop back and see how `more` will glue these rules together.

- If you looked up `pam`, you'll see it defined as `(just '&')`. Oh, right.  _That_ `pam`.  

And `just` takes a single character and creates a rule out of it.  So, the first rule matches the ampersand character.

- Our next rule starts out with `plus`.  `hoon.hoon` defines `plus` as:

```
++  plus  |*(fel/rule ;~(plug fel (star fel)))
```

Great.  More Kleisli arrows.  Let's check the docs.

[In the docs](https://urbit.org/~~/docs/hoon/library/4f/) we see `++plus` defined as:

```
++plus
List of at least one match.

Parser modifier: parse ++list of at least one match.
```

Given that we're doing parsing, I'm going to work under the assumption that `plus` works like `+` in a regex.  Also, I noted that comment for `++star` says ":: 0 or more times".

- What's next?  Oh, crap, there's that `semsig` again.  

I was trying to avoid learning category theory.  Hmm...

The [page for this rune](https://urbit.org/~~/docs/hoon/twig/sem-make/sig-dip/), aka `:dip`, says we have two parameters, p and q.  q is a list of gates and p is "glue" for connecting each of the results from q.

So looking at our twig:

```
;~(less pam prn)
```

The `p` is be `less`, and `q` is `pam` and `prn`.

- The code for `less` in `hoon.hoon` is opaque.  The comment says "::  no first
  and second".  Looking at [the
  docs](https://urbit.org/~~/docs/hoon/library/4e/) the description reads:
  "Parse unless".   It takes an edge (which is a parser output, as we found out
  above) and a rule.  

- `pam` we've already covered.  `++prn` is a rule for "any printable character".  
- To be honest, I'm really not sure what this twig is doing.  My working theory
  is that it's saying, in English, "parse, unless you come across an ampersand.
  Otherwise, accept any printable character".

  It kinda seems like there ought to be an easier way to do this, but I don't
  know.  Maybe not.

- Anyway, our rule was started with `++more`.  (It's possibly kinda starting
  to fall into place here.) `more` says "Parse a list with a delimiter".  The
  delimiter is the `pam`.  The rule is "one or more matches of some character
  that isn't an ampersand".  
  
- I surmise that this will parse any cord, unless it contains unprintable characters, or consecutive ampersands.  And it will return a list of matches with the ampersands stripped out.

- And to put all this together, the `rash` will run the body's unwrapped data
  through this parser.  

```
(rash q.u.bod (more pam (plus ;~(less pam prn))))
```

So, our puts for this gate we're making a tape and passing it into parsing 
rules.





- And what is a `++rule`?  Looking at the examples, it seems to be some kind of function that we feed our `cord` to.  The good news is we're just understanding this, and not writing our own.  Not yet, at least.
- 



Takes an atom and a `rule` and 


- There doesn't seem to be any good way to 
- 

- As a very first step, I'm making a `++poke-atom` arm. You poke it with a
  command and it performs a specific GET.




## Up next

- Right now we can make a text message.  What happens if someone writes back? Well, it goes in a black hole.  To actually get replies and maybe do something
  with them, we'd need an API connector with a webhook setup.
- Once that's setup, we can read the account number and the phone number from within the account info, and won't need to pass that into the app directly
  (necessarily).  Although asking people to hack one file isn't exactly the Spanish Inquisition, but still.

