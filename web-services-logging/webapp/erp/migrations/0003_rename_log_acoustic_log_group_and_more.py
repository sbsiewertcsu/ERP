# Generated by Django 4.1.2 on 2022-11-27 15:30

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('erp', '0002_remove_log_acoustic_remove_log_geophone_and_more'),
    ]

    operations = [
        migrations.RenameField(
            model_name='acoustic',
            old_name='log',
            new_name='log_group',
        ),
        migrations.RenameField(
            model_name='geophone',
            old_name='log',
            new_name='log_group',
        ),
        migrations.RenameField(
            model_name='snapshot',
            old_name='log',
            new_name='log_group',
        ),
    ]
