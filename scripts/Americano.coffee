class Injector
    ### Injector class

        Allows you to register singletons for use throughout the application. 
        The first line should define an instance of your Injector

        > INJECTOR = new Injector

        and you can register functions with:

        -> INJECTOR.register('singletonGetter', -> )
    ###
    
    register: (name, factory) ->
        ### Register a factory with the Injector
        
            @param {string} name A name for the singleton getter
            @param {function} factory A factory  
        ###
        @[name] = factory

class EspressoMachine
  # GWT-Style Injection Machine.
  # Based off code from https://gist.github.com/998920 cc: bremac
    
  constructor: (dict) ->
    @extend(dict)

  extend: (dict) ->
    for k, v of dict
      @[k] = v
    @
  
  register: (name, factory) ->
    @[name] = factory
  
  create: (type) ->
    if type.PRESS
      pressArgs = []
      for name, factory of type.PRESS
        pressArgs.push @[factory](@)
      typeInstance = new type(pressArgs...)
    else
      typeInstance = new type()
    
    @inject(typeInstance, type.INJECT)

  inject: (obj, dict) ->
    if dict?
      for name, factory of dict
        obj[name] = @[factory](@)
    obj.esm = @
    obj
    
class EventBus
    ### Event Bus class
        Keeping track of events, and firing events in the global scope
        in hopes that someone is listening on 'window' for the event
    ###
    
    constructor: () ->

    fire: (eventName, data) ->
        ### FIRE EVENT-PEDOS
        
            @param {string} eventName The name of the event you wish to fire
            @param {Object} data The data you wish for the event to receive
        ###
        
        e = document.createEvent "Event"
        e.initEvent(eventName, true, true)
        e.data = data
        window.dispatchEvent e

    addHandler: (eventName, callback) ->
        ### Add a generic event handler to the global scope. 
            Keep track of it on your own, because a remove is not supported.
        ###
        window.addEventListener(eventName, callback, false)

class Logger
    ### Hey Look, a handy-dandy logger.
    
        TODO: make me awesomer
    ###
    
    constructor: () ->

    defaultLogThreshold = 2;

    log: (message, logLevel) ->
        ### log a message with an optional log level
        
            @param {string} message The message to log
            @param {int} logLevel How much of an ermergency is it?
        ###
        msg = message
        if logLevel > defaultLogThreshold
            message += "!"
        console.log msg

class Handler
    ### Handler Class
        
        A Generic event handler wrapper around managing an event.
        Allows you to maintain it's stickyness to the scope and fire it.
    ###
    
    constructor: (@name, @scope, @handler) ->
        ### 
            @param {string} name The name of the event the handler will handle
            @param {Object} scope Where should one bind this event handler? to the window? to the wall?
            @param {Function} handler The event handler function
        ###
        
    bind: () ->
        # Bind the handler function to the scope
        @scope.addEventListener(@name, @handler, false)
    
    remove: () ->
        # Take the handler away from the scope
        if @scope
            @scope.removeEventListener(@name, @handler, false)        
            
    call: (data) ->
        # FIRE CALL-PEDOS
        @handler(data)

class Presenter
    ### Presenter Class
        
        You should subclass this guy for your Presenter Implementation.
        The Presenter is the man in the middle between your Model and your 
        Display. 
        All events 
    ###

    constructor: (@display) ->
        @bound = false
        @handlers = {}
    
    getDisplay: () -> @display

    onBind: () ->
        alert "Unimplemented"

    bind: () ->
        ### The method to call to put the processing gears into action and
            bind all the events
        ###
        @onBind()
        @bound = true

    unbind: () ->
        ### Disables all event handlers from the presenter
        ###
        @bound = false
        for name, hndlrs of @handlers
            for hndlr in hndlrs
                hndlr.remove()
        @handlers = {}

    registerHandler: (name, scope, handler) ->
        ### Registers an event handler with the Presenter with the option 
            of scoping it strictly to the presenter, globally, or an element
        
            @param {string} name Name of the event
            @param {boolean | window | Element} scope You decide.
            @param {Function} handler The event handler
        ###
        hndlr = new Handler(name, scope, handler)

        if scope and typeof scope is "object"
            hndlr.bind()
        else if scope
            # if the scope is set to "true", we want to register the event globally
            hndlr.scope = window
            hndlr.bind()

        @handlers[name] = [] if !@handlers[name]?    
        @handlers[name].push hndlr        
            
    unregisterHandler: (name) ->
        ### Removes all handlers from this presenter under an event name
        
            @param {string} name The name of the event you want to remove
        ###
        for nm, hndlrs of @handlers
            if nm == name
                for hndlr in hndlrs
                    hndlr.remove()
                @handlers[nm] = []

    fireHandler: (name, data) ->
        ### FIRE HANDLE-PEDOS
            
            @param {string} name The event name to fire
            @param {Object} data The data to pass with your event
        ###
        for nm, hndlrs of @handlers
            if nm == name
                for hndlr in hndlrs
                    hndlr.call({data:data})
                    
class Display
    ### Display Class
    
        I'm the interface.
        I display the data from the model and provide hooks to the Presenter
        to reach DEEP inside of me to handle events that I might fire. I should
        not format data, or ever talk directly to a model.
    ###
    asWidget: -> "unimplemented"
