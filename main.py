from tkinter import *
from pynput.keyboard import Listener
import threading
from playsound import playsound


def on_press(key):
    try:
        print('alphanumeric key {0} pressed'.format(
            key.char))
    except AttributeError:
        print('special key {0} pressed'.format(
            key))


def is_integer(value: str, *, base: int = 10) -> bool:
    try:
        int(value, base=base)
        return True
    except ValueError:
        return False


def enterClicked():
    userMin = minBox.get()

    if is_integer(userMin) == True:
        intCheck.configure(text="Time Set")

    else:
        print("invalid")
        intCheck.configure(text="Invalid Entry(unless decimal)")

    print(userMin)


def bellClicked():

    playsound('Tram-bell-sound-effect.mp3')
    print("bell clicked")


def timeControl():

    playsound('Tram-bell-sound-effect.mp3')
    print("time done")


def startClicked():
    timeMin = minBox.get()

    timeSec = (float(timeMin)*60)

    print(timeSec)

    print("start clicked")
    timer = threading.Timer(float(timeSec), timeControl)
    timer.start()


def keyboardListener(key):
    # keyData = str(key)
    # print(keyData)
    print("Keyboard Clicked")


window = Tk()
minBox = 0

# tkinter gui button and label declarations
window.geometry('500x300')

window.title("Relax")

time = Label(window, text="Time:", font=("Ariel", 14))
time.grid(column=0, row=0)

minBox = Entry(window, width=10)
minBox.grid(column=1, row=0)


minutes = Label(window, text="minutes", font=("Ariel", 10))
minutes.grid(column=2, row=0)

enter = Button(window, text="Enter", command=enterClicked)
enter.grid(column=3, row=0)

sound = Label(window, text="Sound:", font=("Ariel", 14))
sound.grid(column=0, row=1)

bell = Button(window, text="Bell", command=bellClicked)
bell.grid(column=1, row=1)

intCheck = Label(window, text="", font=("Ariel", 8))
intCheck.grid(column=4, row=0)


start = Button(window, text="Start", command=startClicked)
start.place(x=460, y=270)

with Listener(on_press=keyboardListener) as l:
    window.mainloop()
    l.join()
