# **Americano** takes a shot at being one of those new-fangled Micro-JS-Frameworks.
# The goal of the project is to allow any Coffeescript developer to create an
# MVP style application without locking them into how they like to implement
# Widgets or Models.
#
##### It's really just the "P" #####

# **Americano** is a based on the GWT-Presenter project and it's implementation
# in the SheepdogInc.ca [project gTrax](http://app.gtraxapp.com/). 

# The [source for Americano](http://github.com/thurloat/Americano) is available
# on GitHub, along with examples of how to implement a sample application 
# called *Americanotes*.

#### Still a WIP ###

# You can help! Please submit feature requests and bug reports to GitHub Issues,
# or even better, Fork the project and submit a pull request! Good Luck!


## The Codes ##

### Presenter Class ###
# You should subclass this guy for your Presenter Implementation.
# The Presenter is the man in the middle between your Model and your 
# Display. 
# All events 

class Presenter

    constructor: (@display) ->
        @bound = false
        @handlers = {}
    
    #####getDisplay###
    # Get the bound display for the presenter.
    getDisplay: () -> @display

    #####bind###
    # The method to call to put the processing gears into action and
    # bind all the events   
    bind: () ->
        @onBind()
        @bound = true

    #####ensureBound#####
    # Makes sure the presenter is bound, if not it will call bind for you
    ensureBound: () ->
        if not @bound
          @bind()
        
    #####onBind#####
    # Shoddy interface. `:P`
    onBind: () ->
        alert "Unimplemented"
        
    #####unbind#####
    # Disables, and removes all event handlers from the presenter
    unbind: () ->
        @bound = false
        for name, hndlrs of @handlers
            for hndlr in hndlrs
                hndlr.remove()
        @handlers = {}
    
    #####registerHandler#####
    # Registers an event handler with the Presenter with
    # the option of scoping it strictly to the presenter, globally, or an 
    # element
    #
    # @param {*string*} `name` Name of the event
    #
    # @param {*boolean | window | Element*} `scope` You decide.
    #
    # @param {*Function*} `handler` The event handler
    registerHandler: (name, scope, handler) ->
        hndlr = new Handler(name, scope, handler)

        if scope and typeof scope is "object"
            hndlr.bind()
        else if scope
            # if the scope is set to "true", we want to register the event 
            # globally
            hndlr.scope = window
            hndlr.bind()

        @handlers[name] = [] if !@handlers[name]?    
        @handlers[name].push hndlr        
        
    #####unregisterHandler#####
    # Removes all handlers from this presenter under an event name
    #
    # @param {*string*} `name` The name of the event you want to remove    
    unregisterHandler: (name) ->
        for nm, hndlrs of @handlers
            if nm == name
                for hndlr in hndlrs
                    hndlr.remove()
                @handlers[nm] = []

    #####fireHandler#####
    # FIRE HANDLE-PEDOS
    #
    # @param {*string*} `name` The event name to fire
    #
    # @param {*Object*} `data` The data to pass with your event
    fireHandler: (name, data) ->
        for nm, hndlrs of @handlers
            if nm == name
                for hndlr in hndlrs
                    hndlr.call({data:data})

### Display Class ###
# I'm the interface.
# I display the data from the model and provide hooks to the Presenter
# to reach DEEP inside of me to handle events that I might fire. I should
# not format data, or ever talk directly to a model.
class Display
    
    #####asWidget#####
    # You should implement me.
    asWidget: -> "unimplemented"

### Handler Class ###
# A Generic event handler wrapper around managing an event.
# Allows you to maintain it's stickyness to the scope and fire it.

class Handler

    #####constructor#####
    # 
    # @param {*string*} `name` The name of the event the handler will handle
    #
    # @param {*Object*} `scope` Where should one bind this event handler? to 
    # the window? to the wall?
    #
    # @param {*Function*} `handler` The event handler function
    constructor: (@name, @scope, @handler) ->

    #####bind#####
    # Bind the handler function to the scope
    bind: () ->
        @scope.addEventListener(@name, @handler, false)

    #####remove#####
    # Take the handler away from the scope
    remove: () ->
        if @scope
            @scope.removeEventListener(@name, @handler, false)        

    #####call#####
    # FIRE CALL-PEDOS
    call: (data) ->
        @handler(data)


### EventBus ###
# Keeping track of events, and firing events in the global scope in hopes that
# someone is listening on 'window' for the event

class EventBus

    #####fire#####
    # Fire Event-predos, this shoots a new event across the EventBus.
    #
    # @param {*string*} `eventName` The name of the event you wish to fire
    #
    # @param {*Object*} `data` The data you wish for the event to receive
    fire: (eventName, data) ->
        e = document.createEvent "Event"
        e.initEvent(eventName, true, true)
        e.data = data
        window.dispatchEvent e

    #####addHandler#####
    # Add a generic event handler to the global scope. Keep track of it on your
    # own, because a remove is not supported.
    addHandler: (eventName, callback) ->
        window.addEventListener(eventName, callback, false)

### Espresso Machine ###
# GWT-Style Injection Machine.
# 
# Based on a [gist](https://gist.github.com/998920) by: bremac

class EspressoMachine

  #####constructor#####
  # Build a new **EspressoMachine** instance with a default dict of registered
  # factories for the EspressoMachine to inject.
  constructor: (dict) ->
    @extend(dict)

  #####extend#####
  # Extend the **EspressoMachine** instance with the provided list of factories
  extend: (dict) ->
    for k, v of dict
      @[k] = v
    @

  #####register#####
  # Register a new function getter with the esm. It will overwrite any existing
  # registry entries at that key.
  register: (name, factory) ->
    @[name] = factory

  #####create#####
  # Create a new instance of a Type, it will read in dicts from both 
  # decorators `@PRESS`, which puts the args in order into the constructor for
  # the type; and `@INJECT`, which attaches the registered factories to the
  # scope of the Type so all are available via `@registry.foo` in the returned
  # Type object.
  create: (type) ->

    if type.PRESS
      pressArgs = []
      for name, factory of type.PRESS
        pressArgs.push @[factory](@)
      typeInstance = new type(pressArgs...)
    else
      typeInstance = new type()

    @inject(typeInstance, type.INJECT)

  #####inject#####
  # Perform the injection of the dict into the new Type object. An `@esm` is 
  # added to the scope for `@esm.create()` functionality within the created
  # Type.
  inject: (obj, dict) ->
    if dict?
      for name, factory of dict
        obj[name] = @[factory](@)
    obj.esm = @
    obj

### Logger ###
# Hey Look, a handy-dandy logger
# TODO: make me awesomer

class Logger

    #####defaultLogThreshold#####
    # A default log threshold (this doesn't really do anything yet.)
    defaultLogThreshold = 2;

    #####log#####
    # Log a message to the logger.
    #
    # @param {*string*} `message` The message to log
    #
    # @param {*int*} `logLevel` How much of an ermergency is it?
    log: (message, logLevel) ->
        if logLevel > defaultLogThreshold
            message += "!"
        console.log message
