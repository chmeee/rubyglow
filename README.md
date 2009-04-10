# Rubyglow

rubyglow is a ruby version of perl visualization software
[afterglow](http://afterglow.sf.net)

## Motivation

I like afterglow and I like security visualization but I don't like perl and I
feel I want to mess with afterglow code and can't. So I decided to rewrite
everything in ruby.

## State and plans

At the moment every script from afterglow has been translated except for the
main program in `graph/`.

At the moment I've tried to make a direct translation in order to understand the
scripts and not change too much. The next step is to reshape everything in a
more object oriented and flexible way. So much to factorize...

At the moment I'm thinking about what to do with the properties file. In the
original afterglow this file can have perl code, so `afterglow.rb` will no
longer be compatible.

That's why i'm left with two options:

* Do the same thing as original afterglow, using eval
* Create a DSL to describe the propierties

I guess the second option is more in the ruby way.
