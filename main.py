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
    #print  delta.seconds
    if delta.seconds == 0:
       return
    if delta.seconds >= breakTime:
       workTime = 0
    else: 
       workTime = workTime + delta.seconds
    clickTime = now 
       #print( "workTime = %d "% ( workTime))    

    if workTime >= bellTime:
       playsound(bellSound)
       workTime = 0
                

mypy = sys.argv[0]
  
# get the mypy directory 
dir = os.path.split(mypy) [0]
bellSound = os.path.join(dir, 'bell.mp3')

breakTime = 5*60 # five minutes
bellTime = 60*60 # an hour

workTime = 0 # continious work time
clickTime = datetime.datetime.now()

with Listener(on_press= keyboardListener) as listener:
    listener.join()