from django.urls import path
from django.conf import settings
from django.conf.urls.static import static
from django.contrib.auth import views as auth_views

from . import views

urlpatterns = [
    path("", views.index, name="index"),
    path("page/<int:page>/", views.index_page),
    path('post/', views.upload_request),
    path('register/', views.register),
    path('login/', auth_views.LoginView.as_view()),
    path('logout/', auth_views.LogoutView.as_view()),
    path('log/<uid>/', views.log),
    path('log/<uid>/geophone/', views.geophone_log),
    path('log/<uid>/snapshots/', views.snapshot_logs),
    path('log/<uid>/acoustic/', views.acoustic_logs),
    path('saved/<username>/', views.saved_logs),
    #path("foundation/", views.foundation, name="foundation"),
] #+ static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
