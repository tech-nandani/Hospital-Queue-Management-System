from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from patients.models import Department, DoctorProfile
import datetime


DOCTORS_DATA = [
    # General Medicine
    {
        'username': 'dr_priya_sharma',
        'first_name': 'Dr. Priya Sharma',
        'email': 'priya.sharma@hospital.org',
        'department': 'General Medicine',
        'role': 'Doctor',
        'qualification': 'MBBS, MD',
        'specialty': 'General Medicine',
        'is_approved': True,
        'is_available': True,
        'consultation_start': datetime.time(9, 0),
        'consultation_end': datetime.time(17, 0),
    },
    {
        'username': 'dr_rahul_verma',
        'first_name': 'Dr. Rahul Verma',
        'email': 'rahul.verma@hospital.org',
        'department': 'General Medicine',
        'role': 'Doctor',
        'qualification': 'MBBS, MD',
        'specialty': 'General Medicine',
        'is_approved': True,
        'is_available': True,
        'consultation_start': datetime.time(9, 0),
        'consultation_end': datetime.time(17, 0),
    },
    {
        'username': 'dr_anjali_mehta',
        'first_name': 'Dr. Anjali Mehta',
        'email': 'anjali.mehta@hospital.org',
        'department': 'General Medicine',
        'role': 'Doctor',
        'qualification': 'MBBS, MD',
        'specialty': 'General Medicine',
        'is_approved': True,
        'is_available': True,
        'consultation_start': datetime.time(10, 0),
        'consultation_end': datetime.time(18, 0),
    },
    # Cardiology
    {
        'username': 'dr_vikram_sen',
        'first_name': 'Dr. Vikram Sen',
        'email': 'vikram.sen@hospital.org',
        'department': 'Cardiology',
        'role': 'Doctor',
        'qualification': 'MBBS, MD, DM',
        'specialty': 'Cardiology Specialist',
        'is_approved': True,
        'is_available': True,
        'consultation_start': datetime.time(9, 0),
        'consultation_end': datetime.time(16, 0),
    },
    # Dermatology
    {
        'username': 'dr_kavita_shukla',
        'first_name': 'Dr. Kavita Shukla',
        'email': 'kavita.shukla@hospital.org',
        'department': 'Dermatology',
        'role': 'Doctor',
        'qualification': 'MBBS, MD (Skin)',
        'specialty': 'Dermatologist',
        'is_approved': True,
        'is_available': True,
        'consultation_start': datetime.time(10, 0),
        'consultation_end': datetime.time(17, 0),
    },
    # Pediatrics
    {
        'username': 'dr_sneha_roy',
        'first_name': 'Dr. Sneha Roy',
        'email': 'sneha.roy@hospital.org',
        'department': 'Pediatrics',
        'role': 'Doctor',
        'qualification': 'MBBS, MD, DCH',
        'specialty': 'Child Specialist',
        'is_approved': True,
        'is_available': True,
        'consultation_start': datetime.time(9, 0),
        'consultation_end': datetime.time(15, 0),
    },
    # Gynecology
    {
        'username': 'dr_sunita_rao',
        'first_name': 'Dr. Sunita Rao',
        'email': 'sunita.rao@hospital.org',
        'department': 'Gynecology',
        'role': 'Doctor',
        'qualification': 'MBBS, MS (OB-GYN)',
        'specialty': 'Gynecologist',
        'is_approved': True,
        'is_available': True,
        'consultation_start': datetime.time(10, 0),
        'consultation_end': datetime.time(17, 0),
    },
    # Orthopedics
    {
        'username': 'dr_rajesh_khanna',
        'first_name': 'Dr. Rajesh Khanna',
        'email': 'rajesh.khanna@hospital.org',
        'department': 'Orthopedics',
        'role': 'Doctor',
        'qualification': 'MBBS, MS Ortho',
        'specialty': 'Orthopedic Surgeon',
        'is_approved': True,
        'is_available': True,
        'consultation_start': datetime.time(9, 0),
        'consultation_end': datetime.time(17, 0),
    },
]


class Command(BaseCommand):
    help = 'Seed initial approved doctors across key departments.'

    def handle(self, *args, **options):
        created_count = 0
        for doc in DOCTORS_DATA:
            dept, _ = Department.objects.get_or_create(name=doc['department'])
            user, was_created = User.objects.get_or_create(
                username=doc['username'],
                defaults={
                    'first_name': doc['first_name'],
                    'email': doc['email'],
                    'is_active': True,
                },
            )
            if was_created:
                user.set_password('DoctorPass123!')
                user.save()

            profile, prof_created = DoctorProfile.objects.update_or_create(
                user=user,
                defaults={
                    'department': dept,
                    'role': doc['role'],
                    'qualification': doc['qualification'],
                    'specialty': doc['specialty'],
                    'is_approved': doc['is_approved'],
                    'is_available': doc['is_available'],
                    'consultation_start': doc['consultation_start'],
                    'consultation_end': doc['consultation_end'],
                },
            )
            if prof_created:
                created_count += 1

        self.stdout.write(self.style.SUCCESS(f'{created_count} doctors seeded/updated successfully.'))
