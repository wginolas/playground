import math
import pycom
from machine import Timer
from umqtt.simple import MQTTClient
import ubinascii
import ustruct

def byte_sin(x):
    return round((math.cos(x) + 1)  * 127)

def mix_rgb(r, g, b):
    return (r << 16) + (g << 8) + b

def colorfade():
    print('Start')
    phase = math.pi * 2 / 3
    chrono = Timer.Chrono()
    chrono.start()
    pycom.heartbeat(False)

    while True:
        time = chrono.read()
        r = byte_sin(time) // 1
        g = byte_sin(time + phase) // 1
        b = byte_sin(time + phase*2) // 1
        color = mix_rgb(r, g, b)
        print(time, r, g, b, color)
        pycom.rgbled(color)

def callback(topic, message):
    print(topic, message)
    print(topic, message[1:])
    print(topic, ubinascii.unhexlify(message[1:]))
    print(topic, ustruct.unpack('I', ubinascii.unhexlify(message[1:]))[0])
    pycom.rgbled(ustruct.unpack('I', ubinascii.unhexlify(message[1:]))[0])
    

def mqtt():
    print('Start')
    pycom.heartbeat(False)
    client = MQTTClient(
        client_id = "wipy_id", 
        server = "io.adafruit.com",
        user = "antonpeter",
        password = "cec2683d7ea94cdb9dc8b5420b89cbd5")
    print('Connecting...', client.connect())
    print('Connected')
    client.set_callback(callback)
    print('Subscribe...', client.subscribe('antonpeter/f/led'))
    print('Subscribed')
    while True:
        print('wait_msg', client.wait_msg())

colorfade()

