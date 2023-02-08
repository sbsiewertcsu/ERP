from django.core import serializers
from datetime import datetime, timedelta
from math import ceil

from django.conf import settings

def searchQuery(request, logGroups, pageLimit):
    query = request.POST['search']
    selectedLogs = []

    timeA = datetime.min
    timeB = None

    if '->' in query:
        components = query.split('->')
        size = len(components)

        if size > 2:
            # user wants a date and time interval
            pass
        else:
            pass
            # user wants a date interval
    else:
        if ':' in query:
            timeA = datetime.strptime(query, '%m-%d-%y %H:%M')
        else:
            timeA = datetime.strptime(query, '%m-%d-%y')

    for log in logGroups:
        select = False

        if timeB:
            pass
        else:
            diff = abs(log.timestamp - timeA)

            if ':' in query:
                select = diff < timedelta(minutes=1)
            else:
                select = diff < timedelta(days=1)
        
        if select:
            selectedLogs.append(log)

    if len(selectedLogs) > 0:
        logGroups = selectedLogs
        request.session['logQueryResults'] = serializers.serialize('json', logGroups)
        pageLimit = getPageLimit(selectedLogs)

    return logGroups, pageLimit

def getPageLimit(logGroups):
    return ceil(len(logGroups)/settings.LOG_PAGE_CUTOFF)