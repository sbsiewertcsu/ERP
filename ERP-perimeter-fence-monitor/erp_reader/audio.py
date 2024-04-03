import serial
from datetime import datetime
ser = serial.Serial()
ser.baudrate = 921600
ser.port = "COM4"
ser.timeout = 5
while not ser.is_open:
    try:
        # print("///")
        ser.open()
        ser.flush()
    except:
        # print("...")
        pass
now = datetime.now()
date_time = now.strftime("%m-%d-%Y, %H-%M-%S")
audio_file = open(f"{date_time}-audio.bin","wb")
print("Started...")
samples_read = 0
print("sending start byte...")
ser.write(0xFF)
print("sent start byte")
bytes_read = 0
while True:
    try:
        line = ser.read_all()
        if len(line) != 0:
            bytes_read += len(line)
            print(f"{bytes_read} bytes read...")
            # print(f"Samples Read: {samples_read}")
            audio_file.write(line)
            audio_file.flush()
    except KeyboardInterrupt:
        audio_file.close()
        exit(0)

    # print(repr(list(line)))