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
            'department', 'is_available', 'consultation_start', 'consultation_end',
        ]


class AppointmentSerializer(serializers.ModelSerializer):
    doctor_details = DoctorSerializer(source='doctor', read_only=True)
    department = serializers.CharField(source='doctor.department.name', read_only=True)

    class Meta:
        model = Appointment
        fields = [
            'id', 'doctor', 'doctor_details', 'department', 'appointment_date',
            'appointment_time', 'queue_token', 'estimated_wait_minutes',
            'reason', 'hospital_name', 'status', 'created_at', 'updated_at',
        ]
        read_only_fields = ['queue_token', 'estimated_wait_minutes', 'status']


class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = ['id', 'title', 'message', 'is_read', 'created_at']