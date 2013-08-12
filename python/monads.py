
"""
My attempt, to implment monads in python.
"""

from functools import partial

class MaybeMonad(object):
    pass

class Just(MaybeMonad):
    def __init__(self, value):
        self.value = value

    def has_value(self):
        return True

class Nothing(MaybeMonad):
    def has_value(self):
        return False

NOTHING = Nothing()

def concat(lists):
    result = []
    for l in lists:
        result.extend(l)
    return result

class ListMonad(object):
    def __init__(self, list):
        self.list = list

    def __rshift__(self, f):
        return concat(
            (f(x) for x in self.list)
        )

@partial
def guard(predicate, x):
    if predicate(x):
        return ListMonad([x])
    else:
        return ListMonad([])

