from django.contrib import admin

from .models import Appointment, Department, DoctorProfile, Notification, PatientProfile

admin.site.register([PatientProfile, Department, DoctorProfile, Appointment, Notification])