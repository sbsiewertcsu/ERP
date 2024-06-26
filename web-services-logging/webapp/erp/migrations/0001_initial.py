# Generated by Django 4.1.2 on 2022-10-27 18:59

from django.db import migrations, models
import django.utils.timezone
import uuid


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Log',
            fields=[
                ('uid', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('timestamp', models.DateTimeField(default=django.utils.timezone.now)),
                ('snapshot', models.FileField(upload_to='snapshots')),
                ('acoustic', models.FileField(upload_to='audio')),
                ('geophone', models.FileField(upload_to='seismic')),
            ],
        ),
    ]
