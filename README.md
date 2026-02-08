# Taxi Fleet — Microservices Platform

A distributed taxi fleet management platform built with **11 microservices**, event-driven architecture via **Apache Kafka**, polyglot persistence, and a **Flutter** mobile app.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Mobile App                        │
│              (Driver & Passenger Interface)                  │
└──────────────────────────┬──────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────┐
│                    API Gateway                               │
│              (MSTxFleet-Api-Gateway)                         │
└──────────────────────────┬──────────────────────────────────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
   ┌────▼────┐     ┌──────▼──────┐    ┌─────▼─────┐
   │  Auth   │     │  Location   │    │   Trip    │
   │ Service │     │  Service    │    │  Service  │
   └────┬────┘     └──────┬──────┘    └─────┬─────┘
        │                 │                  │
   ┌────▼────┐     ┌──────▼──────┐    ┌─────▼─────┐
   │  Redis  │     │   PostGIS   │    │ Cassandra │
   └─────────┘     └─────────────┘    └───────────┘
                                            │
                   ┌────────────────────────▼─────┐
                   │     Kafka Event Bus           │
                   │  (Async Communication)        │
                   └────────────────┬──────────────┘
                                    │
                   ┌────────────────▼──────────────┐
                   │    Kafka Consumer Service      │
                   └───────────────────────────────┘
```

## Microservices

| Service | Repository | Description |
|---------|-----------|-------------|
| **Frontend** | `taxi_fleet_frontend_app` | Flutter mobile app for drivers and passengers |
| **API Gateway** | `MSTxFleet-Api-Gateway` | Request routing, load balancing, rate limiting |
| **Auth Service** | `MSTxFleet-Auth` | Authentication and authorization |
| **Registry** | `MSTxFleet-Registry-Service` | Service discovery and registration |
| **Location Service** | `MSTxFleet-Location` | Real-time geospatial tracking |
| **Trip Service** | `MSTxFleet-Trip` | Trip lifecycle management |
| **Kafka Consumer** | `MSTxFleet-Kafka-Consumer` | Async event processing |
| **Cassandra DB** | `MSTxFleet-DBS-Cassandra` | Time-series data store config |
| **MongoDB** | `MSTxFleet-DBS-MongoDb` | Document store config |
| **Redis** | `MSTxFleet-DBS-Redis` | Cache and session store config |
| **PostGIS** | `MSTxFleet-DBS-Postgis` | Spatial database config |

## Tech Stack

### Backend
- **Java** — Spring Boot microservices
- **Apache Kafka** — Event-driven messaging
- **Spring Cloud** — Service discovery, API gateway, config management

### Databases (Polyglot Persistence)
- **Apache Cassandra** — Time-series trip data
- **MongoDB** — Document storage for flexible schemas
- **Redis** — Caching, session management, real-time data
- **PostGIS** (PostgreSQL) — Geospatial queries and location tracking

### Frontend
- **Flutter / Dart** — Cross-platform mobile application

### Infrastructure
- **Docker** — Containerized services
- **Eureka** — Service registry
- **Spring Cloud Gateway** — API gateway

## Key Design Decisions

- **Event-driven architecture**: Services communicate asynchronously via Kafka topics, enabling loose coupling and resilience
- **Polyglot persistence**: Each service uses the database best suited for its data model
- **Domain-driven design**: Services are organized around business capabilities (Auth, Location, Trip)
- **API Gateway pattern**: Single entry point for client requests with routing and cross-cutting concerns

## Getting Started

### Prerequisites

- Java 17+
- Docker & Docker Compose
- Flutter SDK

### Running Locally

```bash
# Start infrastructure (databases, Kafka, etc.)
docker-compose up -d

# Start services (each in its own terminal)
cd MSTxFleet-Registry-Service && ./mvnw spring-boot:run
cd MSTxFleet-Auth && ./mvnw spring-boot:run
cd MSTxFleet-Api-Gateway && ./mvnw spring-boot:run
cd MSTxFleet-Location && ./mvnw spring-boot:run
cd MSTxFleet-Trip && ./mvnw spring-boot:run
cd MSTxFleet-Kafka-Consumer && ./mvnw spring-boot:run

# Start mobile app
cd taxi_fleet_frontend_app && flutter run
```

## Organization

All repositories are under the [ILISI3-Taxi-Fleet-project](https://github.com/orgs/ILISI3-Taxi-Fleet-project/repositories) GitHub organization.

## Academic Context

Built as part of the ILISI3 (Computer Engineering) curriculum, focusing on distributed systems, microservices architecture, and event-driven design patterns.

## License

This project is provided for educational purposes.
