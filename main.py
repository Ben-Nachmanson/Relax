from pynput.keyboard import Listener
from playsound import playsound
import time



def keyboardListener(key):
    global clickCheck

    clickCheck = True


def Play():
    playsound('Tram-bell-sound-effect.mp3')
    playsound('Tram-bell-sound-effect.mp3')

def timeControl():

    global mainTime
    global standbyTime
    global clickCheck
    i = 0

    while i < mainTime+1:
        time.sleep(1.0)

        if i == mainTime:
            clickCheck == False
            Play()            
            i = 0
        elif i % standbyTime == 0:
            if clickCheck:
                clickCheck = False
                i = i + 1
            else: 
                i = 0
        else:
             i = i + 1



clickCheck = False
mainTime = 20*60 # the bell will sound when there was no break for 
standbyTime = 5*60 # five minutes brake silence the bell
Play()
with Listener(keyboardListener) as l:
    timeControl()
    l.run()
