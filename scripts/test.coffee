
INJECTOR = new Injector

class MainPresenter extends Presenter

    onBind: () ->

        @registerHandler "error", true, (event) ->
            INJECTOR.getLogger().log("ERROR: " + event.data, 5)

        @registerHandler "click", @display.getAlertButton(), (event) ->
            INJECTOR.getEventBus().fire "displayMessage", "alert button clicked"

class MainDisplay extends Display

    container = $('<div/>')

    constructor: () ->
        @button = $('<input/>', {type: 'submit'})
        @button.appendTo(container)

    getAlertButton: -> @button[0]

    asWidget: -> container

class MessageCentre extends Presenter

    onBind: () ->
        @registerHandler "displayMessage", true, (event) =>
            console.log("displaying message?")
            @display.showMessage(event.data)

class MessageCentreDisplay extends Display

    container = $('<div/>')

    constructor: () ->
        @numMessages = 0
        @messageHolder = $('<h1/>')
        @messageHolder.appendTo(container)

    showMessage: (message) ->
        @messageHolder.animate opacity: '0.5'

        @messageHolder.text message + @numMessages

        @numMessages += 1

        @messageHolder.animate opacity: '1.0'

    asWidget: -> container

class Application

    eventBus = new EventBus()
    logger = new Logger()

    run: ->
        INJECTOR.register("getEventBus", -> return eventBus)
        INJECTOR.register("getLogger", -> return logger)
        INJECTOR.register("getRootPanel", -> return $("#application"))

        mainPresenter = new MainPresenter(new MainDisplay())
        mainPresenter.bind()

        messagePresenter = new MessageCentre(new MessageCentreDisplay())
        messagePresenter.bind()

        eventBus.fire('displayMessage', "Globally Listening ... ");

        INJECTOR.getRootPanel().append(mainPresenter.getDisplay().asWidget())
        INJECTOR.getRootPanel().append(messagePresenter.getDisplay().asWidget())

$(document).ready ->

    app = new Application()

    if window
        window.APP = app
    app.run()
