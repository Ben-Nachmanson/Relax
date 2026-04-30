from pynput.keyboard import Listener
import subprocess
import os
import sys
import datetime


def playsound(path):
    if sys.platform == "darwin":
        subprocess.Popen(
            ["/usr/bin/afplay", path],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    else:
        from playsound import playsound as _playsound
        _playsound(path)

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
                

mypy = os.path.abspath(sys.argv[0])

dir = os.path.dirname(mypy)
bellSound = os.path.join(dir, 'bell.mp3')

breakTime = 5*60 # five minutes
bellTime = 60*60 # an hour

workTime = 0 # continious work time
clickTime = datetime.datetime.now()

print(f"Relax started at {clickTime.isoformat()}; bell={bellSound}", flush=True)

with Listener(on_press= keyboardListener) as listener:
    listener.join()