import functools


def handle_errors(_func=None, *, error_callback=None, error_message=None, stacktrace=True):
    """
        handle_errors(func)
            handle errors using a callback function or show a message
    """
    def decorator_handle_errors(func):
        @functools.wraps(func)
        def wrapper_handle_errors(*args, **kwargs):
            nonlocal error_callback

            func_output = None

            if "error_callback" in kwargs:
                error_callback = kwargs["error_callback"]
                kwargs.pop("error_callback")

            try:
                func_output = func(*args, **kwargs)
            except Exception as exception:
                if error_message is not None:
                    print(error_message)
                if stacktrace:
                    print("Error when executing %s" % (func,))
                    print("Stacktrace: %s" % (exception,))
                try:
                    if error_callback is not None:
                        error_callback()
                except:
                    if error_message is not None:
                        print(error_message)
                    if stacktrace:
                        print("Stacktrace: %s" % (exception,))

            return func_output
        return wrapper_handle_errors

    if _func is None:
        return decorator_handle_errors
    else:
        return decorator_handle_errors(_func)
