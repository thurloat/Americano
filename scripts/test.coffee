
INJECTOR = new Injector

class MainPresenter extends Presenter

    on_bind: () ->

        @register_handler "error", true, (event) ->
            INJECTOR.get_logger().log("ERROR: " + event.data, 5)

        @register_handler "click", @display.get_alert_button(), (event) ->
            INJECTOR.get_event_bus().fire "display_message", "alert button clicked"

class MainDisplay extends Display

    container = $('<div/>')

    constructor: () ->
        @button = $('<input/>', {type: 'submit'})
        @button.appendTo(container)

    get_alert_button: -> @button[0]

    as_widget: -> container

class MessageCentre extends Presenter

    on_bind: () ->
        @register_handler "display_message", true, (event) =>
            console.log("displaying message?")
            @display.show_message(event.data)

class MessageCentreDisplay extends Display

    container = $('<div/>')

    constructor: () ->
        @num_messages = 0
        @message_holder = $('<h1/>')
        @message_holder.appendTo(container)

    show_message: (message) ->
        @message_holder.animate opacity: '0.5'

        @message_holder.text message + @num_messages

        @num_messages += 1

        @message_holder.animate opacity: '1.0'

    as_widget: -> container

class Application

    event_bus = new EventBus()
    logger = new Logger()

    run: ->
        INJECTOR.register("get_event_bus", -> return event_bus)
        INJECTOR.register("get_logger", -> return logger)
        INJECTOR.register("get_root_panel", -> return $("#application"))

        main_presenter = new MainPresenter(new MainDisplay())
        main_presenter.bind()

        message_presenter = new MessageCentre(new MessageCentreDisplay())
        message_presenter.bind()

        event_bus.fire('display_message', "Globally Listening ... ");

        INJECTOR.get_root_panel().append(main_presenter.get_display().as_widget())
        INJECTOR.get_root_panel().append(message_presenter.get_display().as_widget())

$(document).ready ->

    app = new Application()

    if window
        window.APP = app
    app.run()
