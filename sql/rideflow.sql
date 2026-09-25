-- ============================================================
-- RideFlow Transport Management System — Database Schema
-- Version: 2.0 | Engine: InnoDB | Charset: utf8mb4
-- ============================================================
CREATE DATABASE IF NOT EXISTS rideflow CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE rideflow;

SET FOREIGN_KEY_CHECKS = 0;
SET SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';

-- ── USERS ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
  id               INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name             VARCHAR(120)  NOT NULL,
  email            VARCHAR(180)  NULL UNIQUE,
  phone            VARCHAR(20)   NOT NULL DEFAULT '',
  password         VARCHAR(255)  NOT NULL DEFAULT '',
  password_hash    VARCHAR(255) NULL,
  role             ENUM('admin','customer','driver') NOT NULL DEFAULT 'customer',
  status           ENUM('pending','active','inactive','suspended') NOT NULL DEFAULT 'pending',
  phone_verified   TINYINT(1) NOT NULL DEFAULT 0,
  email_verified   TINYINT(1) NOT NULL DEFAULT 0,
  email_token      VARCHAR(64)  NULL,
  id_type          ENUM('NIC','Passport','Driver License','Other') NULL,
  id_number        VARCHAR(120) NULL,
  selfie_url       VARCHAR(500) NULL,
  id_document_url  VARCHAR(500) NULL,
  verification_status ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  verification_note TEXT NULL,
  reset_token      VARCHAR(64)  NULL,
  social_provider  VARCHAR(40)  NULL,
  social_id        VARCHAR(255) NULL,
  avatar_url       VARCHAR(500) NULL,
  address          TEXT         NULL,
  created_at       TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
  updated_at       TIMESTAMP    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_social (social_provider, social_id),
  INDEX idx_email (email),
  INDEX idx_phone (phone),
  INDEX idx_role  (role),
  INDEX idx_status(status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── TRANSPORT TYPES ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS transport_types (
  id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  type_name  VARCHAR(50) NOT NULL,
  icon       VARCHAR(30) NOT NULL DEFAULT 'bus',
  color      VARCHAR(10) NOT NULL DEFAULT '#ff6a00',
  is_active  TINYINT(1)  NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── VEHICLES ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS vehicles (
  id             INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  type_id        INT UNSIGNED NOT NULL,
  vehicle_name   VARCHAR(100) NOT NULL,
  vehicle_number VARCHAR(30)  NOT NULL UNIQUE,
  capacity       INT UNSIGNED NOT NULL DEFAULT 40,
  amenities      TEXT         NULL COMMENT 'JSON: ["AC","WiFi","USB"]',
  status         ENUM('active','maintenance','retired') NOT NULL DEFAULT 'active',
  created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (type_id) REFERENCES transport_types(id) ON DELETE RESTRICT,
  INDEX idx_type   (type_id),
  INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── ROUTES ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS routes (
  id                 INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  type_id            INT UNSIGNED NOT NULL,
  route_name         VARCHAR(150) NOT NULL,
  origin             VARCHAR(100) NOT NULL,
  destination        VARCHAR(100) NOT NULL,
  distance_km        DECIMAL(8,2) NULL,
  estimated_duration VARCHAR(30)  NULL,
  status             ENUM('active','inactive') NOT NULL DEFAULT 'active',
  created_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (type_id) REFERENCES transport_types(id) ON DELETE RESTRICT,
  INDEX idx_origin (origin),
  INDEX idx_dest   (destination),
  INDEX idx_type   (type_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── ROUTE STOPS ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS route_stops (
  id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  route_id   INT UNSIGNED NOT NULL,
  stop_name  VARCHAR(100) NOT NULL,
  stop_order INT          NOT NULL DEFAULT 0,
  FOREIGN KEY (route_id) REFERENCES routes(id) ON DELETE CASCADE,
  INDEX idx_route (route_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── DRIVERS ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS drivers (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id     INT UNSIGNED NOT NULL,
  vehicle_id  INT UNSIGNED NULL,
  license_no  VARCHAR(50)  NOT NULL,
  experience  INT          NOT NULL DEFAULT 0 COMMENT 'Years',
  rating      DECIMAL(3,2) NOT NULL DEFAULT 5.00,
  status      ENUM('active','inactive','on_trip') NOT NULL DEFAULT 'active',
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id)    REFERENCES users(id)    ON DELETE CASCADE,
  FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE SET NULL,
  UNIQUE KEY uk_user (user_id),
  INDEX idx_vehicle (vehicle_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── SCHEDULES ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS schedules (
  id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  route_id        INT UNSIGNED NOT NULL,
  vehicle_id      INT UNSIGNED NOT NULL,
  departure_date  DATE         NOT NULL,
  departure_time  TIME         NOT NULL,
  arrival_time    TIME         NULL,
  fare            DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  available_seats INT          NOT NULL DEFAULT 0,
  status          ENUM('scheduled','departed','arrived','cancelled') NOT NULL DEFAULT 'scheduled',
  created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (route_id)   REFERENCES routes(id)   ON DELETE CASCADE,
  FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE RESTRICT,
  INDEX idx_route   (route_id),
  INDEX idx_vehicle (vehicle_id),
  INDEX idx_date    (departure_date),
  INDEX idx_status  (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── BOOKINGS ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS bookings (
  id               INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id          INT UNSIGNED NOT NULL,
  schedule_id      INT UNSIGNED NOT NULL,
  booking_ref      VARCHAR(20)  NOT NULL UNIQUE,
  seats_booked     INT          NOT NULL DEFAULT 1,
  total_fare       DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  passenger_name   VARCHAR(120) NOT NULL,
  passenger_phone  VARCHAR(20)  NOT NULL,
  passenger_email  VARCHAR(180) NULL,
  booking_status   ENUM('pending','confirmed','cancelled','completed','no_show') NOT NULL DEFAULT 'pending',
  payment_status   ENUM('unpaid','paid','refunded','failed') NOT NULL DEFAULT 'unpaid',
  qr_code          TEXT         NULL COMMENT 'Base64 QR data',
  notes            TEXT         NULL,
  booked_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id)     REFERENCES users(id)     ON DELETE CASCADE,
  FOREIGN KEY (schedule_id) REFERENCES schedules(id) ON DELETE RESTRICT,
  INDEX idx_user     (user_id),
  INDEX idx_schedule (schedule_id),
  INDEX idx_status   (booking_status),
  INDEX idx_payment  (payment_status),
  INDEX idx_ref      (booking_ref)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── PAYMENTS ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS payments (
  id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  booking_id      INT UNSIGNED NOT NULL,
  user_id         INT UNSIGNED NOT NULL,
  gateway         ENUM('stripe','paypal','ezCash','genie','bank_transfer','cash') NOT NULL DEFAULT 'cash',
  amount          DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  currency        VARCHAR(5)    NOT NULL DEFAULT 'LKR',
  status          ENUM('pending','completed','failed','refunded') NOT NULL DEFAULT 'pending',
  transaction_ref VARCHAR(100) NULL,
  gateway_ref     VARCHAR(200) NULL COMMENT 'External gateway transaction ID',
  gateway_data    TEXT         NULL COMMENT 'JSON response from gateway',
  paid_at         DATETIME     NULL,
  payment_date    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id)    REFERENCES users(id)    ON DELETE CASCADE,
  INDEX idx_booking (booking_id),
  INDEX idx_user    (user_id),
  INDEX idx_status  (status),
  INDEX idx_gateway (gateway)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── FEEDBACK ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS feedback (
  id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id    INT UNSIGNED NOT NULL,
  booking_id INT UNSIGNED NULL,
  rating     TINYINT      NOT NULL DEFAULT 5 COMMENT '1-5',
  comment    TEXT         NULL,
  is_public  TINYINT(1)   NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id)    REFERENCES users(id)    ON DELETE CASCADE,
  FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE SET NULL,
  INDEX idx_user    (user_id),
  INDEX idx_booking (booking_id),
  INDEX idx_rating  (rating)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── SUBSCRIPTIONS (Newsletter) ───────────────────────────────
CREATE TABLE IF NOT EXISTS subscriptions (
  id           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  email        VARCHAR(180) NOT NULL UNIQUE,
  name         VARCHAR(120) NULL,
  is_active    TINYINT(1)   NOT NULL DEFAULT 1,
  subscribed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── CHATBOT MESSAGES ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS chatbot_messages (
  id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id    INT UNSIGNED NULL,
  session_id VARCHAR(64)  NOT NULL,
  role       ENUM('user','assistant') NOT NULL,
  message    TEXT         NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_session (session_id),
  INDEX idx_user    (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── CHATBOT FAQ (Admin-managed) ──────────────────────────────
CREATE TABLE IF NOT EXISTS chatbot_faq (
  id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  question   TEXT         NOT NULL,
  answer     TEXT         NOT NULL,
  keywords   VARCHAR(500) NULL COMMENT 'comma-separated trigger words',
  category   VARCHAR(60)  NULL,
  is_active  TINYINT(1)   NOT NULL DEFAULT 1,
  sort_order INT          NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── NOTIFICATIONS ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS notifications (
  id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id    INT UNSIGNED NOT NULL,
  title      VARCHAR(200) NOT NULL,
  message    TEXT         NOT NULL,
  type       ENUM('booking','payment','system','promo') NOT NULL DEFAULT 'system',
  is_read    TINYINT(1)   NOT NULL DEFAULT 0,
  link       VARCHAR(300) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user   (user_id),
  INDEX idx_unread (user_id, is_read)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── CONTACT MESSAGES ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS contact_messages (
  id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(120) NOT NULL,
  email      VARCHAR(180) NOT NULL,
  subject    VARCHAR(200) NOT NULL,
  message    TEXT         NOT NULL,
  is_read    TINYINT(1)   NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_read (is_read)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── SITE SETTINGS ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS site_settings (
  setting_key   VARCHAR(80)  NOT NULL PRIMARY KEY,
  setting_value TEXT         NULL,
  updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── API TOKENS (Mobile app) ──────────────────────────────────
CREATE TABLE IF NOT EXISTS api_tokens (
  id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id    INT UNSIGNED NOT NULL,
  token      VARCHAR(64)  NOT NULL UNIQUE,
  expires_at DATETIME     NOT NULL,
  last_used  DATETIME     NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_token (token),
  INDEX idx_user  (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── OTP CODES ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS otp_codes (
  id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  phone      VARCHAR(20)  NOT NULL,
  code       VARCHAR(10)  NOT NULL,
  purpose    VARCHAR(30)  NOT NULL DEFAULT 'login',
  expires_at DATETIME     NOT NULL,
  used       TINYINT(1)   NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_phone   (phone),
  INDEX idx_purpose (phone, purpose)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;

-- ════════════════════════════════════════════════════════════
-- SAMPLE DATA
-- ════════════════════════════════════════════════════════════

-- Transport types
INSERT INTO transport_types (type_name, icon, color) VALUES
('Bus',         'bus',   '#ff6a00'),
('Train',       'train', '#38bdf8'),
('Three-Wheel', 'car',   '#22c55e'),
('Taxi',        'car',   '#f59e0b');

-- Sample users (passwords are all "password" hashed with bcrypt)
INSERT INTO users (name, email, phone, password, role, status, email_verified) VALUES
('System Admin',   'admin@rideflow.lk',  '+94771234567', '$2y$12$X0xhaZAVue0.n/Ir81bMRO1ac6JcTSSqM5eZdcLST8NPxcmvIzLgu', 'admin',    'active', 1),
('John Perera',    'john@example.com',   '+94779876543', '$2y$12$X0xhaZAVue0.n/Ir81bMRO1ac6JcTSSqM5eZdcLST8NPxcmvIzLgu', 'customer', 'active', 1),
('Sara Fernando',  'sara@example.com',   '+94712345678', '$2y$12$X0xhaZAVue0.n/Ir81bMRO1ac6JcTSSqM5eZdcLST8NPxcmvIzLgu', 'customer', 'active', 1),
('Kamal Silva',    'driver@rideflow.lk', '+94761234567', '$2y$12$X0xhaZAVue0.n/Ir81bMRO1ac6JcTSSqM5eZdcLST8NPxcmvIzLgu', 'driver',   'active', 1);

-- Vehicles
INSERT INTO vehicles (type_id, vehicle_name, vehicle_number, capacity, amenities, status) VALUES
(1, 'Express Coach A1', 'NC-1234', 45, '["AC","WiFi","USB"]', 'active'),
(1, 'Night Rider B2',   'NC-5678', 50, '["AC","USB"]',        'active'),
(2, 'Intercity Express','TR-2024', 300,'["AC","Restaurant","WiFi"]','active'),
(2, 'Rajarata Rail',    'TR-2025', 280,'["AC"]',               'active'),
(3, 'City Tuk-Tuk 1',  'WP-T001', 3,  '[]',                  'active'),
(4, 'Comfort Cab',      'WP-C001', 4,  '["AC","Water"]',      'active');

-- Routes
INSERT INTO routes (type_id, route_name, origin, destination, distance_km, estimated_duration, status) VALUES
(1,'Colombo–Kandy Express',     'Colombo',    'Kandy',       120.00,'3h 30m','active'),
(1,'Colombo–Galle Coastal',     'Colombo',    'Galle',       119.00,'2h 45m','active'),
(1,'Kandy–Jaffna Overnight',    'Kandy',      'Jaffna',      310.00,'8h 00m','active'),
(2,'Colombo–Badulla Hill Line', 'Colombo Fort','Badulla',    292.00,'9h 00m','active'),
(2,'Colombo–Kandy Intercity',   'Colombo Fort','Kandy',      120.00,'2h 30m','active'),
(3,'Colombo City Rides',        'Colombo',    'Any City Point',5.00,'15m',   'active'),
(4,'Colombo Airport Taxi',      'Colombo',    'BIA Airport',  35.00,'45m',  'active');

-- Route stops
INSERT INTO route_stops (route_id, stop_name, stop_order) VALUES
(1,'Colombo Bastian Mawatha',1),(1,'Kadawatha',2),(1,'Nittambuwa',3),(1,'Kegalle',4),(1,'Kandy',5),
(2,'Colombo Bastian Mawatha',1),(2,'Panadura',2),(2,'Kalutara',3),(2,'Hikkaduwa',4),(2,'Galle',5),
(5,'Colombo Fort',1),(5,'Kelaniya',2),(5,'Kandy',3);

-- Schedules (mix of today/future)
INSERT INTO schedules (route_id, vehicle_id, departure_date, departure_time, arrival_time, fare, available_seats, status) VALUES
(1,1,CURDATE(),'06:00:00','09:30:00', 450.00, 35,'scheduled'),
(1,1,CURDATE(),'10:00:00','13:30:00', 450.00, 20,'scheduled'),
(1,2,DATE_ADD(CURDATE(),INTERVAL 1 DAY),'07:00:00','10:30:00',500.00,45,'scheduled'),
(2,1,CURDATE(),'07:30:00','10:15:00', 380.00, 28,'scheduled'),
(2,2,DATE_ADD(CURDATE(),INTERVAL 1 DAY),'08:00:00','10:45:00',400.00,50,'scheduled'),
(4,3,CURDATE(),'05:30:00','14:30:00',1200.00,280,'scheduled'),
(5,3,CURDATE(),'07:00:00','09:30:00', 350.00,280,'scheduled'),
(5,4,CURDATE(),'12:00:00','14:30:00', 350.00,250,'scheduled');

-- Sample bookings
INSERT INTO bookings (user_id, schedule_id, booking_ref, seats_booked, total_fare, passenger_name, passenger_phone, passenger_email, booking_status, payment_status, booked_at) VALUES
(2,1,'RF-240001',2, 900.00,'John Perera',   '+94779876543','john@example.com','confirmed','paid',   DATE_SUB(NOW(),INTERVAL 3 DAY)),
(3,4,'RF-240002',1, 380.00,'Sara Fernando', '+94712345678','sara@example.com','confirmed','paid',   DATE_SUB(NOW(),INTERVAL 2 DAY)),
(2,6,'RF-240003',3,1050.00,'John Perera',   '+94779876543','john@example.com','confirmed','unpaid', DATE_SUB(NOW(),INTERVAL 1 DAY)),
(3,7,'RF-240004',1, 350.00,'Sara Fernando', '+94712345678','sara@example.com','pending',  'unpaid', NOW());

-- Sample payments
INSERT INTO payments (booking_id, user_id, gateway, amount, currency, status, transaction_ref, paid_at) VALUES
(1,2,'stripe',    900.00,'LKR','completed','TXN-STR-001',DATE_SUB(NOW(),INTERVAL 3 DAY)),
(2,3,'ezCash',    380.00,'LKR','completed','TXN-EZC-001',DATE_SUB(NOW(),INTERVAL 2 DAY));

-- Feedback
INSERT INTO feedback (user_id, booking_id, rating, comment) VALUES
(2,1,5,'Excellent service! Very comfortable and on time.'),
(3,2,4,'Good journey but bus was 10 mins late.');

-- Drivers
INSERT INTO drivers (user_id, vehicle_id, license_no, experience, rating, status) VALUES
(4,1,'B1234567',8,4.8,'active');

-- Chatbot FAQ
INSERT INTO chatbot_faq (question, answer, keywords, category, sort_order) VALUES
('How do I book a ticket?','Visit the Search page, enter your origin, destination and date, choose a trip, select seats and proceed to payment. You will receive an email confirmation.','book,booking,ticket,reserve','booking',1),
('What payment methods are accepted?','We accept Credit/Debit Cards (Stripe), PayPal, Dialog eZ Cash, Genie, Bank Transfer and Cash on Board.','payment,pay,card,ezCash,genie,PayPal','payment',2),
('Can I cancel my booking?','Yes, you can cancel from My Bookings within 2 hours of booking. Cancellations made after departure time are non-refundable.','cancel,refund,cancellation','booking',3),
('How do I get my ticket?','After payment your e-ticket is emailed to you. You can also download it from My Bookings. Show the QR code to the conductor.','ticket,download,print,qr','booking',4),
('What routes are available?','We serve Colombo–Kandy, Colombo–Galle, Kandy–Jaffna, Colombo–Badulla (train) and many city routes. Use the Search page for live availability.','route,routes,available,city','routes',5),
('How early should I arrive?','Please arrive 15 minutes before departure for buses, 30 minutes for trains.','arrive,time,departure','travel',6),
('Is Wi-Fi available on board?','AC Express coaches and intercity trains offer Wi-Fi. Check the amenities icon on the schedule listing.','wifi,internet,amenities','travel',7),
('How do I contact support?','Call +94 11 234 5678 (9am–9pm) or email support@rideflow.lk or use the Contact page.','contact,support,help,phone','support',8);

-- Subscriptions
INSERT INTO subscriptions (email, name) VALUES
('john@example.com','John Perera'),
('sara@example.com','Sara Fernando');

-- Site settings
INSERT INTO site_settings (setting_key, setting_value) VALUES
('site_name',          'RideFlow'),
('site_tagline',       'Sri Lanka Transport Booking'),
('site_email',         'info@rideflow.lk'),
('site_phone',         '+94 11 234 5678'),
('site_address',       'No.42, Galle Road, Colombo 03'),
('google_client_id',   ''),
('google_client_secret',''),
('anthropic_api_key',  ''),
('ai_enabled',         '1'),
('smtp_host',          'smtp.gmail.com'),
('smtp_port',          '587'),
('smtp_user',          ''),
('smtp_pass',          ''),
('smtp_from',          'noreply@rideflow.lk'),
('smtp_from_name',     'RideFlow'),
('stripe_pk',          ''),
('stripe_sk',          ''),
('paypal_client_id',   ''),
('sms_provider',       'demo'),
('maintenance_mode',   '0');
