from pynput.keyboard import Listener
from playsound import playsound
import time
import os
import sys
import datetime

def keyboardListener(key):
    global clickTime
    global workTime
    global breakTime
    global bellTime
    global bellSound
    
    now = datetime.datetime.now()
    #print("ee")
    delta = now - clickTime
    #print  delta.minutes
    if delta.minutes == 0:
       return
    if delta.minutes >= breakTime:
       workTime = 0
    else: 
       workTime = workTime + delta.minutes
    clickTime = now 
       #print( "workTime = %d "% ( workTime))    

    if workTime >= bellTime:
       playsound(bellSound)
       workTime = 0
                

mypy = sys.argv[0]
  
# get the mypy directory 
dir = os.path.split(mypy) [0]
bellSound = os.path.join(dir, 'bell.mp3')

breakTime = 5 # minutes
bellTime = 60 # minutes

workTime = 0 # continious work time
clickTime = datetime.datetime.now()

with Listener(on_press= keyboardListener) as listener:
    listener.join()