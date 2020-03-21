from pynput.keyboard import Listener
from playsound import playsound
import time



def keyboardListener(key):
    global clickCheck

    clickCheck = True
#    print('press')

def Play(n):
    while n > 0: 
          playsound('Tram-bell-sound-effect.mp3')
          n -= 1

def timeControl():
    global bellTime    
    global clickCheck
    i = 1
    breakTime = 300
    while True:
        time.sleep(breakTime)

        if i == bellTime:
            clickCheck == False
            Play(2)            
            i = 1
        else: 
             if clickCheck:
                clickCheck = False
                i = i + 1
             else: 
                i = 1


clickCheck = False
bellTime = 10 # the bell will sound when there was no break for 10 break intervals: 50 minutes
Play(1)
with Listener(keyboardListener) as l:
    timeControl()
    l.run()
