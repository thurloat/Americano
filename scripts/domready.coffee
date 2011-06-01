# DOM ready event listener
ready = do () ->

    ready_event_fired = false

    (fn) ->

        # Create an idempotent version of the 'fn' function
        idempotent_fn = () ->
            unless ready_event_fired
                ready_event_fired = true
                fn()

        # The DOM ready check for Internet Explorer
        do_scroll_check = () ->
            # If IE is used, use the trick by Diego Perini
            # http://javascript.nwbox.com/IEContentLoaded/
            try 
                document.documentElement.doScroll "left"
            catch e
                setTimeout do_scroll_check, 1
                return
            # Execute any waiting functions
            idempotent_fn()


        # If the browser ready event has already occurred
        if document.readyState is "complete"
            return idempotent_fn()

        # Mozilla, Opera and webkit nightlies currently support this event
        if document.addEventListener
            # Use the handy event callback
            document.addEventListener "DOMContentLoaded", idempotent_fn, false
            # A fallback to window.onload, that will always work
            window.addEventListener "load", idempotent_fn, false

        # If IE event model is used
        else if document.attachEvent
            # Ensure firing before onload; maybe late but safe also for iframes
            document.attachEvent "onreadystatechange", idempotent_fn
            # A fallback to window.onload, that will always work
            window.attachEvent "onload", idempotent_fn
            # If IE and not a frame:
            # continually check to see if the document is ready
            do_scroll_check() if document?.documentElement?.doScroll and window?.frameElement is null

if window
  window.ready = ready