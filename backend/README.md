# Hospital Queue Management Backend

Django 5 + Django REST Framework patient API.

## Setup

```powershell
cd backend
.venv\Scripts\Activate.ps1
python manage.py migrate
python manage.py seed_departments
python manage.py runserver
```

Base URL: `http://127.0.0.1:8000/api/patient/`

## Patient endpoints

- `POST auth/register/` - create patient account and receive token
- `POST auth/login/` - login with `email` and `password`
- `GET/PATCH profile/` - read or update patient profile
- `GET departments/` - active departments
- `GET doctors/?department=<id>` - approved available doctors/nurses
- `GET appointments/` - patient appointment history
- `POST appointments/` - book an appointment; queue token is generated server-side
- `POST appointments/<id>/cancel/` - cancel an appointment
- `POST appointments/<id>/reschedule/` - update appointment date/time
- `GET notifications/` - patient notifications
- `POST notifications/<id>/mark_read/` - mark a notification read

Use the token returned by register/login:

```http
Authorization: Token <token>
```

## Tests

```powershell
python manage.py test patients
```

The current development database is SQLite. Use PostgreSQL for production and move `SECRET_KEY`, CORS, and database credentials to environment variables before deployment.
