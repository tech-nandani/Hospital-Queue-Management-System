from django.contrib.auth.models import User
from django.db import transaction
from rest_framework import serializers

from .models import Appointment, Department, DoctorProfile, Notification, PatientProfile


class PatientRegisterSerializer(serializers.Serializer):
    name = serializers.CharField(max_length=150)
    email = serializers.EmailField()
    mobile = serializers.CharField(max_length=20)
    password = serializers.CharField(write_only=True, min_length=8)
    date_of_birth = serializers.DateField(required=False, allow_null=True)
    gender = serializers.CharField(max_length=20, required=False, allow_blank=True)
    address = serializers.CharField(required=False, allow_blank=True)

    def to_internal_value(self, data):
        data = data.copy() if hasattr(data, 'copy') else dict(data)
        if data.get('date_of_birth') == '':
            data['date_of_birth'] = None
        return super().to_internal_value(data)

    def validate_email(self, value):
        normalized = value.lower().strip()
        if User.objects.filter(username=normalized).exists() or User.objects.filter(email=normalized).exists():
            raise serializers.ValidationError('An account with this email already exists. Please login instead.')
        return normalized

    @transaction.atomic
    def create(self, validated_data):
        name = validated_data.pop('name')
        email = validated_data.pop('email').lower().strip()
        date_of_birth = validated_data.pop('date_of_birth', None)
        gender = validated_data.pop('gender', '')
        address = validated_data.pop('address', '')
        mobile = validated_data.pop('mobile', '')
        password = validated_data.pop('password')
        try:
            user = User.objects.create_user(
                username=email,
                email=email,
                password=password,
                first_name=name,
            )
        except Exception:
            raise serializers.ValidationError({'email': 'An account with this email already exists.'})

        PatientProfile.objects.create(
            user=user,
            mobile=mobile,
            date_of_birth=date_of_birth,
            gender=gender,
            address=address,
        )
        return user


class PatientProfileSerializer(serializers.ModelSerializer):
    name = serializers.CharField(source='user.first_name', required=False)
    email = serializers.EmailField(source='user.email', read_only=True)
    date_of_birth = serializers.DateField(required=False, allow_null=True)
    gender = serializers.CharField(max_length=20, required=False, allow_blank=True)
    address = serializers.CharField(required=False, allow_blank=True)

    class Meta:
        model = PatientProfile
        fields = ['name', 'email', 'mobile', 'date_of_birth', 'gender', 'address', 'allergies']

    def to_internal_value(self, data):
        data = data.copy() if hasattr(data, 'copy') else dict(data)
        if data.get('date_of_birth') == '':
            data['date_of_birth'] = None
        return super().to_internal_value(data)

    def update(self, instance, validated_data):
        user_data = validated_data.pop('user', {})
        if 'first_name' in user_data:
            instance.user.first_name = user_data['first_name']
            instance.user.save(update_fields=['first_name'])
        return super().update(instance, validated_data)


class DepartmentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Department
        fields = ['id', 'name', 'description']


class DoctorSerializer(serializers.ModelSerializer):
    name = serializers.CharField(source='user.get_full_name', read_only=True)
    department = DepartmentSerializer(read_only=True)

    class Meta:
        model = DoctorProfile
        fields = [
            'id', 'name', 'role', 'qualification', 'specialty',
            'hospital_name', 'city',
            'department', 'is_available', 'consultation_start', 'consultation_end',
        ]


class AppointmentSerializer(serializers.ModelSerializer):
    doctor_details = DoctorSerializer(source='doctor', read_only=True)
    department = serializers.CharField(source='doctor.department.name', read_only=True)
    patient_name = serializers.SerializerMethodField()
    patient_email = serializers.CharField(source='patient.email', read_only=True)
    patient_mobile = serializers.SerializerMethodField()
    patient_gender = serializers.SerializerMethodField()
    patient_age = serializers.SerializerMethodField()
    patient_dob = serializers.SerializerMethodField()

    class Meta:
        model = Appointment
        fields = [
            'id', 'patient', 'patient_name', 'patient_email', 'patient_mobile',
            'patient_gender', 'patient_age', 'patient_dob', 'doctor',
            'doctor_details', 'department', 'appointment_date', 'appointment_time',
            'queue_token', 'estimated_wait_minutes', 'priority', 'reason',
            'hospital_name', 'status', 'diagnosis', 'clinical_notes',
            'prescription', 'treatment_advice', 'follow_up_date',
            'consultation_completed_at', 'created_at', 'updated_at',
        ]
        read_only_fields = ['patient', 'queue_token', 'estimated_wait_minutes']

    def get_patient_name(self, obj):
        if obj.patient:
            return obj.patient.get_full_name() or obj.patient.first_name or obj.patient.username
        return 'Patient'

    def get_patient_mobile(self, obj):
        profile = getattr(obj.patient, 'patient_profile', None)
        return profile.mobile if profile else ''

    def get_patient_gender(self, obj):
        profile = getattr(obj.patient, 'patient_profile', None)
        return profile.gender if profile else ''

    def get_patient_dob(self, obj):
        profile = getattr(obj.patient, 'patient_profile', None)
        return str(profile.date_of_birth) if profile and profile.date_of_birth else ''

    def get_patient_age(self, obj):
        import datetime
        profile = getattr(obj.patient, 'patient_profile', None)
        if profile and profile.date_of_birth:
            today = datetime.date.today()
            return today.year - profile.date_of_birth.year - (
                (today.month, today.day) < (profile.date_of_birth.month, profile.date_of_birth.day)
            )
        return None


class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = ['id', 'title', 'message', 'is_read', 'created_at']