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

I guess the second option is more in the ruby way. That's why I've come up with
this idea to configure afterglow:

    Afterglow::properties do 
      cluster :event do |fields|
        regex_replace(".*?\\.(.*\\..*)") if (fields[1] !~ /\d+$/
      end
      size :all, 0.2 { |fields| fields[1] =~ /192.*/ }
      color :source, springgreen {|fields| fields[0] =~ /10\./ }
    end

Commands will be:

    color :all :source :target :event :edge :sourcetarget
    size :all :source :target :event
    threshold :all :source :event :target
    shape :source :target :event
    sum :source :target :event
    label :source :target :event
    url
    cluster :source :target :event
    maxnodesize
    variable
    exit


