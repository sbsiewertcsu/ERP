from django.shortcuts import render, redirect
from django.http import HttpResponse, Http404
from django.http import JsonResponse
from django.core import serializers
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.models import User
from django.core.files import File

from datetime import datetime, timedelta

from math import ceil

import wave
import json
import os

from django.conf import settings

from . import models
from . import forms
from . import view_lib

# Create your views here.
def index(request):
    logGroups = models.LogGroup.objects.order_by('-timestamp').all()
    pageLimit = view_lib.getPageLimit(logGroups)

    if request.method == "POST":
        if 'search' in request.POST:
            # Handle log search query
            logGroups, pageLimit = view_lib.searchQuery(request, logGroups, pageLimit)
    else:
        if 'logQueryResults' in request.session:
            request.session.pop('logQueryResults')

    request.session['logPage'] = 'index'
    request.session['searchFormPostURL'] = '/'

    template = {
        'title': 'ERP Home',
        'headerTitle': 'Logs',
        'searchForm': forms.SearchForm,
        'logs': logGroups[:settings.LOG_PAGE_CUTOFF],
        'logPage': request.session['logPage'],
        'pageLimit': pageLimit,
        'page': 1,
        'postURL': request.session['searchFormPostURL']
    }

    return render(request, "index.html", template)

def index_page(request, page):
    request.session['page'] = page

    if page >= 1:
        rangeA = (page - 1) * settings.LOG_PAGE_CUTOFF
        rangeB = page * settings.LOG_PAGE_CUTOFF

        if 'logQueryResults' in request.session:       
            logGroups = []

            for log in serializers.deserialize('json', request.session['logQueryResults']):
                logGroups.append(log.object)

            pageLimit = ceil(len(logGroups)/settings.LOG_PAGE_CUTOFF)
        else:
            logGroups = models.LogGroup.objects.order_by('-timestamp').all()
            pageLimit = ceil(len(logGroups)/settings.LOG_PAGE_CUTOFF)

            print(rangeA, rangeB, "are the cutoffs")
            
        logGroups = logGroups[rangeA:rangeB]

        if request.session['logPage'] == 'index':
            title = 'ERP Home'
            headerTitle = 'Logs'
        elif request.session['logPage'] == 'user_logs':
            title = 'Saved Logs'
            headerTitle = title

        template = {
            'title': title,
            'headerTitle': headerTitle,
            'searchForm': forms.SearchForm,
            'logs': logGroups,
            'logPage': request.session['logPage'],
            'pageLimit': pageLimit,
            'page': page,
            'postURL': request.session['searchFormPostURL']
        }

        return render(request, "index.html", template)
    else:
        return redirect("/")

@csrf_exempt
def upload_request(request):
    if request.method == "POST":
        files = request.FILES
        
        with files['json'].open('r') as f:
            data = json.load(f)
        
        logGroup = models.LogGroup(timestamp=datetime.strptime(data['logTimestamp'], '%Y-%m-%d %H:%M:%S'))
        logGroup.save()
        
        pictureTimestamps = data['picture_timestamps']
        pictureTimestampKeys = pictureTimestamps.keys()            

        acousticLogMappings = data['acoustic_log_mappings']
        acousticLogKeys = acousticLogMappings.keys()

        for key in files.keys():
            if key == 'geophone_logs':
                geophoneLog = models.GeophoneLog(timestamp=data['geophone_timestamp'],
                    logfile=files['geophone_logs'],
                    log_group=logGroup)

                geophoneLog.save()
            elif {key} <= pictureTimestampKeys:
                snapshotLog = models.SnapshotLog(timestamp=pictureTimestamps[key], 
                    name=key,
                    picture=files[key],
                    log_group=logGroup)

                snapshotLog.save()
            elif {key} <= acousticLogKeys:
                acousticLogfileKey = acousticLogMappings[key]['logfileKey']

                acousticRecording = files[key]

                # Convert the .pcm recording to .wav so that it's compatible with the HTML5 audio player
                with acousticRecording.open('rb') as pcmfile:
                    pcmdata = pcmfile.read()
                    wavFileName = key.removesuffix('.pcm') + '.wav'

                    with wave.open(wavFileName, 'wb') as wavfile:
                        wavfile.setparams((2, 2, 44100, 0, 'NONE', 'NONE'))
                        wavfile.writeframes(pcmdata)

                    newWavFile = open(wavFileName, 'rb')
                
                wavf = File(newWavFile)
                os.remove(wavFileName)

                acousticLog = models.AcousticLog(
                    timestamp=acousticLogMappings[key]['timestamp'],
                    logfile=files[acousticLogfileKey],
                    recording=wavf,
                    log_group=logGroup)

                acousticLog.save()
            
        return HttpResponse("OK")
    else:
        raise Http404

def register(request):
    if request.method == "POST":
        regForm = forms.RegistrationForm(request.POST)
        
        if regForm.is_valid():
            user = regForm.save()
            return redirect("/login/")
    else:
        regForm = forms.RegistrationForm()

    context = {
        "title": "Registration",
        "form": regForm
    }

    return render(request, "registration/register.html", context)

def log(request, uid):
    logGroup = models.LogGroup.objects.filter(uid=uid)[0]

    timestamp = str(logGroup.timestamp)

    template = {
        'logGroup': logGroup,
        'timestamp': timestamp,
    }

    return render(request, "log_group.html", template)

def geophone_log(request, uid):
    logGroup = models.LogGroup.objects.filter(uid=uid)[0]

    if hasattr(logGroup, 'geophone_data'):
        geophoneLog = logGroup.geophone_data
        indivGeoLogs = []
        limit = 25

        with geophoneLog.logfile.open('r') as f:
            l = 0

            for line in f:
                if l < limit:
                    indivGeoLogs.append(line.rstrip('\n'))
                else:
                    break
                l = l + 1

        template = {
            'timestamp': geophoneLog.timestamp,
            'geophoneLogs': indivGeoLogs,
            'logfileURL': geophoneLog.logfile.url,
            'notice': '* Preview is limited to the first ' + str(limit) + ' lines'
        }
    else:
        template = {
            'notice': 'No geophone data was captured'
        }

    return render(request, "geophone_log.html", template)

def snapshot_logs(request, uid):
    logGroup = models.LogGroup.objects.filter(uid=uid)[0]
    snapshots = logGroup.snapshots.all()

    template = {
        'snapshots': snapshots,
        'numSnapshots': len(snapshots)
    }

    return render(request, "snapshot_logs.html", template)

def acoustic_logs(request, uid):
    logGroup = models.LogGroup.objects.filter(uid=uid)[0]
    acousticLogs = logGroup.acoustic_data.all()
    logfileDict = {}

    for log in acousticLogs:
        logfile = log.logfile
        logfileDict[os.path.basename(logfile.name)] = logfile.url

    logfileDict = json.dumps(logfileDict)
    
    template = {
        'acousticLogs': acousticLogs,
        'logfileJSON': logfileDict,
        'numAcousticLogs': len(acousticLogs)
    }

    return render(request, "acoustic_logs.html", template)

def saved_logs(request, username):
    if User.objects.filter(username=username).exists() and username == request.user.username:
        userObject = User.objects.filter(username=username)[0]
        userLogsModel = models.UserLogs.objects.filter(user=userObject)

        if not userLogsModel.exists():
            userLogsModel = models.UserLogs(user=userObject)
            userLogsModel.save()
        else:
            userLogsModel = userLogsModel[0]

        logGroups = userLogsModel.log_groups.all()[::-1]
        pageLimit = view_lib.getPageLimit(logGroups)

        if request.method == 'POST':
            if 'search' in request.POST:
                logGroups, pageLimit = view_lib.searchQuery(request, logGroups, pageLimit)
            else:
                savedLogForm = forms.LogSaveForm(request.POST)

                if savedLogForm.is_valid():
                    uid = savedLogForm.cleaned_data.get('savedLog')

                    targetLog = models.LogGroup.objects.filter(uid=uid)[0]
                    userLogsModel.log_groups.add(targetLog)

                    logGroups = userLogsModel.log_groups.all()[::-1]
                    pageLimit = view_lib.getPageLimit(logGroups)
        
        request.session['logPage'] = 'user_logs'
        request.session['searchFormPostURL'] = '/saved/' + username + '/'

        template = {
            'title': 'Saved Logs',
            'headerTitle': 'Saved Logs',
            'searchForm': forms.SearchForm,
            'logs': logGroups[:settings.LOG_PAGE_CUTOFF],
            'logPage': request.session['logPage'],
            'pageLimit': pageLimit,
            'page': 1,
            'postURL': request.session['searchFormPostURL']
        }

        request.session['logPage'] = 'user_logs'

        return render(request, "index.html", template)
    else:
        raise Http404

#def foundation(request):
#    return render(request, "foundation_sample.html")