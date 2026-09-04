# poe part 1# RaceDay

## System Description

RaceDay is a web-based event management system designed for the South African road running, walking, and cycling community.

The system allows event organisers to create and manage events, categories, participant enrolments, routes, weather information, and race results. Participants can browse available events, enrol in events, and view their results and performance history.

## User Roles

### 1. Event Organiser

The Event Organiser can:

- Create and manage events
- Create and manage event categories
- View participant enrolments
- Add and update race results
- Add and manage event route information
- Manage event information

### 2. Participant

The Participant can:

- Register and log into the system
- View upcoming events
- View event details and categories
- Enrol in events
- View their enrolments
- Cancel an enrolment
- View their race results and performance history
- View route and weather information

## Database

The RaceDay database is implemented using Microsoft SQL Server.

The database contains the following tables:

- Users
- Events
- Categories
- Enrolments
- Results
- Routes
- Weather

The database design and relationships are documented in the ERD located in the `/docs` folder.

## Documentation

The `/docs` folder contains the project's planning and database documentation:

- `RaceDay_ERD.png` – Entity Relationship Diagram
- `RaceDay_Endpoint_Plan.xlsx` – API endpoint plan
- `PROG Sql.sql` – SQL database creation and sample data script

## API

The planned API endpoints are documented in:

`/docs/RaceDay_Endpoint_Plan.xlsx`

The endpoint plan defines the HTTP methods, routes, descriptions, required roles, request information, and expected responses.


- Microsoft SQL Server
- GitHub
- GitHub Actions
