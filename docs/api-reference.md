# API Reference

Complete API documentation for the Python Flask App.

## Base URL

- **Local Development**: `http://localhost:8080`
- **Kubernetes Service**: `http://python-app:8080`
- **Production**: Configured via Ingress

## Endpoints

### General Endpoints

#### GET /

Returns a welcome message.

**Response:**
```json
{
  "message": "Hello World!"
}
```

**Example:**
```bash
curl http://localhost:8080/
```

#### GET /hello

Returns a hello message.

**Response:**
```json
{
  "message": "Hello World!"
}
```

**Example:**
```bash
curl http://localhost:8080/hello
```

### Health Check

#### GET /health

Lightweight health check endpoint for Kubernetes probes.

**Response:**
```json
{
  "status": "healthy"
}
```

**Status Codes:**
- `200` - Application is healthy

**Example:**
```bash
curl http://localhost:8080/health
```

### Date and Time Endpoints

#### GET /datetime

Returns current date, time, datetime, and timestamp.

**Response:**
```json
{
  "date": "2024-01-15",
  "time": "14:30:25",
  "datetime": "2024-01-15 14:30:25",
  "timestamp": 1705327825.123456
}
```

**Example:**
```bash
curl http://localhost:8080/datetime
```

#### GET /time

Returns current time and timezone.

**Response:**
```json
{
  "current_time": "14:30:25",
  "timezone": "local"
}
```

**Example:**
```bash
curl http://localhost:8080/time
```

#### GET /date

Returns current date with day of week and month name.

**Response:**
```json
{
  "current_date": "2024-01-15",
  "day_of_week": "Monday",
  "month": "January"
}
```

**Example:**
```bash
curl http://localhost:8080/date
```

## Response Format

All endpoints return JSON responses with appropriate HTTP status codes.

### Success Responses

- Status Code: `200 OK`
- Content-Type: `application/json`

### Error Responses

Currently, the API does not implement error handling. All endpoints return `200 OK` status.

## Rate Limiting

No rate limiting is currently implemented.

## Authentication

No authentication is required for any endpoints.

## OpenAPI Specification

The complete OpenAPI 3.0 specification is available in the `catalog-info.yaml` file and can be viewed in Backstage.

