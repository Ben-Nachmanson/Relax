from tkinter import *

# def is_integer(value: str, *, base: int = 10) -> bool:
#     try:
#         int(value, base=base)
#         return True
#     except ValueError:
#         return False

# window = Tk()
# minBox = 0

# window.geometry('500x300')

# window.title("Relax")

# time = Label(window, text="Time:", font=("Ariel", 14))
# time.grid(column=0, row=0)

# minBox = Entry(window, width=10)
# minBox.grid(column=1, row=0)

# def clicked():
#     userMin = minBox.get()

#     if is_integer(userMin) == True:
#         intCheck.configure(text="Time Set")

#     else:
#         print("invalid")
#         intCheck.configure(text="Invalid Entry")

#     print(userMin)

# minutes = Label(window, text="minutes", font=("Ariel", 10))
# minutes.grid(column=2, row=0)

# enter = Button(window, text="Enter", command=clicked)
# enter.grid(column=3, row=0)

# intCheck = Label(window, text="", font=("Ariel", 8))

# intCheck.grid(column=4, row=0)

# window.mainloop()

secs = 10

standbysecs = 5