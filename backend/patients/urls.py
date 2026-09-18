from django.urls import include, path
from rest_framework.routers import DefaultRouter

from .views import (
    AIChatView,
    AppointmentViewSet,
    DepartmentViewSet,
    DoctorViewSet,
    LoginView,
    MeView,
    NotificationViewSet,
    RegisterView,
)

router = DefaultRouter()
router.register('departments', DepartmentViewSet, basename='department')
router.register('doctors', DoctorViewSet, basename='doctor')
router.register('appointments', AppointmentViewSet, basename='appointment')
router.register('notifications', NotificationViewSet, basename='notification')

urlpatterns = [
    path('auth/register/', RegisterView.as_view(), name='register'),
    path('auth/login/', LoginView.as_view(), name='login'),
    path('profile/', MeView.as_view(), name='profile'),
    path('ai/chat/', AIChatView.as_view(), name='ai-chat'),
    path('', include(router.urls)),
]
