class NotePresenter extends Presenter
  
  @PRESS =
    display: 'noteDisplayType'
  
  @INJECT =
    eventBus: 'getEventBus'
    logger: 'getLogger'
    DB: 'getDB'
    
  onBind: () ->
    
    # Register a handler for the 'newNote' event to set display up for a new 
    # note object
    @registerHandler "newNote", true, (event) =>

      # Create a new note with an empty object
      @setNote
        title: ''
        body: ''
    
    # Register a handler with the 'loadNote' event to change the note being
    # edited to the one in the event data.  
    @registerHandler "loadNote", true, (event) =>

      @setNote event.data
      
      # Pass along a notification to mention that the new note has loaded.
      @eventBus.fire('notify', message: "Loaded Note:" + event.data.title)
      
    # Register a handler on the save button's 'click' to save the note being
    # edited right now.
    @registerHandler "click", @display.getSaveButton(), (event) =>
      
      # Set the data and insert the record into the database.
      @note.title = @display.getTitleBoxValue()
      @note.body = @display.getBodyBoxValue()
      
      @DB.save @note, =>
        
        # Since data is stale now, fire a 'refreshDisplay' event so any 
        # presenter that needs to update it's info can do so with freshness.
        @eventBus.fire("refreshDisplay")
        
        # Send out a notification telling the user that the note saved 
        # correctly.
        @eventBus.fire("notify", message: "Note Saved")
      
    @registerHandler "refreshDisplay", true, (event) =>
      @fireHandler "newNote"
      
  setNote: (note) ->
    # Set current note to the one provided.
    @note = note
    @display.setTitleBoxValue note.title
    @display.setBodyBoxValue note.body

class NoteDisplay extends Display
  # NoteDisplay class is the Editor for a note.  
    
  constructor: () ->
    
    @container = $('<div/>', class:'editor')
    
    $('<h2/>', text: 'Note Editor').appendTo @container
    
    # Title text box
    $('<h4/>', text: 'Title').appendTo @container
    @titleBox = $('<input/>', {type: 'text'})
    @titleBox.appendTo @container
      
    # Body text area
    $('<h4/>', text: 'Body').appendTo @container
    @bodyBox = $('<textarea/>')
    @bodyBox.appendTo @container
      
    # Save button
    @saveButton = $('<input/>', {type: 'submit', value: 'Save'})
    @saveButton.appendTo @container
      
  getSaveButton: -> @saveButton[0]
      
  getTitleBoxValue: -> @titleBox.val()
  setTitleBoxValue: (title) -> @titleBox.val(title)  
    
  getBodyBoxValue: -> @bodyBox.val()
  setBodyBoxValue: (body) -> @bodyBox.val(body)
      
  asWidget: -> @container[0]

class NoteListPresenter extends Presenter
  # This NoteListPresenter manages a list of notes for the user.
  
  @PRESS =
    display: 'noteListDisplayType'
  
  @INJECT =
    eventBus: 'getEventBus'
    logger: 'getLogger'
    DB: 'getDB'
    
  onBind: () ->
    @notes = []
    
    @registerHandler "click", @display.getNewNoteButton(), (event) =>
      # Create a new note, and push a notification saying so.
      @eventBus.fire("newNote", null)
      @eventBus.fire('notify', message: "Creating New Note")
    
    @registerHandler "noteClicked", true, (event) =>
      # Listen to the child NodeListItemPresenters for a noteClicked event
      # and pass on the loadNote message through the event bus with the note
      @eventBus.fire("loadNote", event.data.note)
      
    @registerHandler "noteDeleteClicked", true, (event) =>
      
      @eventBus.fire "notify", message: "Deleting Note"
      @DB.remove event.data.note.key, => 
        @eventBus.fire "refreshDisplay"
    
    @registerHandler "refreshDisplay", true, (event) =>
      # Register a handler for refreshing the display when data is stale.
      @refresh()
    
    @refresh()
  
  refresh: () ->
    # Refresh the display by fetching fresh data.
    
    for note in @notes
      note.unbind()
    
    @notes = []
    @display.clearNotes()
    
    @DB.all (notes) =>
      for note in notes
        @addNote(note)
    
  addNote: (note) ->
    # Add a new note to the note list by creating a NoteListItemPresenter, and
    # adding it's widget to the display.
     
    np = @esm.create(NoteListItemPresenter)
    np.setNote note
    np.bind()
    
    @display.addNote np.getDisplay().asWidget()
    @notes.push np

    
class NoteListDisplay extends Display
  # The NoteListDisplay displays the managed unordered list of notes in the UI
  # Nothing special here.
  
  
  constructor: () ->
    @container = $('<div/>', class: 'noteList')
    
    @noteWidgets = []
    $('<h2>', text: 'My Notes').appendTo @container
    @newButton = $('<input/>', {type: 'submit', value: 'New Note'})
    @newButton.appendTo(@container)
    @noteList = $('<ul/>').appendTo @container
    
  getNoteList: -> @noteList[0]
  getNewNoteButton: -> @newButton[0]
  
  addNote: (noteWidget) ->
    @noteList.append noteWidget
    @noteWidgets.push noteWidget
    
  clearNotes: () ->
    @noteWidgets = []
    @noteList.empty()
    
  asWidget: -> @container[0]

class NoteListItemPresenter extends Presenter
  # Presenter to handle the management of a Note List Item
  @PRESS =
    display: 'noteListItemDisplayType'
  
  @INJECT =
    eventBus: 'getEventBus'
    logger: 'getLogger'
    DB: 'getDB'
    
  # constructor: (@note, display) ->
  #   # Here, we pass the note in as an arg to the constructor,
  #   # and call the parent's constructor
  #   super display
  
  setNote: (@note) ->
  
  onBind: ->
    
    # Register a click handler for the display's list item
    @registerHandler "click", @display.getListItem(), (event) =>
      # Fire the 'noteClicked' message on the event bus, so the NotePresenter
      # will hear it.
      
      @eventBus.fire 'noteClicked', note: @note
    
    @registerHandler "click", @display.getDeleteButton(), (event) =>
      
      @eventBus.fire 'noteDeleteClicked', note: @note
    
    @display.setText @note.title

class NoteListItemDisplay extends Display
  # NoteListItemDisplay is EXTRA nothing special.
   
  constructor: () ->
    @container = $('<li/>')
    @noteLabel = $('<span/>').appendTo @container
    
    deleteParams = 
      class: 'delete'
      text: 'x'
    
    @deleteButton = $('<span/>', deleteParams)
    @deleteButton.appendTo @container
    
  getListItem: -> @noteLabel[0]
  
  getDeleteButton: -> @deleteButton[0]
  
  setText: (text) -> @noteLabel.text text
  
  asWidget: -> @container[0]

class NotificationPresenter extends Presenter
  # Simple Notification Window that will listen to 'notify' and display the message
  
  @PRESS =
    display: 'notificationDisplayType'
  
  @INJECT =
    eventBus: 'getEventBus'
    logger: 'getLogger'
    DB: 'getDB'
    
  onBind: ->
      
    # Listen to 'notify' globally
    @registerHandler "notify", true, (event) =>
      
      # Display the message & animate
      @display.setText(event.data.message)
      @display.flashMessage()

class NotificationDisplay extends Display
  # Notification Display Widget
  
  constructor: ->
    @showingMessage = false
    
    @container = document.createElement "div"
    @container.setAttribute 'class', 'notification'
    
    @notification = document.createElement "span"
    @notification.innerText = 'waiting on notifications'
    
    @container.appendChild @notification
    
  flashMessage: ->
    # Fancy message flashing
    if @showingMessage is false
      @showingMessage = true
      $(@container).animate opacity: 'toggle', 250, =>
        $(@container).animate opacity: 'toggle', 1500, =>
          @showingMessage = false


  setText: (text) -> @notification.innerText = text
  asWidget: -> @container

class Application
  
  esp = new EspressoMachine()
  eventBus = new EventBus()
  logger = new Logger()
  db = new Lawnchair "Notes", -> console.log("Database Loaded.")

  hasRun = false

  run: ->
    if hasRun
      console.log "run"
      return false
    hasRun = true
    # Register shared objects in the injector registry
    esp.register("getEventBus", -> eventBus)
    esp.register("getLogger", -> logger)
    esp.register("getRootPanel", -> document.getElementById "application" )
    esp.register("getDB", -> db)
        
    # Singleton displays
    noteDisplay = new NoteDisplay
    noteListDisplay = new NoteListDisplay
    notificationDisplay = new NotificationDisplay
    
    # Register the display types
    esp.register('noteDisplayType', -> noteDisplay)
    esp.register('noteListDisplayType', -> noteListDisplay)
    esp.register('notificationDisplayType', -> notificationDisplay)
    esp.register('noteListItemDisplayType', -> new NoteListItemDisplay)
    
    # Create the presenters with all the stuff injected
    notePresenter = esp.create(NotePresenter)
    noteListPresenter = esp.create(NoteListPresenter)    
    notificationPresenter = esp.create(NotificationPresenter)
    
    # Bind all of the presenters
    notePresenter.bind()
    noteListPresenter.bind()
    notificationPresenter.bind()
    
    # Insert the presenter's display widgets into the DOM
    esp.getRootPanel().appendChild notificationPresenter.getDisplay().asWidget()
    esp.getRootPanel().appendChild notePresenter.getDisplay().asWidget()    
    esp.getRootPanel().appendChild noteListPresenter.getDisplay().asWidget()

window.ready ->

  app = new Application
  if window
    window.APP = app
  app.run()
