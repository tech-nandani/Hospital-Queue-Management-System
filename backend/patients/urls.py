from django.urls import include, path
from rest_framework.routers import DefaultRouter

from .views import (
    AIChatView,
    AppointmentViewSet,
    DepartmentViewSet,
    DoctorAvailabilityView,
    DoctorViewSet,
    GoogleLoginView,
    LoginView,
    MeView,
    NotificationViewSet,
    RegisterView,
    StaffLoginView,
    StaffQueueView,
)

router = DefaultRouter()
router.register('departments', DepartmentViewSet, basename='department')
router.register('doctors', DoctorViewSet, basename='doctor')
router.register('appointments', AppointmentViewSet, basename='appointment')
router.register('notifications', NotificationViewSet, basename='notification')

urlpatterns = [
    path('auth/register/', RegisterView.as_view(), name='register'),
    path('auth/login/', LoginView.as_view(), name='login'),
    path('auth/google/', GoogleLoginView.as_view(), name='google-login'),
    path('auth/staff-login/', StaffLoginView.as_view(), name='staff-login'),
    path('staff/queue/', StaffQueueView.as_view(), name='staff-queue'),
    path('staff/generate-token/', StaffQueueView.as_view(), name='staff-generate-token'),
    path('staff/doctor-availability/', DoctorAvailabilityView.as_view(), name='doctor-availability'),
    path('staff/doctors/<int:pk>/toggle-availability/', DoctorAvailabilityView.as_view(), name='doctor-toggle-availability'),
    path('profile/', MeView.as_view(), name='profile'),
    path('ai/chat/', AIChatView.as_view(), name='ai-chat'),
    path('', include(router.urls)),
]
