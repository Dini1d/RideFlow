# RideFlow Final Project Structure

This is the clean final output structure for the project, separated clearly for Admin and User sections.

## 1. Root Project

```text
rideflow/
├── admin/
│   ├── dashboard.php
│   ├── bookings.php
│   ├── users.php
│   ├── drivers.php
│   ├── vehicles.php
│   ├── routes.php
│   ├── schedules.php
│   ├── payments.php
│   ├── reports.php
│   ├── feedback.php
│   ├── messages.php
│   ├── chatbot.php
│   ├── newsletter.php
│   ├── integrations.php
│   ├── settings.php
│   ├── subscriptions.php
│   ├── admin_sidebar.php
│   ├── admin_topbar.php
│   └── google_setup.php
│
├── user/
│   ├── dashboard.php
│   ├── bookings.php
│   ├── profile.php
│   ├── notifications.php
│   └── ticket.php
│
├── driver/
│   └── dashboard.php
│
├── assets/
│   ├── css/
│   │   └── style.css
│   ├── js/
│   │   └── app.js
│   └── images/
│       └── avatars/
│       └── verification/
│
├── api/
│   ├── newsletter.php
│   ├── notifications.php
│   └── v1/
│       └── index.php
│
├── auth/
│   ├── google_callback.php
│   ├── google_login.php
│   └── google_process.php
│
├── chatbot/
│   └── chat.php
│
├── config/
│   ├── config.php
│   └── database.php
│
├── includes/
│   ├── auth.php
│   ├── footer.php
│   ├── header.php
│   └── helpers.php
│
├── mail/
│   └── mailer.php
│
├── payment/
│   └── checkout.php
│
├── sql/
│   └── rideflow.sql
│
├── vendor/
│   └── ...
│
├── .htaccess
├── book.php
├── contact.php
├── forgot_password.php
├── index.php
├── login.php
├── logout.php
├── otp_verify.php
├── register.php
├── reset_password.php
├── robots.txt
├── search.php
├── verify_email.php
├── README.md
├── SETUP_GUIDE.md
├── composer.json
├── composer.lock
└── temp_bcrypt_test.php
```

## 2. Admin Folder

Admin pages are grouped separately for secure management operations.

**Primary admin files:**
- dashboard.php
- bookings.php
- users.php
- drivers.php
- vehicles.php
- routes.php
- schedules.php
- payments.php
- reports.php
- feedback.php
- messages.php
- chatbot.php
- newsletter.php
- settings.php
- subscriptions.php
- integrations.php
- google_setup.php

**Admin shared UI files:**
- admin_sidebar.php
- admin_topbar.php

## 3. User Folder

User pages are grouped separately for customer operations.

**User pages:**
- dashboard.php
- bookings.php
- profile.php
- notifications.php
- ticket.php

## 4. Important Notes

- Admin and user-specific files are already separated into their own folders.
- Shared app assets and config stay in the main root folders for common access.
- Backend API and auth files remain separate for better code organization.
- Database and mail handlers are centralized in their own sections.

## 5. Recommended Clean Structure for Future Development

For long-term maintainability, use this structure:

```text
rideflow/
├── app/
│   ├── admin/
│   ├── user/
│   ├── driver/
│   ├── config/
│   ├── includes/
│   └── services/
├── public/
│   ├── assets/
│   ├── css/
│   ├── js/
│   └── images/
├── api/
├── sql/
├── vendor/
├── README.md
├── composer.json
└── .htaccess
```

This is the cleaner production-ready version of the same project.
