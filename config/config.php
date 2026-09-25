<?php
/**
 * RideFlow — Main Configuration
 * Edit this file with your server settings before deploying.
 */

/* ── Database ─────────────────────────────────── */
define('DB_DRIVER', getenv('RIDEFLOW_DB_DRIVER') ?: 'mysql'); // 'mysql' | 'pgsql'
define('DB_HOST', 'localhost');
define('DB_NAME', 'rideflow');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_CHAR', 'utf8mb4');
define('DB_PORT', getenv('RIDEFLOW_DB_PORT') ?: '');
define('DB_DSN', getenv('RIDEFLOW_DB_DSN') ?: '');
define('SUPABASE_DB_URL', getenv('SUPABASE_DB_URL') ?: '');

/* ── Application ──────────────────────────────── */
define('SITE_URL',  'http://localhost/rideflow');  // NO trailing slash
define('SITE_NAME', 'RideFlow');
define('APP_ENV',   'development');   // 'development' | 'production'
define('TIMEZONE',  'Asia/Colombo');

/* ── Session ──────────────────────────────────── */
define('SESSION_NAME',     'RF_SESSION');
define('SESSION_LIFETIME', 7200);  // 2 hours

/* ── Google OAuth ─────────────────────────────── */
define('GOOGLE_CLIENT_ID',     '');  // your-id.apps.googleusercontent.com
define('GOOGLE_CLIENT_SECRET', '');  // GOCSPX-...
define('GOOGLE_REDIRECT',      SITE_URL.'/auth/google_callback.php');

/* ── Email (PHPMailer/SMTP) ───────────────────── */
define('MAIL_HOST',      'smtp.gmail.com');
define('MAIL_PORT',      587);
define('MAIL_USER',      '');   // your Gmail or SMTP user
define('MAIL_PASS',      '');   // App password
define('MAIL_FROM',      'noreply@rideflow.lk');
define('MAIL_FROM_NAME', 'RideFlow');
define('MAIL_ENABLED',   false);  // set true when SMTP is configured

/* ── Stripe ───────────────────────────────────── */
define('STRIPE_PK', '');  // pk_test_...
define('STRIPE_SK', '');  // sk_test_...

/* ── AI Chatbot (Anthropic Claude) ───────────── */
define('ANTHROPIC_API_KEY', '');   // sk-ant-...

/* ── SMS ──────────────────────────────────────── */
define('SMS_PROVIDER', 'demo');  // 'demo' | 'twilio' | 'esms' | 'dialog'
define('TWILIO_SID',   '');
define('TWILIO_TOKEN', '');
define('TWILIO_FROM',  '');
define('ESMS_API_KEY', '');

/* ── Security ─────────────────────────────────── */
define('BCRYPT_COST', 12);
define('CSRF_TOKEN_LEN', 32);
define('OTP_EXPIRY_MIN', 10);

/* ── Pagination ───────────────────────────────── */
define('PER_PAGE', 20);

/* ── Bootstrap app ───────────────────────────── */
date_default_timezone_set(TIMEZONE);
error_reporting(APP_ENV === 'development' ? E_ALL : 0);
ini_set('display_errors', APP_ENV === 'development' ? 1 : 0);
