from pynput.keyboard import Listener
from playsound import playsound
import time
import os
import sys


def keyboardListener(key):
    global click

    click = True
#    print('press')

def Play():
    global bellSound
    playsound(bellSound)

def timeControl():
    global bellTime    
    global click

    i = 0

    sleepTime = 10 # seconds

    while True:
        time.sleep(sleepTime)

        if i >= bellTime:
            click == False
            Play()            
            i = 0
        elif i % breakTime == 0:
                  if click:
                      click = False
                      i = i + sleepTime
                      #print("no break")
                  else: 
                      i = 0
                      #print("got a break")
        else: 
             i = i + sleepTime
             

path = sys.argv[0]
  
# Split the path in  
# head and tail pair 
dir = os.path.split(path) [0]
print(dir)
bellSound = os.path.join(dir, 'bell.mp3')

breakTime = 300 # five minutes
bellTime = breakTime * 12 # the bell will sound when there was no break for 12 break intervals: 60 minutes


click = False
with Listener(keyboardListener) as l:
    timeControl()
    l.run()
