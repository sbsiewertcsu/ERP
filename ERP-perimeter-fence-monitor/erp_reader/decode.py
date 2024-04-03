import csv
import struct
source = open("03-27-2024, 19-26-47-audio.bin",'rb')
sample_number = 0
data = bytearray(source.read())
print(len(data))
decoded_samples = []
index = 0
for i in range(702,len(data),2): # skip header info
    sample = ['',struct.unpack("<h",data[i:i+2])[0]]
    if sample[1] < 4096:
        decoded_samples.append(sample)
        decoded_samples[-1][1] -= 2047 # remove DC offset

# real_samples = [sample for sample in decoded_samples if sample[1] != ord(',')]
dest = open("decoded.csv","w",newline='')
writer = csv.writer(dest)
writer.writerow(["Timestamp","ADC Value"])
writer.writerows(decoded_samples)
dest.close()