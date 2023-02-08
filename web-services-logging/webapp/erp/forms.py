from django import forms
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth.models import User

from . import models

def must_be_unique(value):
    user = User.objects.filter(email = value)
    if len(user) > 0:
        raise forms.ValidationError("Email already exists")
    return value

class SearchForm(forms.Form):
    search = forms.CharField(max_length=32,
        widget=forms.TextInput(attrs={
            #'placeholder': 'Filter by Date or Time (e.g. 01-01-22, 01-01->04-22, 01-01-22 8:00 or 01-01-22 8:00->14:00)', # version 2 expansion (implement -> operator)
            'placeholder': 'Filter by Date or Time (e.g. 01-01-22, or 01-01-22 8:00)',
            'type': 'search'
        }))

class LogSaveForm(forms.Form):
    savedLog = forms.UUIDField()

class RegistrationForm(UserCreationForm):
    email = forms.EmailField(
        label = "Email",
        required = True,
        validators = [must_be_unique]
    )

    class Meta:
        model = User
        fields = [
            "username",
            "email",
            "password1",
            "password2"
        ]

    def save(self, commit=True):
        user = super(RegistrationForm, self).save(commit=False)
        user.email = self.cleaned_data["email"]
        if commit:
            user.save()
        return user