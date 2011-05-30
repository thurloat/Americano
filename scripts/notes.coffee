INJECTOR = new Injector

class NotePresenter extends Presenter
    
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
      INJECTOR.getEventBus().fire('notify', message: "Loaded Note:" + event.data.title)
      
    # Register a handler on the save button's 'click' to save the note being
    # edited right now.
    @registerHandler "click", @display.getSaveButton(), (event) =>
      
      # Set the data and insert the record into the database.
      @note.title = @display.getTitleBoxValue()
      @note.body = @display.getBodyBoxValue()
      
      INJECTOR.getDB().save @note, =>
        
        # Since data is stale now, fire a 'refreshDisplay' event so any 
        # presenter that needs to update it's info can do so with freshness.
        INJECTOR.getEventBus().fire("refreshDisplay")
        
        # Send out a notification telling the user that the note saved 
        # correctly.
        INJECTOR.getEventBus().fire("notify", message: "Note Saved")
      
    @registerHandler "refreshDisplay", true, (event) =>
      @fireHandler "newNote"
      
  setNote: (note) ->
    # Set current note to the one provided.
    @note = note
    @display.setTitleBoxValue note.title
    @display.setBodyBoxValue note.body

class NoteDisplay extends Display
  # NoteDisplay class is the Editor for a note.  
    
  container = $('<div/>', class:'editor')
    
  constructor: () ->
    $('<h2/>', text: 'Note Editor').appendTo container
    
    # Title text box
    $('<h4/>', text: 'Title').appendTo container
    @titleBox = $('<input/>', {type: 'text'})
    @titleBox.appendTo container
      
    # Body text area
    $('<h4/>', text: 'Body').appendTo container
    @bodyBox = $('<textarea/>')
    @bodyBox.appendTo container
      
    # Save button
    @saveButton = $('<input/>', {type: 'submit', value: 'Save'})
    @saveButton.appendTo container
      
  getSaveButton: -> @saveButton[0]
      
  getTitleBoxValue: -> @titleBox.val()
  setTitleBoxValue: (title) -> @titleBox.val(title)  
    
  getBodyBoxValue: -> @bodyBox.val()
  setBodyBoxValue: (body) -> @bodyBox.val(body)
      
  asWidget: -> container

class NoteListPresenter extends Presenter
  # This NoteListPresenter manages a list of notes for the user.
  
  onBind: () ->
    @notes = []
    
    @registerHandler "click", @display.getNewNoteButton(), (event) ->
      # Create a new note, and push a notification saying so.
      INJECTOR.getEventBus().fire("newNote", null)
      INJECTOR.getEventBus().fire('notify', message: "Creating New Note")
    
    @registerHandler "noteClicked", true, (event) ->
      # Listen to the child NodeListItemPresenters for a noteClicked event
      # and pass on the loadNote message through the event bus with the note
      INJECTOR.getEventBus().fire("loadNote", event.data.note)
      
    @registerHandler "noteDeleteClicked", true, (event) ->
      
      INJECTOR.getEventBus().fire "notify", message: "Deleting Note"
      INJECTOR.getDB().remove event.data.note.key, -> 
        INJECTOR.getEventBus().fire "refreshDisplay"
    
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
    
    INJECTOR.getDB().all (notes) =>
      for note in notes
        @addNote(note)
    
  addNote: (note) ->
    # Add a new note to the note list by creating a NoteListItemPresenter, and
    # adding it's widget to the display.
     
    np = new NoteListItemPresenter note, new NoteListItemDisplay()
    np.bind()
    
    @display.addNote np.getDisplay().asWidget()
    @notes.push np

    
class NoteListDisplay extends Display
  # The NoteListDisplay displays the managed unordered list of notes in the UI
  # Nothing special here.
  
  container = $('<div/>', class: 'noteList')
  
  constructor: () ->
    @noteWidgets = []
    $('<h2>', text: 'My Notes').appendTo container
    @newButton = $('<input/>', {type: 'submit', value: 'New Note'})
    @newButton.appendTo(container)
    @noteList = $('<ul/>').appendTo container
    
  getNoteList: -> @noteList[0]
  getNewNoteButton: -> @newButton[0]
  
  addNote: (noteWidget) ->
    @noteList.append noteWidget
    @noteWidgets.push noteWidget
    
  clearNotes: () ->
    @noteWidgets = []
    @noteList.empty()
    
  asWidget: -> container

class NoteListItemPresenter extends Presenter
  # Presenter to handle the management of a Note List Item
  
  constructor: (@note, display) ->
    # Here, we pass the note in as an arg to the constructor,
    # and call the parent's constructor
    super display
  
  onBind: ->
    
    # Register a click handler for the display's list item
    @registerHandler "click", @display.getListItem(), (event) =>
      # Fire the 'noteClicked' message on the event bus, so the NotePresenter
      # will hear it.
      
      INJECTOR.getEventBus().fire 'noteClicked', note: @note
    
    @registerHandler "click", @display.getDeleteButton(), (event) =>
      
      INJECTOR.getEventBus().fire 'noteDeleteClicked', note: @note
    
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
    
    @container = $('<div/>', class: 'notification')  
    @notification = $('<span/>', text: 'waiting on notifications')
    @notification.appendTo @container
    
  flashMessage: ->
    # Fancy message flashing
    if @showingMessage is false
      @showingMessage = true
      @container.animate opacity: 'toggle', 250, =>
        @container.animate opacity: 'toggle', 1500, =>
          @showingMessage = false


  setText: (text) -> @notification.text text
  asWidget: -> @container[0]

class Application

  eventBus = new EventBus()
  logger = new Logger()
  db = new Lawnchair "Notes", ->
    console.log("Database Loaded.")

  run: ->
    # Register shared objects in the injector registry
    INJECTOR.register("getEventBus", -> eventBus)
    INJECTOR.register("getLogger", -> logger)
    INJECTOR.register("getRootPanel", -> $("#application"))
    INJECTOR.register("getDB", -> db)

    # Create and bind all of the presenters for this application
    notePresenter = new NotePresenter(new NoteDisplay())
    notePresenter.bind()
        
    noteListPresenter = new NoteListPresenter(new NoteListDisplay())
    noteListPresenter.bind()
    
    notificationPresenter = new NotificationPresenter(new NotificationDisplay())
    notificationPresenter.bind()
        
    # Insert the presenter's display widgets into the DOM
    INJECTOR.getRootPanel().append(notificationPresenter.getDisplay().asWidget())
    INJECTOR.getRootPanel().append(notePresenter.getDisplay().asWidget())
    INJECTOR.getRootPanel().append(noteListPresenter.getDisplay().asWidget())

$(document).ready ->

  app = new Application
  if window
    window.APP = app
  app.run()
