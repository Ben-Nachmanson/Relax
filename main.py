from pynput.keyboard import Listener
from playsound import playsound
import time
import os
import sys


def keyboardListener(key):
    global clickCheck

    clickCheck = True
#    print('press')

def Play():
    global bellSound
    playsound(bellSound)

def timeControl():
    global bellTime    
    global clickCheck
    i = 1
    breakTime = 300
    while True:
        time.sleep(breakTime)

        if i == bellTime:
            clickCheck == False
            Play()            
            i = 1
        else: 
             if clickCheck:
                clickCheck = False
                i = i + 1
             else: 
                i = 1

path = sys.argv[0]
  
# Split the path in  
# head and tail pair 
dir = os.path.split(path) [0]
print(dir)
bellSound = os.path.join(dir, 'bell.mp3')

clickCheck = False
bellTime = 10 # the bell will sound when there was no break for 10 break intervals: 50 minutes
with Listener(keyboardListener) as l:
    timeControl()
    l.run()
