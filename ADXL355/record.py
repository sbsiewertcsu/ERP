import spidev
import time
import numpy as np
import sys

import adxl355

################################################################################
# Some values for the recording                                                #
################################################################################
fid = open("/home/pi/Documents/Accelerometers/record_input.txt", "r")
# Filename for output
outfilename = str(fid.readline())
outfilename = outfilename[0:(len(outfilename)-1)] # Truncate \n from string
# Measurement time in seconds
mtime = float(fid.readline())
# Data rate, only some values are possible. All others will crash
# possible: 4000, 2000, 1000, 500, 250, 125, 62.5, 31.25, 15.625, 7.813, 3.906 
rate = float(fid.readline())
# Measurement range: 2g 4g 8g
G_range = int(fid.readline())
fid.close()

################################################################################
# Initialize the SPI interface                                                 #
################################################################################
spi = spidev.SpiDev()
bus = 0
device = 1
spi.open(bus, device)
spi.max_speed_hz = 5000000
spi.mode = 0b00 #ADXL 355 has mode SPOL=0 SPHA=0, its bit code is 0b00

################################################################################
# Initialize the ADXL355                                                       #
################################################################################
acc = adxl355.ADXL355(spi.xfer2)
acc.start()

# Set g range
if G_range == 2:
    acc.setrange(adxl355.SET_RANGE_2G)
if G_range == 4:
    acc.setrange(adxl355.SET_RANGE_4G)
if G_range == 8:
    acc.setrange(adxl355.SET_RANGE_8G)


acc.setfilter(lpf = adxl355.ODR_TO_BIT[rate]) # set data rate


################################################################################
# Record data                                                                  #
################################################################################
msamples = mtime * rate
mperiod = 1.0 / rate

datalist = []
acc.emptyfifo()
while (len(datalist) < msamples):
    if acc.fifooverrange():
        print("The FIFO overrange bit was set. That means some data was lost.")
        print("Consider slower sampling. Or faster host computer.")
    if acc.hasnewdata():
        datalist += acc.get3Vfifo()

# The get3Vfifo only returns raw data. That means three bytes per coordinate,
# three coordinates per data point. Data needs to be converted first to <int>,
# including, a twocomplement conversion to allow for negative values.
# Afterwards, values are converted to <float> g values.

# Convert the bytes to <int> (including twocomplement conversion)
rawdatalist = acc.convertlisttoRaw(datalist)
# Convert the <int> to <float> in g
gdatalist = acc.convertRawtog(rawdatalist)

# Add a column with a timestamp
alldata = []
for i in range(len(gdatalist)):
    alldata.append([i * mperiod] + gdatalist[i])

# Save it as a csv file    
alldatanp = np.array(alldata)
np.savetxt(outfilename, alldatanp, delimiter=",")


