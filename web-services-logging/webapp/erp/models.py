from django.db import models
from django.utils import timezone
from django.contrib.auth.models import User

import datetime
import uuid
import os

# Create your models here.

class LogGroup(models.Model):
    uid = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    timestamp = models.DateTimeField(default=timezone.now)

    def getRawTimestamp(self):
        return str(self.timestamp)

class UserLogs(models.Model):
    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE
    )
    log_groups = models.ManyToManyField(LogGroup)

class GeophoneLog(models.Model):
    timestamp = models.DateTimeField(default=timezone.now)
    logfile = models.FileField(upload_to='geophone_logfiles')
    # seismogram = models.FileField(upload_to='geophone_seismograms') # version 2 expansion
    log_group = models.OneToOneField(
        LogGroup,
        on_delete=models.CASCADE,
        related_name='geophone_data'
    )

class SnapshotLog(models.Model):
    timestamp = models.DateTimeField(default=timezone.now)
    name = models.CharField(max_length=32, default='')
    picture = models.ImageField(upload_to='snapshots')
    log_group = models.ForeignKey(
        LogGroup,
        on_delete=models.CASCADE,
        related_name='snapshots'
    )

class AcousticLog(models.Model):
    timestamp = models.DateTimeField(default=timezone.now)
    logfile = models.FileField(upload_to='acoustic_logfiles')
    recording = models.FileField(upload_to='acoustic_recordings')
    log_group = models.ForeignKey(
        LogGroup,
        on_delete=models.CASCADE,
        related_name='acoustic_data'
    )

    def logfileBasename(self):
        return os.path.basename(self.logfile.name)