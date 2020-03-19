from pynput.keyboard import Listener
from playsound import playsound
import time



def keyboardListener(key):
    global clickCheck

    clickCheck = True

    print("click")


def Play():
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
            Play()
            i = 0
        elif i % standbyTime == 0:
            if clickCheck:
                clickCheck = False
            else:
                i = 0

        i = i+1
        print(i)


clickCheck = False
mainTime = 10
standbyTime = 5

with Listener(keyboardListener) as l:
    timeControl()
    l.run()
