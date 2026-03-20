# TaskFlow — Task Management System

A full-stack task management app built with **Node.js + TypeScript + Prisma** (backend) and **Next.js + TypeScript + Tailwind** (frontend).

---

## Project Structure

```
taskflow/
├── backend/          # Node.js + Express + TypeScript + Prisma
├── frontend/         # Next.js 14 App Router + TypeScript + Tailwind
├── mobile/           # Flutter (Track B) — Android/iOS
└── taskflow.code-workspace
```

---

## Quick Start

### 1. Open in VS Code

```bash
code taskflow.code-workspace
```

---

### 2. Backend Setup

```bash
cd backend

# Install dependencies
npm install

# Copy env file and edit values
cp .env.example .env

# Generate Prisma client & create SQLite DB
npx prisma generate
npx prisma db push

# Start dev server (http://localhost:4000)
npm run dev
```

**Backend `.env` variables:**
| Variable | Description |
|---|---|
| `DATABASE_URL` | PostgreSQL URL, e.g. `postgresql://postgres:password@localhost:5435/taskmanager` |
| `JWT_ACCESS_SECRET` | Secret for signing access tokens |
| `JWT_REFRESH_SECRET` | Secret for signing refresh tokens |
| `JWT_ACCESS_EXPIRES_IN` | e.g. `15m` |
| `JWT_REFRESH_EXPIRES_IN` | e.g. `7d` |
| `PORT` | Default `4000` |
| `CORS_ORIGIN` | Frontend URL, e.g. `http://localhost:3000` |

---

### 3. Frontend Setup

```bash
cd frontend

# Install dependencies
npm install

# Copy env file
cp .env.example .env.local

# Start dev server (http://localhost:3000)
npm run dev
```

---

## API Endpoints

### Auth
| Method | Endpoint | Description |
|---|---|---|
| POST | `/auth/register` | Register a new user |
| POST | `/auth/login` | Login, returns tokens |
| POST | `/auth/refresh` | Rotate access + refresh tokens |
| POST | `/auth/logout` | Revoke refresh token |

### Tasks (all require `Authorization: Bearer <token>`)
| Method | Endpoint | Description |
|---|---|---|
| GET | `/tasks` | List tasks (paginated, filterable, searchable) |
| POST | `/tasks` | Create a task |
| GET | `/tasks/:id` | Get a single task |
| PATCH | `/tasks/:id` | Update a task |
| DELETE | `/tasks/:id` | Delete a task |
| PATCH | `/tasks/:id/toggle` | Toggle PENDING ↔ COMPLETED |

**GET /tasks query params:**
- `page` (default: 1)
- `limit` (default: 10)
- `status`: `PENDING` | `IN_PROGRESS` | `COMPLETED`
- `search`: searches by title

---

## Tech Stack

### Backend
- **Runtime**: Node.js
- **Language**: TypeScript
- **Framework**: Express.js
- **ORM**: Prisma
- **Database**: SQLite (swap to PostgreSQL by changing `DATABASE_URL` in `.env`)
- **Auth**: JWT (access + refresh tokens), bcryptjs

### Frontend
- **Framework**: Next.js 14 (App Router)
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **Forms**: react-hook-form + zod
- **HTTP**: Axios (with auto token refresh interceptor)
- **Toast notifications**: react-hot-toast

---

## Production Build

```bash
# Backend
cd backend && npm run build && npm start

# Frontend
cd frontend && npm run build && npm start
```

---

## Database

This project uses **PostgreSQL**. The connection is pre-configured for:
```
postgresql://postgres:Meerut@12@localhost:5435/taskmanager
```
Make sure your PostgreSQL server is running on port `5435` and the `taskmanager` database exists before running migrations.
