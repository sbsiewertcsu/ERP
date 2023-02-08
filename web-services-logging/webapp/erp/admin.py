from django.contrib import admin

from . import models

# Register your models here.
 
admin.site.register(models.LogGroup)
admin.site.register(models.GeophoneLog)
admin.site.register(models.SnapshotLog)
admin.site.register(models.AcousticLog)