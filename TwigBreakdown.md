# A Brief Digression

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
