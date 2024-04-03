import serial
import matplotlib.pyplot as plt
import numpy as np
from beeply import notes
import time

ctr = 0
mybeep = notes.beeps()
plt.ion()
fig = plt.figure()
i = 0
x_accel_sum = 0
y_accel_sum = 0
z_accel_sum = 0
norm = 10
x = list()
y_x = list()
y_y = list()
y_z = list()
# open serial connection
ser = serial.Serial('COM10', 115200)
ser.close()
ser.open()
# discard first 8 reads
for v in range(50):
    data = ser.readline()

while True:
    # accumulate sum of norm values
    for v in range(norm):
        data = ser.readline()
        d = data.decode()
        print(d)
        d = d.split(",")
        x_accel_sum = x_accel_sum + float(d[0])
        y_accel_sum = y_accel_sum + float(d[1])
        z_accel_sum = z_accel_sum + float(d[2])
    # avg of norm values
    x_accel_avg = x_accel_sum / norm
    y_accel_avg = y_accel_sum / norm
    z_accel_avg = z_accel_sum / norm
    # reset sum
    x_accel_sum = 0
    y_accel_sum = 0
    z_accel_sum = 0
    x.append(i)
    y_x.append(x_accel_avg)
    y_y.append(y_accel_avg)
    y_z.append(z_accel_avg)
    # plot i read vs x_accel_avg y_accel_avg z_accel_avgvalues

    plt.subplot(1, 3, 1)
    plt.plot(x, y_x, color='blue', linewidth=0.7)
    plt.title("Acceleration in X axis")
    plt.subplot(1, 3, 2)
    plt.plot(x, y_y, color='green', linewidth=0.7)
    plt.title("Acceleration in Y axis")
    plt.subplot(1, 3, 3)
    plt.plot(x, y_z, color='red', linewidth=0.7)
    plt.title("Acceleration in Z axis")
    i += 1
    plt.show()
    ctr += 1
    if ctr % 100 == 0:
        plt.clf()
        ctr = 0

    if y_accel_avg >= -8:
        mybeep.hear('G', 15)
    if i >= 100:
        x.pop(0)
        y_x.pop(0)
        y_y.pop(0)
        y_z.pop(0)
    plt.pause(0.001)

