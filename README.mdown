
    
       _____                                     )
      (, /  |                ,                  (   )
        /---| ___    _  __     _  _  __   ___  __)_(__
     ) /    |_// (__(/_/ (__(_(__(_(_/ (_(_)   \     /
    (_/                                         \   /_)
                                                 \_/
## Adding P to your .coffee

*Americano* takes a shot at being one of those new-fangled Micro-JS-Frameworks. The goal of the project is to allow any Coffeescript developer to create an MVP style application without locking them into how they like to implement Widgets or Models.

It's really just the **P**

Americano is a based on the GWT-Presenter project and it's implementation in the SheepdogInc.ca [project gTrax](http://app.gtraxapp.com/). 

Framework Code is in **Americano.coffee** in *scripts*

 - A very basic sample exists in **test.coffee**
 - A more potent example is in **notes.coffee**
 
# Sample Application: *Americanotes* #

As an example of how "Just the **P**" Americano is; I created a sample application called "Americanotes". Just a simple application to create, edit notes, stored in your browser. *Handy*!

Here's a Quick [video demo](http://screencast.com/t/6w3SUAL0Uw) of Americanotes in action.

A quick breakdown here shows the pieces pulled together for this app:

### Model - Lawnchair.js ###

All of the model code is written with Lawnchair, nothing in Americano to help with this; yet everything works smoothly.

### View - Nothing Special? ###

The widgets, DOM manipulation, and building are all done with standard Javascript. Animation of the Notification window is done with [emile.js](http://github.com/madrobby/emile). At anytime, you can pull it out and replace it with whatever more feature rich DOM framework that you like most! That's the beauty.

### Presenter - Americano ###

Enough said.

# Compile Steps

Compile steps have been put into `build.sh` because Coffeescript was clobbering the JS when it would over-write the old one.

    ./build.sh