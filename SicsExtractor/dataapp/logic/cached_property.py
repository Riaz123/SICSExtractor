# Lazy and threads safe property
# Copied from here
# https://robusgauli.medium.com/thread-safe-lazy-property-caching-for-python-6b193a381ccb

from threading import RLock
# senitel
_missing = object()
class cached_property(object):
    def __init__(self, func):
        self.__name__ = func.__name__
        self.__module__ = func.__module__
        self.__doc__ = func.__doc__
        self.func = func
        self.lock = RLock()
    def __get__(self, obj, type=None):
        if obj is None:
            return self
        with self.lock:
            value = obj.__dict__.get(self.__name__, _missing)
            if value is _missing:
                value = self.func(obj)
                obj.__dict__[self.__name__] = value
            return value