## DOM Ready? ##
# A quick listener for when to start running your JS codes.
#
# Based heavily on jQuery's $.ready, thanks for doing all the legwork.

@ready = do () ->

    is_ready = false

    (fn) ->

        # Only fire once
        fin = () ->
            unless is_ready
                is_ready = true
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
            fin()


        # If the browser ready event has already occurred
        if document.readyState is "complete"
            return fin()

        # Mozilla, Opera and webkit nightlies currently support this event
        if document.addEventListener
            # Use the handy event callback
            document.addEventListener "DOMContentLoaded", fin, false
            # A fallback to window.onload, that will always work
            window.addEventListener "load", fin, false

        # If IE event model is used
        else if document.attachEvent
            # Ensure firing before onload; maybe late but safe also for iframes
            document.attachEvent "onreadystatechange", fin
            # A fallback to window.onload, that will always work
            window.attachEvent "onload", fin
            # If IE and not a frame:
            # continually check to see if the document is ready
            do_scroll_check() if document?.documentElement?.doScroll and window?.frameElement is null
