from datetime import datetime, timedelta
from stat import S_ISDIR, S_ISREG
from time import time, sleep
import paramiko, requests, json

port = 22
waitInterval = 15
timeout = 30

webServer = "http://34.105.51.81/post/" # final web server

sensors = {
    'geophone': {
        'host': '192.168.1.164',
        'username': 'myshake',
        'password': 'shakeme',
        'remoteDirectory': '/opt/ERP/geophone/src/',
        'localDirectory': '/home/jalymo/ERP/geophone_files/',
        
        #'host': '127.0.0.1',
        #'username': 'jalymo',
        #'password': 'fall',
        #'remoteDirectory': '/home/jalymo/capstone/geophone_files/',
        #'localDirectory': '/home/jalymo/ERP/geophone_files/',
        
        # Specific settings
        'logFileName': 'geophone.log',
    },

    'camera': {
        'host': '192.168.0.104',
        'username': 'csuchico',
        'password': 'password',
        'remoteDirectory': '/tmp/',
        'localDirectory': '/home/jalymo/ERP/camera_files/',

        #'host': '127.0.0.1',
        #'username': 'jalymo',
        #'password': 'fall',
        #'remoteDirectory': '/home/jalymo/capstone/camera_files/',
        #'localDirectory': '/home/jalymo/ERP/camera_files/',
    },

    'acoustic': {
        'host': '192.168.1.176',
        'username': 'myaudio',
        'password': 'hearme',
        'remoteDirectory': '/home/myaudio/ERP/audio/emvia-master/',
        'localDirectory': '/home/jalymo/ERP/acoustic_files/',

        #'host': '127.0.0.1',
        #'username': 'jalymo',
        #'password': 'fall',
        #'remoteDirectory': '/home/jalymo/capstone/acoustic_files/',
        #'localDirectory': '/home/jalymo/ERP/acoustic_files/',
    },
}

# Don't touch anything below this line unless you intend to debug the program or change its functionality

emptyTimestamp = datetime.min
latestTimestamp = datetime.now()

def timeKeyFunction(element):
    return element['timestamp']

def finalStringTimestamp(timestamp):
    return timestamp.strftime('%Y-%m-%d %H:%M:%S')

def timestampToFileId(timestamp):
    return timestamp.strftime('%Y%m%d_%H%M%S')

def getLatestGeophoneLogs(data):
    # Check for new data in the geophone log
    sftp = data['client']
    remoteFile = data['remoteDirectory'] + data['logFileName']

    utime = sftp.stat(data['remoteDirectory'] + data['logFileName']).st_mtime
    lastModified = datetime.fromtimestamp(utime)
    
    logs = []
    # Was the log file modified after the last data retrieval period?
#    if lastModified > latestTimestamp:
    fileObject = sftp.file(remoteFile, 'r')
    
    while (log := fileObject.readline()) != '':
        logTimestamp = datetime.strptime(log.split(',')[0], '%Y-%m-%d %H:%M:%S')

        if logTimestamp > latestTimestamp:
            # Is the logs array empty? Then this is the first log for this group, and its timestamp will be used for comparison 
            #if not logs:
            #    data['timestamp'] = logTimestamp
            
            logs.append({'timestamp': logTimestamp, 'log': log})

    return logs # no need to sort this list as the geophone log file is already (by nature of appending) sorted by entry

def getLatestCameraLog(data):
    sftp = data['client']
    
    pictures = []
    
    for entry in sftp.listdir_attr(data['remoteDirectory']):
        if entry.filename[0] != '.' and '.png' in entry.filename:
            mode = entry.st_mode
             
            lastModified = datetime.fromtimestamp(entry.st_mtime)
            
            if S_ISREG(mode):
                # we'll also want to check the name of the file to ensure that this recently modified file isn't an old imported file
                try:
                    components = entry.filename.split('_')
                    if len(components) == 3:
                        pictime = datetime.strptime(components[0] + ' ' + components[1], '%d%b%Y %H%M%S')
                        
                        if pictime > latestTimestamp:
                            print("pic time is greater than latest timestamp: ", pictime, " | ", latestTimestamp)
                            pictures.append({'timestamp': pictime, 'name': entry.filename})
                except ValueError:
                    print("There was an error when attempting to decode the date in the name of file: " + entry.filename + ". Ensure no improperly named files are in this directory: " + data['remoteDirectory'])

    if len(pictures) > 0:
        pictures.sort(reverse=True, key=timeKeyFunction)

    return pictures

def getLatestAcousticLog(data):
    sftp = data['client']

    recordings = []

    for entry in sftp.listdir_attr(data['remoteDirectory']):
        if entry.filename[0] != '.' and 'recording' in entry.filename:
            lastModified = datetime.fromtimestamp(entry.st_mtime)

            if lastModified > latestTimestamp:
                recordingTimestamp = datetime.strptime(entry.filename.split('.')[1].split('_')[0], '%m%d%Y-%H%M%S%Z')

                if recordingTimestamp > latestTimestamp:
                    recordings.append({'timestamp': recordingTimestamp, 'recording': entry.filename})

    if len(recordings) > 0:
        for entry in sftp.listdir(data['remoteDirectory']):
            if entry[0] != '.' and entry.find('logfile') != -1:
                logfileTimestamp = entry.split('.')[1].split('_')[0]

                for recording in recordings:
                    if logfileTimestamp in recording['recording']:
                        recording['logfile'] = entry

        recordings.sort(reverse=True, key=timeKeyFunction)

    return recordings

def main(): # obtain logs by checking if they're greater than the last obtained timestamp, instead of seeing if the difference is greater than a time delta
    global latestTimestamp 
    
    for sensor, data in sensors.items():
        try:
            transport = paramiko.Transport((data['host'], port))
            transport.connect(None, data['username'], data['password'])

            data['transport'] = transport
            data['client'] = paramiko.SFTPClient.from_transport(transport)
        except paramiko.SSHException as err:
            print(err)
    
    running = True

    while running:
        print("Retrieving sensor data...")
        geophoneLogData = []
        pictureLogData = []
        audioLogData = []

        for sensor, data in sensors.items():
            if 'client' in data:
                if sensor == 'geophone':
                    geophoneLogData = getLatestGeophoneLogs(data)
                elif sensor == 'camera':
                    pictureLogData = getLatestCameraLog(data)
                elif sensor == 'acoustic':
                    audioLogData = getLatestAcousticLog(data)
        
        # get log latest timestamp from each sensor group fo comparison
        geophoneTimestamp = len(geophoneLogData) > 0 and geophoneLogData[-1]['timestamp'] or emptyTimestamp
        cameraTimestamp = len(pictureLogData) > 0 and pictureLogData[0]['timestamp'] or emptyTimestamp
        acousticTimestamp = len(audioLogData) > 0 and audioLogData[0]['timestamp'] or emptyTimestamp
        
        officialLogTimestamp = max(geophoneTimestamp, cameraTimestamp, acousticTimestamp)
        
        #print(cameraTimestamp, "||", officialLogTimestamp, "||", latestTimestamp)
        if officialLogTimestamp > latestTimestamp:
            latestTimestamp = officialLogTimestamp

            #print("this will be the latest timestamp: ", latestTimestamp)
        
            # send the data from each sensor to the web sever as a log group
            files = {}
            data = {
                'picture_timestamps': {},
                'acoustic_log_mappings': {},
                'logTimestamp': finalStringTimestamp(officialLogTimestamp)
            }
            
            if len(geophoneLogData) > 0:
                logStrings = ''.join([entry['log'] for entry in geophoneLogData])

                files['geophone_logs'] = (timestampToFileId(geophoneTimestamp) + '_' + 'geophone.log', logStrings)
                
                data['geophone_timestamp'] = finalStringTimestamp(geophoneTimestamp) # will be used to name the geophone log file on the web server

            if len(pictureLogData) > 0:
                cameraSensor = sensors['camera']

                for pic in pictureLogData:
                    picName = pic['name']

                    files[picName] = cameraSensor['client'].open(cameraSensor['remoteDirectory'] + picName, 'r')
                    
                    data['picture_timestamps'][picName] = finalStringTimestamp(pic['timestamp'])

            if len(audioLogData) > 0:
                acousticSensor = sensors['acoustic']

                for audio in audioLogData:
                    audioName = audio['recording']
                    logName = audio['logfile']

                    files[audioName] = acousticSensor['client'].open(acousticSensor['remoteDirectory'] + audioName, 'r')
                    files[logName] = acousticSensor['client'].open(acousticSensor['remoteDirectory'] + logName, 'r')
                    
                    data['acoustic_log_mappings'][audioName] = {'logfileKey': logName, 'timestamp': finalStringTimestamp(audio['timestamp'])}
            
            files['json'] = ('payload.json', json.dumps(data), 'application/json')

            try:
                r = requests.post(webServer, files=files, timeout=timeout)

                print("A request was sent to the web server. It returned the following status code: " + str(r.status_code))
            except Exception as err:
                print(err)
        else:
            print("No new sensor data found. An attempt to retrieve data will be made in the next iteration.")

        sleep(waitInterval)

    # program close
    for sensor, data in sensors.items():
        data['client'].close()
        data['transport'].close()


if __name__ == '__main__':
    main()
