from datetime import date, time

from django.contrib.auth.models import User
from rest_framework.test import APITestCase

from patients.models import Department, DoctorProfile


class PatientApiTests(APITestCase):
    def setUp(self):
        self.department = Department.objects.create(name='Cardiology')
        doctor_user = User.objects.create_user(
            username='doctor@example.com',
            first_name='Asha Doctor',
            password='secure-password',
        )
        DoctorProfile.objects.create(
            user=doctor_user,
            department=self.department,
            is_approved=True,
            consultation_start=time(9),
            consultation_end=time(17),
        )

    def test_patient_can_register_and_login(self):
        response = self.client.post('/api/patient/auth/register/', {
            'name': 'Test Patient',
            'email': 'patient@example.com',
            'mobile': '9876543210',
            'password': 'secure-password',
        }, format='json')
        self.assertEqual(response.status_code, 201)
        self.client.credentials(HTTP_AUTHORIZATION=f"Token {response.data['token']}")
        profile = self.client.get('/api/patient/profile/')
        self.assertEqual(profile.status_code, 200)
        self.assertEqual(profile.data['name'], 'Test Patient')

    def test_patient_can_list_doctors_and_book(self):
        register = self.client.post('/api/patient/auth/register/', {
            'name': 'Booking Patient',
            'email': 'booking@example.com',
            'mobile': '9999999999',
            'password': 'secure-password',
        }, format='json')
        self.client.credentials(HTTP_AUTHORIZATION=f"Token {register.data['token']}")
        doctors = self.client.get('/api/patient/doctors/?department=1')
        self.assertEqual(doctors.status_code, 200)
        self.assertEqual(len(doctors.data), 1)
        booking = self.client.post('/api/patient/appointments/', {
            'doctor': doctors.data[0]['id'],
            'appointment_date': date.today().isoformat(),
            'appointment_time': '10:30:00',
            'reason': 'Chest discomfort',
        }, format='json')
        self.assertEqual(booking.status_code, 201)
        self.assertEqual(booking.data['queue_token'], 1)

    def test_patient_can_cancel_appointment(self):
        register = self.client.post('/api/patient/auth/register/', {
            'name': 'Cancel Patient',
            'email': 'cancel@example.com',
            'mobile': '8888888888',
            'password': 'secure-password',
        }, format='json')
        self.client.credentials(HTTP_AUTHORIZATION=f"Token {register.data['token']}")
        booking = self.client.post('/api/patient/appointments/', {
            'doctor': DoctorProfile.objects.first().id,
            'appointment_date': date.today().isoformat(),
            'appointment_time': '11:00:00',
        }, format='json')
        cancelled = self.client.post(f"/api/patient/appointments/{booking.data['id']}/cancel/")
        self.assertEqual(cancelled.status_code, 200)
        self.assertEqual(cancelled.data['status'], 'cancelled')
