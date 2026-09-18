from django.core.management.base import BaseCommand

from patients.models import Department


DEPARTMENTS = [
    'General Medicine',
    'Cardiology',
    'Neurology',
    'Pediatrics',
    'Orthopedics',
    'Dermatology',
    'Gynecology',
    'Ophthalmology',
    'ENT',
    'Dentistry',
    'Pulmonology',
    'Gastroenterology',
    'Psychiatry',
    'Oncology',
    'Emergency Medicine',
]


class Command(BaseCommand):
    help = 'Create the default hospital departments.'

    def handle(self, *args, **options):
        created = 0
        for name in DEPARTMENTS:
            _, was_created = Department.objects.get_or_create(name=name)
            created += int(was_created)
        self.stdout.write(self.style.SUCCESS(f'{created} departments created; seed is complete.'))
