from django.contrib.auth.models import User
from django.db import models


class PatientProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='patient_profile')
    mobile = models.CharField(max_length=20)
    date_of_birth = models.DateField(null=True, blank=True)
    gender = models.CharField(max_length=20, blank=True)
    address = models.TextField(blank=True, default='')
    allergies = models.TextField(blank=True)

    def __str__(self):
        return self.user.get_full_name() or self.user.username


class Department(models.Model):
    name = models.CharField(max_length=120, unique=True)
    description = models.TextField(blank=True)
    is_active = models.BooleanField(default=True)

    class Meta:
        ordering = ['name']

    def __str__(self):
        return self.name


class DoctorProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='doctor_profile')
    department = models.ForeignKey(Department, on_delete=models.PROTECT, related_name='doctors')
    role = models.CharField(max_length=20, choices=[('Doctor', 'Doctor'), ('Nurse', 'Nurse')], default='Doctor')
    qualification = models.CharField(max_length=120, blank=True, default='MBBS, MD')
    specialty = models.CharField(max_length=120, blank=True, default='')
    is_approved = models.BooleanField(default=False)
    is_available = models.BooleanField(default=True)
    consultation_start = models.TimeField(null=True, blank=True)
    consultation_end = models.TimeField(null=True, blank=True)

    def __str__(self):
        return f'{self.user.get_full_name()} ({self.role})'


class Appointment(models.Model):
    STATUS_CHOICES = [
        ('upcoming', 'Upcoming'),
        ('waiting', 'Waiting'),
        ('in_consultation', 'In consultation'),
        ('completed', 'Completed'),
        ('cancelled', 'Cancelled'),
        ('no_show', 'No show'),
    ]
    patient = models.ForeignKey(User, on_delete=models.CASCADE, related_name='appointments')
    doctor = models.ForeignKey(DoctorProfile, on_delete=models.PROTECT, related_name='appointments')
    appointment_date = models.DateField()
    appointment_time = models.TimeField()
    queue_token = models.PositiveIntegerField()
    estimated_wait_minutes = models.PositiveIntegerField(default=15)
    reason = models.TextField(blank=True)
    hospital_name = models.CharField(max_length=160, default='City Care Hospital, Lucknow')
    status = models.CharField(max_length=30, choices=STATUS_CHOICES, default='upcoming')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['appointment_date', 'appointment_time', 'queue_token']


class Notification(models.Model):
    patient = models.ForeignKey(User, on_delete=models.CASCADE, related_name='patient_notifications')
    title = models.CharField(max_length=160)
    message = models.TextField()
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']