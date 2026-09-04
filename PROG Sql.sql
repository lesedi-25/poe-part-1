IF DB_ID('RaceDay') IS NOT NULL
BEGIN
    ALTER DATABASE RaceDayDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE RaceDayDB;
END
GO

CREATE DATABASE RaceDayDB;
GO

USE RaceDayDB;
GO

-- ============================================================
-- 1. USERS  (Organisers + Participants)
-- ============================================================
CREATE TABLE Users (
    UserId          INT             IDENTITY(1,1) PRIMARY KEY,
    FirstName       VARCHAR(50)     NOT NULL,
    LastName        VARCHAR(50)     NOT NULL,
    Email           VARCHAR(100)    NOT NULL UNIQUE,
    PasswordHash    VARCHAR(255)    NOT NULL,
    PhoneNumber     VARCHAR(20)     NULL,
    DateOfBirth     DATE            NULL,
    Role            VARCHAR(20)     NOT NULL
                        CONSTRAINT CK_Users_Role CHECK (Role IN ('Participant', 'Organiser')),
    CreatedAt       DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

-- ============================================================
-- 2. EVENTS
-- ============================================================
CREATE TABLE Events (
    EventId                 INT             IDENTITY(1,1) PRIMARY KEY,
    OrganiserId             INT             NOT NULL,
    EventName               VARCHAR(100)    NOT NULL,
    EventDescription        VARCHAR(MAX)    NULL,
    EventDate               DATE            NOT NULL,
    Location                VARCHAR(150)    NOT NULL,
    EventType               VARCHAR(50)     NOT NULL,
    DistanceKm              DECIMAL(6,2)    NOT NULL
                                CONSTRAINT CK_Events_DistanceKm CHECK (DistanceKm > 0),
    EntryFee                DECIMAL(8,2)    NOT NULL DEFAULT 0
                                CONSTRAINT CK_Events_EntryFee CHECK (EntryFee >= 0),
    RegistrationDeadline    DATE            NOT NULL,
    CreatedAt               DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_Events_Organiser FOREIGN KEY (OrganiserId)
        REFERENCES Users(UserId),
    CONSTRAINT CK_Events_DeadlineBeforeDate CHECK (RegistrationDeadline <= EventDate)
);
GO

-- ============================================================
-- 3. CATEGORIES
-- ============================================================
CREATE TABLE Categories (
    CategoryId      INT             IDENTITY(1,1) PRIMARY KEY,
    EventId         INT             NOT NULL,
    CategoryName    VARCHAR(50)     NOT NULL,
    MinimumAge      INT             NULL
                        CONSTRAINT CK_Categories_MinAge CHECK (MinimumAge >= 0),
    MaximumAge      INT             NULL,
    Description     VARCHAR(255)    NULL,
    CONSTRAINT FK_Categories_Event FOREIGN KEY (EventId)
        REFERENCES Events(EventId) ON DELETE CASCADE,
    CONSTRAINT CK_Categories_AgeRange CHECK (
        MaximumAge IS NULL OR MinimumAge IS NULL OR MaximumAge >= MinimumAge
    ),
    CONSTRAINT UQ_Categories_EventName UNIQUE (EventId, CategoryName)
);
GO

-- ============================================================
-- 4. ENROLMENTS
-- ============================================================
CREATE TABLE Enrolments (
    EnrolmentId     INT             IDENTITY(1,1) PRIMARY KEY,
    EventId         INT             NOT NULL,
    ParticipantId   INT             NOT NULL,
    CategoryId      INT             NOT NULL,
    EnrolmentDate   DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    Status          VARCHAR(20)     NOT NULL DEFAULT 'Active'
                        CONSTRAINT CK_Enrolments_Status CHECK (Status IN ('Active', 'Cancelled')),
    CONSTRAINT FK_Enrolments_Event FOREIGN KEY (EventId)
        REFERENCES Events(EventId),
    CONSTRAINT FK_Enrolments_Participant FOREIGN KEY (ParticipantId)
        REFERENCES Users(UserId),
    CONSTRAINT FK_Enrolments_Category FOREIGN KEY (CategoryId)
        REFERENCES Categories(CategoryId),
    CONSTRAINT UQ_Enrolments_EventParticipant UNIQUE (EventId, ParticipantId)
);
GO

-- ============================================================
-- 5. RESULTS
-- ============================================================
CREATE TABLE Results (
    ResultId        INT             IDENTITY(1,1) PRIMARY KEY,
    EnrolmentId     INT             NOT NULL UNIQUE,
    FinishTime      TIME            NULL,
    Position        INT             NULL
                        CONSTRAINT CK_Results_Position CHECK (Position > 0),
    Status          VARCHAR(20)     NOT NULL DEFAULT 'Finished'
                        CONSTRAINT CK_Results_Status CHECK (Status IN ('Finished', 'DNF', 'DSQ')),
    RecordedAt      DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_Results_Enrolment FOREIGN KEY (EnrolmentId)
        REFERENCES Enrolments(EnrolmentId) ON DELETE CASCADE
);
GO

-- ============================================================
-- 6. ROUTES
-- ============================================================
CREATE TABLE Routes (
    RouteId             INT             IDENTITY(1,1) PRIMARY KEY,
    EventId             INT             NOT NULL,
    RouteName           VARCHAR(100)    NOT NULL,
    DistanceKm          DECIMAL(6,2)    NOT NULL
                            CONSTRAINT CK_Routes_DistanceKm CHECK (DistanceKm > 0),
    RouteDescription    VARCHAR(MAX)    NULL,
    StartLocation       VARCHAR(150)    NOT NULL,
    EndLocation         VARCHAR(150)    NOT NULL,
    CONSTRAINT FK_Routes_Event FOREIGN KEY (EventId)
        REFERENCES Events(EventId) ON DELETE CASCADE
);
GO

-- ============================================================
-- 7. WEATHER
-- ============================================================
CREATE TABLE Weather (
    WeatherId               INT             IDENTITY(1,1) PRIMARY KEY,
    EventId                 INT             NOT NULL UNIQUE,
    Temperature             DECIMAL(4,1)    NULL,
    Conditions              VARCHAR(100)    NULL,
    WindSpeedKmh            DECIMAL(5,1)    NULL,
    PrecipitationChance     INT             NULL
                                CONSTRAINT CK_Weather_Precip CHECK (PrecipitationChance BETWEEN 0 AND 100),
    RetrievedAt             DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_Weather_Event FOREIGN KEY (EventId)
        REFERENCES Events(EventId) ON DELETE CASCADE
);
GO



-- ---------- Users: 2 Organisers, 2 Participants ----------
INSERT INTO Users (FirstName, LastName, Email, PasswordHash, PhoneNumber, DateOfBirth, Role)
VALUES
    ('Thandiwe', 'Nkosi',   'thandiwe.nkosi@raceday.co.za', 'hashed_pw_1', '0821234567', '1985-03-12', 'Organiser'),
    ('Marco',    'Fischer', 'marco.fischer@raceday.co.za',  'hashed_pw_2', '0827654321', '1979-11-02', 'Organiser'),
    ('Lindiwe',  'Dlamini', 'lindiwe.dlamini@example.com',  'hashed_pw_3', '0731239876', '1996-06-25', 'Participant'),
    ('Ben',      'Coetzee', 'ben.coetzee@example.com',      'hashed_pw_4', '0839871234', '1990-01-18', 'Participant');
GO

-- ---------- Events: 3 ----------
INSERT INTO Events (OrganiserId, EventName, EventDescription, EventDate, Location, EventType, DistanceKm, EntryFee, RegistrationDeadline)
VALUES
    (1, 'Johannesburg City Marathon', 'A full 42.2km road marathon through the city centre.', '2026-11-08', 'Johannesburg, Gauteng', 'Marathon', 42.20, 450.00, '2026-10-25'),
    (1, 'Sandton Fun Run',            'A family-friendly 5km fun run and walk.',               '2026-09-20', 'Sandton, Gauteng',       'Fun Run',  5.00,  120.00, '2026-09-15'),
    (2, 'Cape Town Trail Challenge',  'A 21.1km trail half-marathon over Table Mountain paths.', '2026-10-04', 'Cape Town, Western Cape', 'Trail',    21.10, 350.00, '2026-09-27');
GO

-- ---------- Categories: for every event ----------
INSERT INTO Categories (EventId, CategoryName, MinimumAge, MaximumAge, Description)
VALUES
    (1, 'Open Marathon', 18, 39,  'Standard open division for the full marathon.'),
    (1, 'Masters',       40, 99,  'Marathon division for runners aged 40 and over.'),
    (2, 'Under 18 Fun Run', 0, 17, 'Fun run category for participants under 18.'),
    (2, 'Open Fun Run',    18, 99, 'Fun run category for adult participants.'),
    (3, 'Elite Trail',   18, 39,  'Competitive trail division.'),
    (3, 'Novice Trail',  18, 99,  'Recreational trail division, no age cap.');
GO

-- ---------- Enrolments ----------
INSERT INTO Enrolments (EventId, ParticipantId, CategoryId, Status)
VALUES
    (1, 3, 1, 'Active'),   
    (1, 4, 2, 'Active'),   
    (2, 3, 4, 'Active'),   
    (3, 4, 6, 'Active');   
GO

-- ---------- Results ----------
INSERT INTO Results (EnrolmentId, FinishTime, Position, Status)
VALUES
    (1, '03:45:22', 12, 'Finished'),
    (2, '04:10:05', 25, 'Finished'), 
    (3, NULL,       NULL, 'DNF');     
GO

-- ---------- Routes ----------
INSERT INTO Routes (EventId, RouteName, DistanceKm, RouteDescription, StartLocation, EndLocation)
VALUES
    (1, 'City Loop Marathon Route', 42.20, 'Loops through the CBD, Braamfontein and Melville before finishing at the stadium.', 'FNB Stadium', 'FNB Stadium'),
    (2, 'Sandton Central 5km',       5.00, 'A flat, closed-road loop around Sandton Central.', 'Nelson Mandela Square', 'Nelson Mandela Square'),
    (3, 'Table Mountain Trail',     21.10, 'Technical single-track trail with significant elevation gain.', 'Kirstenbosch Gate', 'Constantia Nek');
GO

-- ---------- Weather ----------
INSERT INTO Weather (EventId, Temperature, Conditions, WindSpeedKmh, PrecipitationChance)
VALUES
    (1, 16.5, 'Partly cloudy', 12.0, 10),
    (2, 22.0, 'Sunny',          8.0,  0),
    (3, 14.0, 'Windy, chance of showers', 28.0, 45);
GO