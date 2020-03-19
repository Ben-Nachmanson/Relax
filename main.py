from pynput.keyboard import Listener
from playsound import playsound
import time


def on_press(key):
    try:
        print('alphanumeric key {0} pressed'.format(
            key.char))
    except AttributeError:
        print('special key {0} pressed'.format(
            key))


def keyboardListener(key):
    global clickCheck

    clickCheck = True

    print("click")


def timeDone():
    playsound('Tram-bell-sound-effect.mp3')


def timeControl():

    global mainTime
    global standbyTime
    global clickCheck
    i = 0

    while i < mainTime+1:
        time.sleep(1.0)

        if i == mainTime and clickCheck == True:
            clickCheck == False
            timeDone()
            i = 0
        elif i % standbyTime == 0:
            if clickCheck == True:
                clickCheck = False
            else:
                i = 0

        i = i+1
        print(i)


clickCheck = False
mainTime = 10
standbyTime = 5

with Listener(on_press=keyboardListener) as l:
    timeControl()
    l.run()
