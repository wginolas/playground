#!/usr/bin/python

class Cursor(object):
    def __init__(self, x, y, dx, dy):
        self.x = x
        self.y = y
        self.dx = dx
        self.dy = dy

    def pos(self):
        return (self.x, self.y)

    def nose(self):
        return (self.x + self.dx, self.y + self.dy)

class Map(object):
    def __init__(self, width, height):
        self.width = width
        self.height = height
        self.m = {}

    def inMap(self, x, y):
        return x >= 0 and y >= 0 and x < self.width and y < self.height

    def setValue(self, x, y, v):
        self.m[(x, y)] = v

    def getValue(self, x, y):
        return self.m.get((x, y))

