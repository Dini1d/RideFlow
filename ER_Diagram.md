# RideFlow Entity Relationship Diagram

This diagram is based on the table definitions in [`sql/rideflow.sql`](sql/rideflow.sql). It shows the declared foreign-key relationships. `PK` means primary key; `FK` means foreign key; `UK` means unique key.

```mermaid
erDiagram
    USERS {
        int id PK
        string name
        string email UK
        string phone
        enum role
        enum status
    }
    TRANSPORT_TYPES {
        int id PK
        string type_name
        string icon
        string color
        boolean is_active
    }
    VEHICLES {
        int id PK
        int type_id FK
        string vehicle_name
        string vehicle_number UK
        int capacity
        enum status
    }
    ROUTES {
        int id PK
        int type_id FK
        string route_name
        string origin
        string destination
        decimal distance_km
        string estimated_duration
        enum status
    }
    ROUTE_STOPS {
        int id PK
        int route_id FK
        string stop_name
        int stop_order
    }
    DRIVERS {
        int id PK
        int user_id FK_UK
        int vehicle_id FK
        string license_no
        int experience
        decimal rating
        enum status
    }
    SCHEDULES {
        int id PK
        int route_id FK
        int vehicle_id FK
        date departure_date
        time departure_time
        time arrival_time
        decimal fare
        int available_seats
        enum status
    }
    BOOKINGS {
        int id PK
        int user_id FK
        int schedule_id FK
        string booking_ref UK
        int seats_booked
        decimal total_fare
        enum booking_status
        enum payment_status
    }
    PAYMENTS {
        int id PK
        int booking_id FK
        int user_id FK
        enum gateway
        decimal amount
        string currency
        enum status
        string transaction_ref
        datetime paid_at
    }
    FEEDBACK {
        int id PK
        int user_id FK
        int booking_id FK "nullable"
        int rating
        string comment
        boolean is_public
    }
    NOTIFICATIONS {
        int id PK
        int user_id FK
        string title
        string message
        enum type
        boolean is_read
    }
    API_TOKENS {
        int id PK
        int user_id FK
        string token UK
        datetime expires_at
        datetime last_used
    }
    SUBSCRIPTIONS {
        int id PK
        string email UK
        string name
        boolean is_active
    }
    CHATBOT_MESSAGES {
        int id PK
        int user_id "nullable, no declared FK"
        string session_id
        enum role
        string message
    }
    CHATBOT_FAQ {
        int id PK
        string question
        string answer
        string keywords
        string category
        boolean is_active
        int sort_order
    }
    CONTACT_MESSAGES {
        int id PK
        string name
        string email
        string subject
        string message
        boolean is_read
    }
    SITE_SETTINGS {
        string setting_key PK
        string setting_value
    }
    OTP_CODES {
        int id PK
        string phone
        string code
        string purpose
        datetime expires_at
        boolean used
    }

    TRANSPORT_TYPES ||--o{ VEHICLES : classifies
    TRANSPORT_TYPES ||--o{ ROUTES : serves
    ROUTES ||--o{ ROUTE_STOPS : contains
    ROUTES ||--o{ SCHEDULES : has
    VEHICLES ||--o{ SCHEDULES : assigned_to
    USERS ||--o| DRIVERS : has_driver_profile
    VEHICLES o|--o{ DRIVERS : assigned_to
    USERS ||--o{ BOOKINGS : places
    SCHEDULES ||--o{ BOOKINGS : receives
    BOOKINGS ||--o{ PAYMENTS : has_transactions
    USERS ||--o{ PAYMENTS : pays
    USERS ||--o{ FEEDBACK : writes
    BOOKINGS o|--o{ FEEDBACK : receives
    USERS ||--o{ NOTIFICATIONS : receives
    USERS ||--o{ API_TOKENS : owns
```

## Tables without declared foreign keys

`SUBSCRIPTIONS`, `CHATBOT_FAQ`, `CONTACT_MESSAGES`, `SITE_SETTINGS`, and `OTP_CODES` are standalone tables in the SQL schema. `CHATBOT_MESSAGES.user_id` can hold a user ID, but the schema does not declare a foreign-key constraint for it, so no enforced relationship is drawn.
