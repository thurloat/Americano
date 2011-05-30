INJECTOR = new Injector

class NotePresenter extends Presenter
    
  on_bind: () ->
    
    # Register a handler for the 'new_note' event to set display up for a new 
    # note object
    @register_handler("new_note", (event) =>

      # Create a new note with an empty object
      @set_note
        title: ''
        body: ''
    , true)
    
    # Register a handler with the 'load_note' event to change the note being
    # edited to the one in the event data.  
    @register_handler("load_note", (event) =>

      @set_note event.data
      
      # Pass along a notification to mention that the new note has loaded.
      INJECTOR.get_event_bus().fire('notify', message: "Loaded Note:" + event.data.title)
    
    , true)
      
    # Register a handler on the save button's 'click' to save the note being
    # edited right now.
    @register_handler("click", (event) =>
      
      # Set the data and insert the record into the database.
      @note.title = @display.get_title_box_value()
      @note.body = @display.get_body_box_value()
      
      INJECTOR.get_db().save(@note, =>
        
        # Since data is stale now, fire a 'refresh_display' event so any 
        # presenter that needs to update it's info can do so with freshness.
        INJECTOR.get_event_bus().fire("refresh_display")
        
        # Send out a notification telling the user that the note saved 
        # correctly.
        INJECTOR.get_event_bus().fire("notify", message: "Note Saved")
      )
    , @display.get_save_button())
      
  set_note: (note) ->
    # Set current note to the one provided.
    
    @note = note
    @display.set_title_box_value note.title
    @display.set_body_box_value note.body

class NoteDisplay extends Display
  # NoteDisplay class is the Editor for a note.  
    
  container = $('<div/>', class:'editor')
    
  constructor: () ->
    $('<h2/>', text: 'Note Editor').appendTo container
    
    # Title text box
    $('<h4/>', text: 'Title').appendTo container
    @title_box = $('<input/>', {type: 'text'})
    @title_box.appendTo container
      
    # Body text area
    $('<h4/>', text: 'Body').appendTo container
    @body_box = $('<textarea/>')
    @body_box.appendTo(container)
      
    # Save button
    @save_button = $('<input/>', {type: 'submit', value: 'Save'})
    @save_button.appendTo(container)
      
  get_save_button: -> @save_button[0]
      
  get_title_box_value: -> @title_box.val()
  set_title_box_value: (title) -> @title_box.val(title)  
    
  get_body_box_value: -> @body_box.val()
  set_body_box_value: (body) -> @body_box.val(body)
      
  as_widget: -> container

class NoteListPresenter extends Presenter
  # This NoteListPresenter manages a list of notes for the user.
  
  on_bind: () ->
     
    @register_handler("click", (event) ->
      # Create a new note, and push a notification saying so.
      INJECTOR.get_event_bus().fire("new_note", null)
      INJECTOR.get_event_bus().fire('notify', message: "Creating New Note")
    , @display.get_new_note_button())
    
    @register_handler("note_clicked", (event) ->
      # Listen to the child NodeListItemPresenters for a note_clicked event
      # and pass on the load_note message through the event bus with the note
      INJECTOR.get_event_bus().fire("load_note", event.data.note)
    , true)
    
    @register_handler("refresh_display", (event) =>
      # Register a handler for refreshing the display when data is stale.
      @refresh()
    , true)
    
    @refresh()
  
  refresh: () ->
    # Refresh the display by fetching fresh data.
    @notes = []
    @display.clear_notes()
    
    INJECTOR.get_db().all((notes)=>
      for note in notes
        @add_note(note)
    )

  add_note: (note) ->
    # Add a new note to the note list by creating a NoteListItemPresenter, and
    # adding it's widget to the display.
    np = new NoteListItemPresenter(note, new NoteListItemDisplay())
    np.bind()
    
    @display.add_note(np.get_display().as_widget())
    @notes.push np

    
class NoteListDisplay extends Display
  # The NoteListDisplay displays the managed unordered list of notes in the UI
  # Nothing special here.
  
  container = $('<div/>', class: 'note_list')
  
  constructor: () ->
    @note_widgets = []
    $('<h2>', text: 'My Notes').appendTo container
    @new_button = $('<input/>', {type: 'submit', value: 'New Note'})
    @new_button.appendTo(container)
    @note_list = $('<ul/>').appendTo container
    
  get_note_list: -> @note_list[0]
  get_new_note_button: -> @new_button[0]
  
  add_note: (note_widget) ->
    @note_list.append note_widget
    @note_widgets.push note_widget
    
  clear_notes: () ->
    @note_widgets = []
    @note_list.empty()
    
  as_widget: -> container

class NoteListItemPresenter extends Presenter
  # Presenter to handle the management of a Note List Item
  
  constructor: (@note, display) ->
    # Here, we pass the note in as an arg to the constructor,
    # and call the parent's constructor
    super display
  
  on_bind: ->
    
    # Register a click handler for the display's list item
    @register_handler("click", (event) =>
      # Fire the 'note_clicked' message on the event bus, so the NotePresenter
      # will hear it.
      
      INJECTOR.get_event_bus().fire('note_clicked', note: @note)
    , @display.get_list_item())
    
    @display.set_text @note.title

class NoteListItemDisplay extends Display
  # NoteListItemDisplay is EXTRA nothing special.
   
  constructor: () ->
    @container = $('<li/>')
    
  get_list_item: () -> @container[0]
  set_text: (text) -> @container.text text
  as_widget: -> @container[0]

class NotificationPresenter extends Presenter
  # Simple Notification Window that will listen to 'notify' and display the message
  
  on_bind: ->
      
    # Listen to 'notify' globally
    @register_handler("notify", (event) =>
      
      # Display the message & animate
      @display.set_text(event.data.message)
      @display.flash_message()
    , true)

class NotificationDisplay extends Display
  # Notification Display Widget
  
  constructor: ->
    @container = $('<div/>', class: 'notification')  
    @notification = $('<span/>', text: 'waiting on notifications')
    @notification.appendTo @container
    
  flash_message: ->
    # Fancy message flashing
    @show()
    @container.animate opacity: '0.1', 2500, => 
      @hide()
      @container.css 'opacity', '1'
  
  hide: -> @container.hide()
  show: -> @container.show()  
  set_text: (text) -> @notification.text text
  as_widget: -> @container[0]

class Application

  event_bus = new EventBus()
  logger = new Logger()
  db = new Lawnchair "Notes", ->
    console.log("Database Loaded.")

  run: ->
    # Register shared objects in the injector registry
    INJECTOR.register("get_event_bus", -> return event_bus)
    INJECTOR.register("get_logger", -> return logger)
    INJECTOR.register("get_root_panel", -> return $("#application"))
    INJECTOR.register("get_db", -> return db)

    # Create and bind all of the presenters for this application
    note_presenter = new NotePresenter(new NoteDisplay())
    note_presenter.bind()
        
    note_list_presenter = new NoteListPresenter(new NoteListDisplay())
    note_list_presenter.bind()
    
    notification_presenter = new NotificationPresenter(new NotificationDisplay())
    notification_presenter.bind()
        
    # Insert the presenter's display widgets into the DOM
    INJECTOR.get_root_panel().append(notification_presenter.get_display().as_widget())
    INJECTOR.get_root_panel().append(note_presenter.get_display().as_widget())
    INJECTOR.get_root_panel().append(note_list_presenter.get_display().as_widget())

$(document).ready ->

  app = new Application
  if window
    window.APP = app
  app.run()
