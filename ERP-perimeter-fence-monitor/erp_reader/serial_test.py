import serial
import csv
from datetime import datetime
ser = serial.Serial()
ser.baudrate = 512000
ser.port = "COM4"
while not ser.is_open:
    try:
        ser.open()
        ser.flush()
    except:
        pass

rows = [["Timestamp", "Accel X", "Accel Y", "Accel Z", "ADC Value"]]
now = datetime.now()
date_time = now.strftime("%m-%d-%Y, %H-%M-%S")
accel_file = open(f"{date_time}-accel.csv","w",newline="")
audio_file = open(f"{date_time}-audio.csv","w",newline="")
accel_writer = csv.writer(accel_file)
audio_writer = csv.writer(audio_file)
accel_writer.writerow(["Timestamp","Accel X","Accel Y","Accel Z"])
audio_writer.writerow(["Timestamp","ADC Value"])
start_recording = True
while True:
    while not ser.is_open:
        try:
            ser.open()
        except:
            pass
    try:
        line = ser.readline().decode("ascii")
        now = datetime.now()
        date_time = now.strftime("%m/%d/%Y %H:%M:%S")
        if "END-CAPTURE" in line:
            start_recording = False
        elif "Accel" not in line and "ADC" not in line:
            continue
    except:
        continue
    # print(line)
    # if "START-CAPTURE" in line:
    #     start_recording = True
    #     print("Started recording...")
    #     continue

    processed_line = line.replace("\n","")
    print(processed_line)
    fields = processed_line.split(",")
    try:
        if "Accel" in fields[0]:
            accel_writer.writerow([date_time, float(fields[1]), float(fields[2]), float(fields[3])])
        elif "ADC" in fields[0]:
            audio_writer.writerow([date_time,int(fields[1])])
    except KeyboardInterrupt:
        accel_file.close()
        audio_file.close()
        exit(0)
    except:
        pass


