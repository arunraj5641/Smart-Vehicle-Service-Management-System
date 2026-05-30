# 🚗 Vehicle Service Management System 

A production-grade Rails API for managing vehicles, service centers, and service records with role-based access control (RBAC) and multi-tenant architecture.

---

## 🚀 Features

### 🔐 Authentication & Authorization

* JWT-based authentication
* Role-based access control (RBAC)

  * 👤 User
  * 🏢 Service Centre
  * 👑 Admin

---

### 🚗 Vehicles (User-owned)

* Create, view, update, delete vehicles
* Ownership validation enforced
* Pagination support

---

### 🏢 Service Types (Multi-Tenant)

* Each service centre manages its own services
* Scoped uniqueness (no global conflicts)
* Full CRUD support

---

### 🛠 Service Records

* Created and managed by service centres
* Linked to vehicles and service types
* Status lifecycle:

  * `scheduled → in_progress → completed`
* Filtering support:

  * by vehicle
  * by status
  * by service type

---

### 📊 Analytics

* Vehicle-wise service cost analysis
* Monthly cost breakdown
* Secure, user-scoped queries

---

### 👤 User Management

* Register / Login
* Fetch current user (`/me`)
* Admin-only user listing

---

### 🔒 Security

* Multi-tenant data isolation
* Strict RBAC enforcement
* No cross-user or cross-centre data access
* No sensitive data exposure (e.g., password_digest)

---

## 🛠 Tech Stack

* Ruby on Rails (API mode)
* PostgreSQL
* JWT Authentication
* Service Object Pattern
* RESTful API design

---

## 📂 API Endpoints

### 🔐 Auth

* `POST /api/v1/auth/register`
* `POST /api/v1/auth/login`
* `POST /api/v1/auth/logout`

---

### 👤 User

* `GET /api/v1/me`
* `GET /api/v1/users` (admin only)

---

### 🚗 Vehicles

* `POST /api/v1/vehicles`
* `GET /api/v1/vehicles`
* `GET /api/v1/vehicles/:id`
* `PATCH /api/v1/vehicles/:id`
* `DELETE /api/v1/vehicles/:id`

---

### 🏢 Service Types

* `POST /api/v1/service_types`
* `GET /api/v1/service_types`
* `GET /api/v1/service_types/:id`
* `PATCH /api/v1/service_types/:id`
* `DELETE /api/v1/service_types/:id`

---

### 🛠 Service Records

* `POST /api/v1/service_records`
* `GET /api/v1/service_records`
* `GET /api/v1/service_records/:id`
* `PATCH /api/v1/service_records/:id`
* `PATCH /api/v1/service_records/:id/status`

---

### 📊 Analytics

* `GET /api/v1/analytics/vehicle_costs`
* `GET /api/v1/analytics/monthly_costs`

---

## ⚙️ Setup Instructions

### 1. Clone the repository

```bash
git clone <your-repo-url>
cd <project-folder>
```

---

### 2. Install dependencies

```bash
bundle install
```

---

### 3. Setup environment variables

Create a `.env` file:

```env
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_password
DB_HOST=localhost
DB_PORT=5432
```

---

### 4. Setup database

```bash
rails db:create
rails db:migrate
```

---

### 5. Run the server

```bash
rails server
```

---

## 🧪 API Response Format

All responses follow a consistent structure:

```json
{
  "success": true,
  "message": "Success",
  "data": {},
  "meta": {
    "request_id": "uuid"
  },
  "timestamp": "ISO8601"
}
```

---

## 🧠 Architecture Highlights

* Thin controllers, business logic in services/models
* Multi-tenant design (service-centre scoped data)
* Strong validation & DB constraints
* Scalable and maintainable structure

---

## 📌 Future Improvements

* Add automated test suite (RSpec)
* Implement rate limiting for auth endpoints
* Add background jobs for analytics
* Enhance admin dashboard capabilities

---

## 👨‍💻 Author

Built as a production-grade backend system focusing on clean architecture, scalability, and real-world design patterns.

---
