INJECTOR = new Injector
        
class MainPresenter extends Presenter

    on_bind: () ->
        
        @register_handler("error", (event) ->
            INJECTOR.get_logger().log("ERROR: " + event.data, 5)
        , true)
        
        @register_handler('display_message', (event) ->
            INJECTOR.get_logger().log(event.data, 5)
            INJECTOR.get_event_bus().fire("error", event.data)
        , true)
        
        @register_handler("click", (event) -> 
            INJECTOR.get_event_bus().fire("error", "alert button clicked")
        , @display.get_alert_button())


class MainDisplay extends Display
    
    constructor: () ->
        INJECTOR.get_logger().log(@get_thing)
        
    get_alert_button: () ->
        return $('#alert_popup')[0]

class Application

    event_bus = new EventBus()
    logger = new Logger()

    run: ->
        INJECTOR.register("get_event_bus", -> return event_bus)
        INJECTOR.register("get_logger", -> return logger)
                
        main_presenter = new MainPresenter(new MainDisplay())
        main_presenter.bind()
        
        main_presenter.fire_handler('display_message', "HI!");
        event_bus.fire('display_message', "Globally Listening");
        
        logger.log("Un-binding, you should see no message after this.")
        
        main_presenter.unregister_handler('display_message')
        
        event_bus.fire('display_message', "You can't see me")
        event_bus.fire('error', "You can still see me")


$(document).ready ->
    app = new Application()

    if window
        window.APP = app
    app.run()
    