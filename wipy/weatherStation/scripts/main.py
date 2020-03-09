# TODO
# - Load wheather data
#   - [X] Current
#   - [ ] Forecast


from machine import Pin, Timer
import math

from servo import Servo

import openWeather

def move():
    chrono = Timer.Chrono()
    chrono.start()

    servo = Servo()
    while True:
        servo.move(math.sin(chrono.read()) / 2.0 + 0.5)

def httpTest():
    data = openWeather.load_current("2818067")
    print(data)

#httpTest()
