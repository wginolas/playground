from machine import PWM

class Servo:
    def __init__(self, min_ms=1.0, max_ms=2.0, pin='P9', timer_id=0, channel_id=0):
        self._a = max_ms - min_ms
        self._b = min_ms
        self._pwm = PWM(timer_id, 50)
        self._channel = self._pwm.channel(channel_id, pin=pin)
    
    def move(self, to):
        to_ms = to * self._a + self._b
        #print('to_ms: ', to_ms, to_ms / 20)
        self._channel.duty_cycle(to_ms / 20.0)