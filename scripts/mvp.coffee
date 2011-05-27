class Injector
    
    register: (name, factory) ->
        @[name] = factory


class EventBus
    
    constructor: () ->

    fire: (event_name, data) ->
        e = document.createEvent "Event"
        e.initEvent(event_name, true, true)
        e.data = data
        window.dispatchEvent e

    add_handler: (event_name, callback) ->
        window.addEventListener(event_name, callback, false)

class Logger
    
    constructor: () ->

    default_log_threshold = 2;

    log: (message, log_level) ->
        msg = message
        if log_level > default_log_threshold
            message += "!"
        console.log msg

class Handler
    
    constructor: (@name, @handler, @scope) ->
        
    bind: () ->
        @scope.addEventListener(@name, @handler, false)
    
    remove: () ->
        if @scope
            @scope.removeEventListener(@name, @handler, false)        
            
    call: (data) ->
        @handler(data)

class Presenter

    constructor: (@display) ->
        @bound = false
        @handlers = {}

    on_bind: () ->
        alert "Unimplemented"

    bind: () ->
        @on_bind()
        @bound = true

    unbind: () ->
        @bound = false
        for name, hndlrs of @handlers
            for hndlr in hndlrs
                hndlr.remove()
        @handlers = {}

    register_handler: (name, handler, scope) ->
        
        hndlr = new Handler(name, handler, scope)

        if scope and typeof scope is "object"
            hndlr.bind()
        else if scope
            hndlr.scope = window
            hndlr.bind()

        @handlers[name] = [] if !@handlers[name]?    
        @handlers[name].push hndlr        
            
    unregister_handler: (name) ->
        for nm, hndlrs of @handlers
            if nm == name
                for hndlr in hndlrs
                    hndlr.remove()
                @handlers[nm] = []

    fire_handler: (name, data) ->
        for nm, hndlrs of @handlers
            if nm == name
                for hndlr in hndlrs
                    hndlr.call({data:data})
                    

class Display

    constructor: () ->
        @thing = "foo"

    as_widget: () ->
        return "unimplemented"