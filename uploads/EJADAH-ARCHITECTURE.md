# Ejadah App Architecture Handbook

> A read-only audit of the Ejadah codebase for AI agents and developers.
> Base script: **Academy LMS** by Creativeitem (CodeCanyon), customized with Ejadah-specific features.
> Last audited: 2026-08-06.

---

## 1. Tech Stack & Environment

| Layer         | Technology                                   | Notes |
|---------------|----------------------------------------------|-------|
| Language      | PHP 7.x / 8.x                                | Confirmed via `install.sql` header (PHP 8.2.14). |
| Framework     | CodeIgniter 3 (CI3)                         | MVC pattern; `/system` holds the CI3 core. |
| Database       | MySQL 8.0+ (InnoDB) — **NOT MariaDB**       | User-mandated. See `application/config/database.php` → `tafawoq_db_1`. Uses `utf8mb4` for emoji support. |
| Query Layer   | CI3 Query Builder (`$this->db->...`)         | Active Record style; **no raw PDO**. |
| Frontend       | HTML5 + Bootstrap + jQuery + Vanilla JS    | No React, No Vue, No Node.js. |
| Mobile App    | Flutter (Dart)                               | Talks to CI3 REST API (`Api.php`, `Api_instructor.php`) over HTTPS + JWT. |
| Video Infra    | Bunny CDN Stream, Vimeo, YouTube, AWS S3, Wasabi, Google Drive, HTML5 MP4, System iFrame | Provider selected per-lesson via `lesson.video_type`. |
| Auth (Web)     | CI3 Session Library                         | DB-backed `ci_sessions` table. |
| Auth (Mobile)  | JWT (`application/libraries/TokenHandler.php`, `Jwt_model.php`) | Bearer token in `auth_token` param. |
| i18n          | Custom `get_phrase()` / `get_phrase_()`      | `application/helpers/multi_language_helper.php`; `language` table + JSON packs in `/languages/`. |
| Package Mgmt  | Composer (optional)                         | `composer.json` present; `vendor/` for PHP deps. |

### Runtime Environment

- **Local dev:** XAMPP (`/Applications/XAMPP/xamppfiles/htdocs/Ejadah`).
- **DB connection:** `localhost` / `root` / `''` / `tafawoq_db_1` (see `database.php`). mysqli driver, utf8 charset.
- **Entry point:** `index.php` (repo root) → front-controller → routes to `home` controller by default.
- **REST base class:** `application/libraries/REST_Controller.php` (extends `CI_Controller`) — parent of all mobile API controllers.

---

## 2. Global Directory Structure

```
Ejadah/
├── index.php                     # CI3 front-controller (sets APPPATH, ENVIRONMENT)
├── composer.json                 # PHP deps (PHPUnit, Doctrine, etc.)
├── EJADAH-ARCHITECTURE.md        # THIS FILE
├── EJADAH_BRAND_GUIDE.md         # Brand & design system reference
│
├── application/                  # ★ All bespoke PHP lives here (CI3 APPPATH)
│   ├── config/                  # routes.php, config.php, database.php, autoload.php
│   ├── controllers/             # HTTP entry points (Home, Login, User, Admin, Api, Api_instructor, Payment…)
│   │   └── admin/               # Admin sub-namespace controllers
│   ├── core/                    # MY_Controller / MY_Loader extensions
│   ├── helpers/                 # multi_language_helper.php, common_helper.php (get_lesson_type, get_video_url…)
│   ├── hooks/                   # CI3 hooks
│   ├── language/                # CI3 system lang files
│   ├── libraries/               # Stripe/, Razorpay, TokenHandler (JWT), REST_Controller, phpqrcode, Academy_cloud…
│   ├── migrations/              # DB migrations (currently empty on disk)
│   ├── models/                  # Crud_model, User_model, Email_model, Payment_model, Api_model, Video_model, Jwt_model…
│   ├── third_party/             # External libs
│   ├── views/                   # PHP view partials (frontend/ + backend/ + lessons/ + email/)
│   │   ├── backend/             # Admin dashboard shell + partials (role-routed)
│   │   ├── frontend/default-new/# Public site theme (the active theme)
│   │   ├── lessons/             # Lesson player partials (general_course_content_body.php, vimeo_player_config.php…)
│   │   └── email/               # Email templates
│   └── logs/                    # CI3 log files
│
├── assets/                       # Static resources (CSS, JS, images)
│   ├── frontend/default-new/    # Theme-specific frontend assets
│   ├── backend/                 # Admin panel assets (css, js, fonts, images)
│   ├── global/                  # Shared assets
│   ├── lessons/                 # Lesson-specific files
│   ├── payment/                 # Payment gateway assets
│   └── playing-page/           # Video player assets (css, js, img, scss)
│
├── system/                       # CodeIgniter 3 framework core (DO NOT MODIFY)
│
├── uploads/                      # User-uploaded content + install schema
│   ├── install.sql              # ★ Full DB schema dump (reference schema)
│   ├── system/                 # Logo, favicon, system images
│   ├── lesson_files/           # Lesson attachments
│   ├── thumbnails/             # Course thumbnails
│   ├── captions/               # Video caption (VTT/SRT) files for players
│   ├── portfolio_certificates/ # Student portfolio certs
│   └── user_image/             # Profile pictures
│
├── themes/                       # (Empty — themes managed via DB settings)
│
├── languages/                    # JSON i18n packs (arabic, english, french…)
│
├── update/                       # Ejadah update packs & feature docs
│   └── update_6.x/              # Versioned update packs
│
├── update_pack/                  # Historical update bundles (v6.0 → v6.13)
│
└── specs/                        # Spec Kit planning docs
    └── 002-public-student-portfolio/
```

### Purpose of key `application/` subfolders

| Folder | Purpose |
| -------- | --------- |
| `controllers/` | HTTP request entry points. Each public method maps to a URL. Contains core (`Home`, `Login`, `User`, `Admin`, `Payment`) and mobile API (`Api`, `Api_instructor`) controllers. |
| `models/` | Data-access layer. Extends `CI_Model`. Uses Query Builder (`$this->db->get()`, `get_where()`, `insert()`, `update()`, `delete()`). |
| `views/` | PHP templates rendered via `$this->load->view()`. Split into `frontend/default-new/` (public site), `backend/` (admin panel), `lessons/` (lesson player), and `email/` (templates). |
| `libraries/` | Reusable PHP classes. Holds payment SDKs (Stripe, Razorpay), JWT (`TokenHandler`), REST base (`REST_Controller`), `Academy_cloud_model` integration, phpqrcode. |
| `helpers/` | Procedural function libraries. `multi_language_helper.php` provides `get_phrase()`; `common_helper.php` provides `get_lesson_type()`, `get_video_url()`, `get_settings()`, `get_user_role()`. |
| `config/` | Routing (`routes.php`), DB (`database.php`), autoload (`autoload.php`), constants. |

---

## 3. Users, Authentication & RBAC

### Role Model

All users live in the `users` table. Two concepts encode authorization:

- **`role_id` (INT):** `1` = Admin, `2` = Student/User. Stored on the row and mirrored into session.
- **`is_instructor` (0/1):** A separate flag, NOT a role. A user with `role_id=2` and `is_instructor=1` can author courses. Instructor approval flow gates this flag via `instructor_approval()`.

### Authentication Mechanisms

| Surface | Mechanism | Storage |
| --------- | ---------- | -------- |
| Web (browser) | CI3 Session Library | `ci_sessions` table (DB driver). Session keys set by `User_model::set_login_userdata()`. |
| Mobile (Flutter) | JWT Bearer token | `application/libraries/TokenHandler.php` encodes/decodes; `Jwt_model::token_data_get()` wraps it. Token passed as `auth_token` GET/POST param. |

### Web Login Flow (`Login::validate_login` → `User_model::set_login_userdata`)

```php
// Login.php
$credential = array('email' => $email, 'password' => sha1($password), 'status' => 1);
$query = $this->db->get_where('users', $credential);
if ($query->num_rows() > 0) {
    $this->user_model->set_login_userdata($row->id);
}

// User_model::set_login_userdata
$this->session->set_userdata('user_id',   $row->id);
$this->session->set_userdata('role_id',   $row->role_id);
$this->session->set_userdata('role',      get_user_role('user_role', $row->id));
$this->session->set_userdata('name',      $row->first_name.' '.$row->last_name);
$this->session->set_userdata('is_instructor', $row->is_instructor);
$this->session->set_userdata('custom_session_limit', time() + 864000); // 10 days

if ($row->role_id == 1) {
    $this->session->set_userdata('admin_login', '1');
    redirect(site_url('admin/dashboard'));
} elseif ($row->role_id == 2) {
    $this->session->set_userdata('user_login', '1');
    redirect(site_url('home/my_courses'));
}
```

### Session Keys Cheat Sheet

| Session key                  | Type    | Set when | Used to verify |
|------------------------------|---------|----------|----------------|
| `user_id`                    | int     | On login | Identity of the logged-in user (both roles) |
| `role_id`                    | int     | On login | `1` = Admin, `2` = User/Student |
| `role`                       | string  | On login | Lowercase role name (used for view routing in backend) |
| `admin_login`                | '1'     | role_id=1 | Admin area access (`Admin` constructor checks this) |
| `user_login`                 | '1'     | role_id=2 | Student area access (`User` constructor checks this) |
| `is_instructor`              | int (0/1)| On login + `instructor_approval()` | Instructor-only routes in `User` controller |
| `name`                       | string  | On login | Display name in views |
| `custom_session_limit`       | int (timestamp) | On login | Session expiry (10 days) |
| `language`                   | string  | On language switch | Active UI language code |
| `theme_mode`                 | string  | Setting | `dark` / `light` body class |
| `cart_items`                 | array   | Shopping | Cart contents |
| `url_history`                | string  | Redirect guard | Pre-login URL to return to |
| `flash_message` / `error_message` | string | Flashdata | One-time UI notices |

### Role Gating (constructor middleware)

```php
// Admin.php constructor
$this->user_model->check_session_data('admin');   // redirects to /login if admin_login != true

// User.php constructor
$this->user_model->check_session_data('user');    // redirects to /login if user_login != true
$this->instructor_authorization($this->router->method); // blocks non-instructors from instructor routes
$this->instructor_approval();                      // refreshes is_instructor session flag
```

`User_model::check_session_data()` also calls `remove_garbage_collection()` to prune stale sessions before validating.

### Multi-Device Login Tracking

`User_model::new_device_login_tracker($user_id, $is_verified)` (mirrored in `Api_model::new_device_login_tracker` for the mobile API) enforces the `allowed_device_number_of_loging` setting:

- Maintains a JSON array of active `ci_sessions.id` values on `users.sessions`.
- On a new device, if the count exceeds the limit, the oldest session row is deleted from `ci_sessions` and the new one is appended.
- If verification is required, an email alert (`email_model->new_device_login_alert`) is sent and the user is redirected to `login/new_login_confirmation` with a code.
- Admins (`role_id=1`) bypass device tracking entirely.

### Logout

`User_model::session_destroy()` unsets `user_id`, `admin_login`, `user_login`, `role_id`, `role`, `name`, etc., and destroys the session.

### Instructor Application Flow

- `User_model::post_instructor_application()` stores an application row.
- Admins approve via `update_status_of_application()` → sets `is_instructor=1` on the user.
- `assign_permission()` grants the instructor permission JSON used by the backend shell.

---

## 4. Video Streaming & Player Integration

### Supported Lesson Video Providers

The `lesson.video_type` column selects the provider. `common_helper::get_lesson_type($lesson_id)` maps the stored value to a player-case string consumed by `application/views/lessons/general_course_content_body.php`.

| `lesson.video_type` | `get_lesson_type()` returns | Player strategy |
| --------------------- | ---------------------------- | ----------------- |
| `YouTube` / `youtube` | `youtube_video_url` | Plyr-wrapped YouTube iframe embed. |
| `google_drive` | `google_drive_video_url` | HTML5 `<video>` pulling from Drive API (`googleapis.com/drive/v3/files/{id}?alt=media`). |
| `Vimeo` / `vimeo` | `vimeo_video_url` | Vimeo Player SDK directly (no Plyr wrapper) — avoids iframe gesture context loss on mobile. See `vimeo_player_config.php`. |
| `bunny_stream` | `bunny_stream_video_url` | **Ejadah custom.** HTML5 `<video>` + hls.js loading a Bunny CDN signed HLS playlist. |
| `amazon` | `amazon_video_url` | HTML5 `<video>` with S3 URL. |
| `academy_cloud` | `academy_cloud` | HTML5 `<video>` with `Academy_cloud_model` URL. |
| `html5` | `html5_video_url` | HTML5 `<video>` with direct MP4 URL. |
| `system` | `video_file` | Uploaded file served via `Files` controller (token-gated). |
| (wasabi) | `wasabi_video_url` | Wasabi S3-compatible storage URL. |
| (other lesson_type=quiz/text/etc.) | `quiz`, `text`, `*_file`, `iframe` | Non-video fallbacks. |

### Bunny CDN Stream Integration (Ejadah Custom)

Bunny CDN Stream is the flagship video provider. Configuration is stored in the `settings` table:

| Settings key | Purpose |
| -------------- | --------- |
| `ejadah_bunny_api_key` | Bunny Stream API key (account-level). |
| `ejadah_bunny_library_id` | Target Bunny Stream library ID. |
| `ejadah_bunny_pull_zone` | Pull zone hostname (e.g. `bunny-cdn-host.b-cdn.net`). |
| `ejadah_bunny_token_security_key` | Advanced Directory Token V2 security key for URL signing. |

These are persisted via `Crud_model` (lines ~418–431 save the four keys from admin settings POST).

**Signing URLs** — `Api_model::generate_bunny_secure_url($video_id)` produces a time-limited (24h) signed HLS URL:

```php
$pull_zone    = get_settings('ejadah_bunny_pull_zone');
$security_key = get_settings('ejadah_bunny_token_security_key');
$expires      = time() + 86400;                  // 24 hours
$token_path   = '/' . $video_id . '/';

// Bunny CDN Advanced Directory Token V2 Hashable String
$hashableBase = $security_key . $token_path . $expires . "token_path=" . $token_path;
$token = hash('sha256', $hashableBase, true);
$token = strtr(base64_encode($token), '+/', '-_');
$token = str_replace('=', '', $token);

return "https://" . $pull_zone . $token_path . "playlist.m3u8"
     . "?bcdn_token=" . $token
     . "&expires=" . $expires
     . "&token_path=" . urlencode($token_path);
```

**Persistence on lesson rows** — `Crud_model` (lesson save/update, lines ~1563–1576 and ~1982–1996) stores:

- `lesson.ejadah_bunny_video_id` — the Bunny video GUID.
- `lesson.ejadah_bunny_library_id` — copied from `get_settings('ejadah_bunny_library_id')`.
- `lesson.video_type` = `'bunny_stream'`.
- `lesson.duration` — parsed from the admin-posted `bunny_video_duration` (HH:MM:SS → seconds).

**Player rendering** — `application/views/lessons/general_course_content_body.php` (lines 80–104):

```php
<?php elseif ($get_lesson_type == 'bunny_stream_video_url'): ?>
    <?php $secure_url = $this->api_model->generate_bunny_secure_url($lesson_details['ejadah_bunny_video_id']); ?>
    <video poster="<?php echo $lesson_thumbnail_url; ?>" id="player" playsinline controls>
        <?php if ($lesson_details['caption'] != "" && file_exists('uploads/captions/' . $lesson_details['caption'])): ?>
            <track kind="captions" label="Caption"
                src="<?php echo base_url('uploads/captions/' . $lesson_details['caption']); ?>" srclang="en" default />
        <?php endif; ?>
    </video>
    <script src="https://cdn.jsdelivr.net/npm/hls.js@1.4.12/dist/hls.min.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', () => {
            const video = document.getElementById('player');
            const source = "<?php echo $secure_url; ?>";
            if (Hls.isSupported()) {
                const hls = new Hls();
                hls.loadSource(source);
                hls.attachMedia(video);
            } else if (video.canPlayType('application/vnd.apple.mpegurl')) {
                video.src = source;   // Safari native HLS
            }
        });
    </script>
```

Key points:

- Uses **hls.js v1.4.12** from jsDelivr CDN for cross-browser HLS playback.
- Safari falls back to native HLS via `canPlayType('application/vnd.apple.mpegurl')`.
- Caption `<track>` is supported from `uploads/captions/`.
- The signed URL expires every 24h, so the page must be re-rendered to refresh it.

### Vimeo Player (Conditional)

Vimeo uses the Vimeo Player SDK directly (not Plyr) to avoid iframe gesture context loss that caused muted-audio bugs on mobile. Config lives in `application/views/lessons/vimeo_player_config.php`. See `VIMEO_AUDIO_FIX_DOCUMENTATION.md` and `VIMEO_PLAYER_BACKUP_REFERENCE.md` for the history.

### YouTube / Google Drive / S3 / Wasabi / Academy Cloud

All render through HTML5 `<video>` or iframe blocks in `general_course_content_body.php`. The `get_lesson_type()` chain in `common_helper.php` is the single router — add new providers as an `elseif` branch there and a matching case in the view.

### Video Provider APIs (`Video_model`)

`application/models/Video_model.php` wraps third-party metadata APIs:

- `get_youtube_video_id($url)` / `get_vimeo_video_id($url)` — regex extraction.
- `get_youtube_video_information($video_id)` — calls YouTube Data API with `youtube_api_key` setting.
- `getVideoDetails($url)` — routes by host: Vimeo → `api.vimeo.com` (Bearer `vimeo_api_key`); YouTube → Data API.

### Player Assets

| Asset | Location |
| ------- | ---------- |
| Plyr config | `application/views/lessons/plyr_config.php` |
| Vimeo config | `application/views/lessons/vimeo_player_config.php` |
| Playing page JS | `assets/playing-page/js/script.js` (Bootstrap bundle, jQuery) |
| Captions | `uploads/captions/` |
| Lesson thumbnails | `uploads/thumbnails/` via `Crud_model::get_lesson_thumbnail_url()` |

---

## 5. Mobile App API Architecture (Flutter)

The Flutter student and instructor apps talk to two CI3 REST controllers that extend `application/libraries/REST_Controller.php`.

### Auth: JWT via `TokenHandler`

| File | Role |
|------|------|
| `application/libraries/TokenHandler.php` | Encodes/decodes JWT. |
| `application/models/Jwt_model.php` | Thin wrapper: `token_data_get($auth_token)` → `$this->tokenHandler->DecodeToken()`, returns JSON, 401 on exception. |

All protected endpoints expect an `auth_token` GET/POST param. Controllers decode it to resolve the `user_id` before delegating to the model.

### Student API — `application/controllers/Api.php` (extends `REST_Controller`)

Constructor loads `db`, `session`, `TokenHandler`. Sets `Content-Type: application/json`. Delegates business logic to `Api_model`.

| Method | Endpoint (segment-style) | Purpose |
| -------- | -------------------------- | --------- |
| `web_redirect_to_buy_course_get` | `api/web_redirect_to_buy_course/{auth_token}/{course_id}/{app_url}` | Decodes JWT, sets web session, redirects to payment page. |
| `top_courses_get` | `api/top_courses/{top_course_id?}` | Featured courses. |
| `app_logo_get` | `api/app_logo` | App logo payload. |
| `all_categories_get` / `categories_get` / `sub_categories_get` | `api/all_categories`, `api/categories/{id}`, `api/sub_categories/{parent}` | Category tree. |
| `category_wise_course_get` | `api/category_wise_course` | Courses by category. |
| `languages_get` | `api/languages` | Supported languages. |
| `filter_course_get` | `api/filter_course` | Filtered course list. |
| `courses_by_search_string_get` | `api/courses_by_search_string` | Search. |
| `system_settings_get` | `api/system_settings` | Site settings payload. |
| `login_get` | `api/login` | Credentials login (delegates to `Api_model::login_get`). |
| `new_login_confirmation_post` | `api/new_login_confirmation/{param1}` | Device verification code confirmation. |
| `signup_post` | `api/signup` | New user registration. |
| `verify_email_address_post` / `resend_verification_code_post` | `api/verify_email_address`, `api/resend_verification_code` | Email verification flow. |
| `course_object_by_id_get` | `api/course_object_by_id` | Single course object. |
| `my_courses_get` | `api/my_courses` | Enrolled courses for the JWT user. |
| `my_wishlist_get` | `api/my_wishlist` | Wishlist. |
| `sections_get` | `api/sections/{course_id}` | Course sections. |
| `section_wise_lessons_get` | `api/section_wise_lessons` | Lessons in a section (injects signed Bunny URL). |
| `toggle_wishlist_items_get` | `api/toggle_wishlist_items` | Toggle wishlist. |
| `lesson_details_get` | `api/lesson_details` | Lesson detail (injects signed Bunny URL). |
| `course_details_by_id_get` | `api/course_details_by_id` | Full course detail. |
| `submit_quiz_post` | `api/submit_quiz` | Quiz submission. |
| `save_course_progress_get` | `api/save_course_progress` | Persist lesson progress. |
| `upload_user_image_post` / `update_userdata_post` / `update_password_post` | `api/upload_user_image`, `api/update_userdata`, `api/update_password` | Profile management. |
| `userdata_get` | `api/userdata` | Current user payload. |
| `certificate_addon_get` | `api/certificate_addon` | Certificate addon data. |
| `token_data_get` | `api/token_data/{auth_token}` | Decode JWT (validation endpoint). |
| `enroll_free_course_get` | `api/enroll_free_course` | Enroll in a free course. |
| `forgot_password_post` | `api/forgot_password` | Password reset. |
| `bundles_get` / `bundle_courses_get` / `my_bundles_get` / `my_bundle_course_details_get` | `api/bundles`, `api/bundle_courses/{id}`, `api/my_bundles`, `api/my_bundle_course_details` | Course bundles. |
| `web_redirect_to_buy_bundle_get` | `api/web_redirect_to_buy_bundle/{auth_token}/{bundle_id}/{app_url}` | JWT → session redirect for bundle purchase. |
| `forum_add_questions_post` / `forum_questions_get` / `search_forum_questions_get` / `add_questions_reply_post` / `forum_child_questions_get` / `forum_question_vote_get` / `forum_question_delete_get` | `api/forum_*` | Course forum Q&A. |
| `update_watch_history_post` | `api/update_watch_history` | Watch history. |
| `quiz_mobile_web_view_get` / `zoom_mobile_web_view_get` / `lesson_mobile_web_view_get` | `api/quiz_mobile_web_view`, `api/zoom_mobile_web_view`, `api/lesson_mobile_web_view` | WebView bridges for complex lesson types. |

### Instructor API — `application/controllers/Api_instructor.php` (extends `REST_Controller`)

Constructor loads `api_instructor_model`, `TokenHandler`. All endpoints gated by `auth_token`.

| Method | Purpose |
| -------- | --------- |
| `token_data_get` | Decode JWT (401 on failure). |
| `login_post` | Instructor credentials login → issues token on `validity==1`. |
| `change_password_post` / `forgot_password_post` | Password management. |
| `change_profile_photo_post` | Upload profile photo. |
| `userdata_get` | Instructor profile data. |
| `update_userdata_post` | Update profile fields. |
| `courses_get` | Instructor's courses list. |
| `add_course_form_get` / `add_course_post` | Create course. |
| `edit_course_form_get` / `update_course_post` | Edit course. |
| `update_course_status_get` | Toggle course status. |
| `edit_course_requirements_get` / `update_course_requirements_post` | Requirements CRUD. |
| `edit_course_outcomes_get` / `update_course_outcomes_post` | Outcomes CRUD. |
| `delete_course_get` | Delete course. |
| `section_and_lesson_get` / `sections_get` | Section/lesson tree. |
| `add_section_post` / `update_section_post` / `delete_section_post` | Section CRUD. |
| `add_lesson_post` / `lesson_all_data_get` / `update_lesson_post` / `delete_lesson_get` | Lesson CRUD. |
| `sort_post` | Reorder sections/lessons. |
| `course_pricing_form_get` / `update_course_price_post` | Pricing. |
| `sales_report_get` / `details_of_sales_report_get` / `payout_report_get` | Sales/payout reports. |
| `add_withdrawal_request_post` / `delete_withdrawal_request_get` | Withdrawal requests. |
| `live_class_get` / `save_live_class_data_post` | Live class (Zoom) management. |

### Mobile Login & Device Verification (`Api_model`)

`Api_model::login_get()` mirrors the web flow for mobile:

```php
$credential = array('email' => $_GET['email'], 'password' => sha1($_GET['password']), 'status' => 1);
$query = $this->db->get_where('users', $credential);
if ($query->num_rows() > 0) {
    $row = $this->new_device_login_tracker($row['id']);   // enforces allowed_device_number_of_loging
    $userdata['user_id'] = $row['id'];
    // ...
    $userdata['validity'] = 1;
    $userdata['device_verification'] = $response['validity'] == 1 ? 'no-need-verification' : 'needed-verification';
}
```

`new_login_confirmation($param1, $user_id)` handles the verification-code submit/resend flow when a new device exceeds the limit.

### Bunny CDN in the Mobile API

`Api_model::section_wise_lessons()` and `Api_model::lesson_details_get()` both inject a signed Bunny URL into each lesson payload:

```php
if (!empty($lesson['ejadah_bunny_video_id'])) {
    $signed = $this->generate_bunny_secure_url($lesson['ejadah_bunny_video_id']);
    // attach to response
}
```

So the Flutter app never sees the Bunny security key — it only receives a pre-signed 24h HLS URL.

---

## 6. Core LMS Data Model

> Schema reference: `uploads/install.sql` (full dump). DB: `tafawoq_db_1`, engine `InnoDB`.

### Core LMS Tables

| Table | PK | Purpose | Key columns |
| -------------- | ---- | --------- | ------------- |
| `users` | `id INT UNSIGNED` | All users (admins, students, instructors) | `first_name`, `last_name`, `email`, `password` (sha1), `role_id` (1=admin, 2=student), `is_instructor`, `status`, `image`, `wishlist` (longtext JSON), `sessions` (longtext JSON of `ci_sessions.id`), `verification_code`, `paypal_settings`, `stripe_settings`, `razorpay_settings` |
| `category` | `id INT UNSIGNED` | Course categories (hierarchical via `parent`) | `code`, `name`, `slug`, `parent`, `font_awesome_class`, `thumbnail` |
| `course` | `id INT UNSIGNED` | Course catalog | `title`, `short_description`, `description`, `category_id`, `sub_category_id`, `user_id` (instructor), `price`, `discounted_price`, `level`, `language`, `section` (longtext JSON), `status`, `is_free_course`, `expiry_period`, `meta_keywords`, `meta_description` |
| `section` | `id INT UNSIGNED` | Course sections (module grouping) | `course_id`, `title`, `order` |
| `lesson` | `id INT UNSIGNED` | Lessons within sections | `course_id`, `section_id`, `title`, `duration`, `video_type`, `video_url`, `audio_url`, `lesson_type`, `is_free`, `order`, `attachment`, `attachment_type`, `caption`, `ejadah_bunny_video_id`, `ejadah_bunny_library_id` |
| `enrol` | `id INT UNSIGNED` | Student enrolment records | `user_id`, `course_id`, `gifted_by`, `expiry_date`, `date_added` |
| `payment` | `id` | Payment transactions | Course purchases, instructor payouts |
| `payout` | `id` | Instructor payout requests | `user_id`, `amount`, `status` |
| `language` | `phrase_id INT` | i18n phrase translations (MyISAM) | `phrase`, `english` (base column; additional language columns added dynamically) |
| `ci_sessions` | `id VARCHAR(40)` | Session storage | `ip_address`, `timestamp`, `data` (blob) |
| `settings` | `id` | Key-value system/frontend settings | `key`, `value` |
| `frontend_settings` | `id` | Frontend-specific settings | `key`, `value` |
| `badges` | `id` | Achievement badges | (see `install.sql`) |
| `blogs` / `blog_category` / `blog_comments` | — | Blog subsystem | — |
| `forum_question` / `forum_question_reply` / `forum_question_vote` | — | Course forum Q&A | Used by mobile `forum_*` endpoints. |
| `watch_history` | — | Per-user watch history | Used by `update_watch_history_post`. |

### Course / Section / Lesson Hierarchy

```
course (1) ──< section (n) ──< lesson (n)
  │                │              │
  │                │              ├── video_type: YouTube / Vimeo / bunny_stream / amazon / academy_cloud / html5 / system / google_drive / wasabi_s3
  │                │              ├── lesson_type: video / audio / quiz / text / other / wasabi
  │                │              └── attachment + attachment_type for non-video lessons
  │                │
  │                └── order drives display sequence
  │
  ├── user_id → instructor (users.id)
  ├── category_id / sub_category_id → category.id
  └── section (longtext JSON) caches section ordering on the course row
```

`Crud_model::get_lessons($type, $id)` returns lessons for a course or section. `Crud_model::get_course_by_id($course_id)` returns the course row.

### Enrolment & Access

- `enrol` row grants access. `Api_model::is_purchased($user_id, $course_id)` and `is_added_to_wishlist($user_id, $course_id)` are the canonical checks.
- Free courses use `enroll_free_course_get` to create the `enrol` row without payment.
- Gifted enrolments set `gifted_by`.
- `expiry_date` on `enrol` enforces course access windows.

### Payment Tables & Gateways

`Payment_model` (`application/models/Payment_model.php`) integrates a wide set of gateways. Each gateway has a `check_*_payment($identifier)` method that verifies the transaction and creates the `payment` + `enrol` rows:

| Gateway | Payment_model method |
| --------- | --------------------- |
| PayPal | `check_paypal_payment` |
| Stripe | `check_stripe_payment` |
| Razorpay | `check_razorpay_payment` / `razorpayPrepareData` |
| Skrill | `check_skrill_payment` / `skrill_ipn` |
| PayU | `check_payu_payment` |
| SSLCommerz | `check_sslcommerz_payment` |
| PagSeguro | `check_pagseguro_payment` |
| Xendit | `check_xendit_payment` |
| Doku | `check_doku_payment` |
| bKash | `check_bkash_payment` |
| Cashfree | `check_cashfree_payment` |
| MaxiCash | `check_maxicash_payment` |
| Aamarpay | `check_aamarpay_payment` |
| Flutterwave | `check_flutterwave_payment` |
| Tazapay | `check_tazapay_payment` |

`configure_course_payment()` builds the common payment payload from `cart_items` session (applies coupon, adds tax, sets `success_url`/`cancel_url`/`back_url`).
`configure_instructor_payment($is_instructor_payout_user_id)` builds the payload for instructor payout withdrawals.
`checkLogin($payment_info)` gates the payment controller by session.

Instructor payout settings are stored per-user: `update_instructor_paypal_settings`, `update_instructor_stripe_settings`, `update_instructor_razorpay_settings`.

---

## 7. Frontend Theme & View System

### CI3 View Loading Mechanism

Controllers assemble a `$page_data` array and render a **theme shell**:

```php
// Home.php
public function home()
{
    $page_data['page_name']  = "home";
    $page_data['page_title'] = site_phrase('home');
    $this->load->view('frontend/' . get_frontend_settings('theme') . '/index', $page_data);
}
```

`get_frontend_settings('theme')` returns the active theme folder — currently `default-new`. So the rendered file is `application/views/frontend/default-new/index.php`.

### The `index.php` Shell (Frontend)

`application/views/frontend/default-new/index.php` is the master layout. It:

1. Sets the `<html dir>` from `language_dirs` setting (LTR/RTL support).
2. Includes `seo.php`, `includes_top.php` (CSS/JS `<head>` assets).
3. Injects custom CSS from `frontend_settings.custom_css`.
4. Reads `$this->session->userdata('theme_mode')` for the body class.
5. Includes `header.php` (nav), `eu-cookie.php` (conditional), then **the page partial**:

   ```php
   if ($page_name === null) {
       include $path;
   } else {
       include $page_name.'.php';   // e.g. home.php, course_page.php, login.php
   }
   ```

6. Includes `footer.php`.

So a controller setting `$page_data['page_name'] = 'course_page'` causes `course_page.php` to be injected into the shell.

### Lesson Player Shell (`application/views/lessons/index.php`)

The lesson watching experience uses its own standalone shell (separate from the frontend theme shell) that sets `<html dir>` from `language_dirs`, includes `includes_top.php`, `header.php` (conditional via `eu-cookie.php`), then includes `general_course_content_body.php` (the video player router) and `bottom_tabs.php` / `sidebar.php`. `plyr_config.php` and `vimeo_player_config.php` are conditionally included by the body partial based on `get_lesson_type`.

### Backend Shell (`application/views/backend/index.php`)

Admin pages use a separate shell that routes partials by role:

```php
$logged_in_user_role = strtolower($this->session->userdata('role'));
include $logged_in_user_role.'/'.'navigation.php';          // admin/navigation.php
include $logged_in_user_role.'/'.$page_name.'.php';         // admin/dashboard.php
```

Admin controllers set `$page_data['page_name']` (e.g. `'dashboard'`, `'categories'`) and call `$this->load->view('backend/index.php', $page_data);`.

### Asset Locations

| Asset type | Directory | Referenced via |
| ------------ | ----------- | ---------------- |
| Frontend CSS/JS | `assets/frontend/default-new/css/`, `js/` | `base_url('assets/frontend/default-new/...')` |
| Backend CSS/JS | `assets/backend/css/`, `js/` | `base_url('assets/backend/...')` |
| Global assets | `assets/global/` | `base_url('assets/global/...')` |
| Playing-page assets | `assets/playing-page/css/`, `js/`, `img/` | `base_url('assets/playing-page/...')` |
| System images (logo, favicon) | `uploads/system/` | `base_url('uploads/system/'.get_frontend_settings('favicon'))` |
| Course thumbnails | `uploads/thumbnails/` | `base_url('uploads/thumbnails/...')` |
| User images | `uploads/user_image/` | `base_url('uploads/user_image/...')` |
| Captions | `uploads/captions/` | `base_url('uploads/captions/...')` |

All asset URLs use `base_url()` (auto-computed in `config.php` from `$_SERVER['HTTP_HOST']` + script path) so the app is host-agnostic.

### AJAX Conventions

Frontend AJAX calls target controller methods via `base_url()`:

```js
$.post(base_url + 'home/add_to_cart', { course_id: id }, function (response) { ... });
```

Responses are typically JSON-encoded via `json_encode()` with `Content-Type: application/json` set by the controller.

### Routing (`application/config/routes.php`)

CodeIgniter 3 uses **segment-based routing** by default: `example.com/class/method/id/`. `routes.php` overrides specific patterns with `$route['pattern'] = 'controller/method/$1';`.

```php
$route['default_controller'] = 'home';
$route['404_override']       = 'home/page_not_found';

// Public student portfolio
$route['u/(:any)/certificate/(:num)'] = 'home/verify_certificate/$1/$2';
$route['u/(:any)/certificates']       = 'home/certificate_center/$1';
$route['u/(:any)']                    = 'home/public_profile/$1';

// Addons (bundles, ebooks, blog, tutor booking, certificate)
$route['course_bundles/(:any)']  = "addons/course_bundles/index/$1";
$route['ebook']                  = "addons/ebook/ebooks";
$route['blogs']                  = "blog/blogs";
$route['tutors']                 = "addons/tutor_booking/list_of_tuitions";

// Sitemap
$route['sitemap.xml'] = 'sitemap';

$route['translate_uri_dashes'] = FALSE;
```

The mobile API controllers (`Api`, `Api_instructor`) are reached via default segment routing (`/api/...`, `/api_instructor/...`) — no explicit `routes.php` entries.

---

## 8. Strict Development Rules

> **These rules are mandatory for all AI agents and contributors working on Ejadah.**

### STRICT RULE 1 — Stack Discipline

Never write React, Node.js, TypeScript, Vue, or any non-CI3 framework. This is a **CodeIgniter 3 PHP** application. Frontend is **Bootstrap + jQuery + Vanilla JS** only. The mobile app is **Flutter (Dart)** and only communicates with the CI3 REST controllers. Spec documents written for other stacks (React/TS/Postgres) must be **ported** to PHP/CI3/MySQL, not imported verbatim.

### STRICT RULE 2 — Query Builder Only

All database access must use **CodeIgniter 3 Query Builder** (`$this->db->...`). Never use raw PDO, `mysqli_*`, or plain SQL strings in controllers/views. Complex queries use `$this->db->select()`, `join()`, `where()`, `order_by()`, `limit()`, then `get()` / `get_where()`.

### STRICT RULE 3 — Secure API & AJAX

- API responses must be JSON-encoded with explicit `Content-Type: application/json` and proper HTTP status codes (`set_status_header()`).
- Frontend AJAX must route through `base_url()` + controller path — never direct file access.
- User input must pass through `html_escape($this->input->post(...))` before DB writes.
- Owner-only access is enforced in the model/repository layer — **no database-level RLS**.
- Bunny CDN security keys and JWT secrets never leave the server — the Flutter app only ever receives pre-signed URLs and JWT tokens.

### STRICT RULE 4 — Video Provider Extension

To add a new video provider:

1. Add the `video_type` value to the lesson save/update branches in `Crud_model` (around lines 1517–1595 and 1935–2016).
2. Add an `elseif` branch to `get_lesson_type()` in `application/helpers/common_helper.php`.
3. Add the matching player case to `application/views/lessons/general_course_content_body.php`.
4. If the provider needs signed URLs, add a generator method to `Api_model` (like `generate_bunny_secure_url`) and inject it into `section_wise_lessons()` and `lesson_details_get()` for mobile.
5. Store any API keys as `settings` rows and persist them via `Crud_model` admin settings handlers.

### Additional Conventions (from project memory)

- **Database engine:** MySQL InnoDB (NOT MariaDB). MySQL 8.0.16+ assumed for CHECK constraints.
- **Charset:** `utf8mb4` for emoji support.
- **Generated columns:** MySQL syntax `GENERATED ALWAYS AS (...) STORED`.
- **UUIDs:** Generate in PHP — do not use `gen_random_uuid()`.
- **i18n:** Use `get_phrase($key)` / `get_phrase_($key, $replacements)` from `application/helpers/multi_language_helper.php`. Language JSON packs live in `/languages/`.
- **Standalone PHP test scripts:** Define `BASEPATH` before requiring libraries:

  ```php
  define('BASEPATH', realpath(__DIR__.'/../..'));
  ```

- **System core:** Never modify `/system/` — it is the upstream CI3 framework.
- **Views:** Keep partials in `application/views/frontend/default-new/` (frontend), `application/views/backend/` (admin), or `application/views/lessons/` (lesson player). Inject via `$page_name`, not direct includes from controllers.
- **Role IDs:** `1` = Admin, `2` = Student/User. `is_instructor` is a separate flag on `users` (0/1), not a role.
- **Passwords:** Stored as `sha1(...)` — do not change the hashing scheme without a full migration.
- **Session device limit:** Enforced by `new_device_login_tracker` using `users.sessions` (JSON of `ci_sessions.id`) and the `allowed_device_number_of_loging` setting.

---

## Appendix A — Key File Quick Reference

| Need | File |
| ------ | ------ |
| Routes | `application/config/routes.php` |
| DB config | `application/config/database.php` |
| App config | `application/config/config.php` |
| Autoload | `application/config/autoload.php` |
| Full schema | `uploads/install.sql` |
| Public controller | `application/controllers/Home.php` |
| Auth controller | `application/controllers/Login.php` |
| Student controller | `application/controllers/User.php` |
| Admin controller | `application/controllers/Admin.php` |
| Student mobile API | `application/controllers/Api.php` |
| Instructor mobile API | `application/controllers/Api_instructor.php` |
| Payment controller | `application/controllers/Payment.php` |
| CRUD model | `application/models/Crud_model.php` |
| User/auth model | `application/models/User_model.php` |
| Payment model | `application/models/Payment_model.php` |
| Student API model | `application/models/Api_model.php` |
| Instructor API model | `application/models/Api_instructor_model.php` |
| Video provider model | `application/models/Video_model.php` |
| JWT model | `application/models/Jwt_model.php` |
| JWT library | `application/libraries/TokenHandler.php` |
| REST base | `application/libraries/REST_Controller.php` |
| Lesson type router | `application/helpers/common_helper.php` (`get_lesson_type`) |
| Bunny URL signer | `application/models/Api_model.php` (`generate_bunny_secure_url`) |
| Lesson player body | `application/views/lessons/general_course_content_body.php` |
| Vimeo player config | `application/views/lessons/vimeo_player_config.php` |
| Plyr config | `application/views/lessons/plyr_config.php` |
| Frontend shell | `application/views/frontend/default-new/index.php` |
| Backend shell | `application/views/backend/index.php` |
| Brand guide | `EJADAH_BRAND_GUIDE.md` |

## Appendix B — Active Theme Partial Map (`frontend/default-new/`)

| Partial | Purpose |
| --------- | --------- |
| `index.php` | Master shell |
| `header.php` / `header_ejadah.php` | Site header / nav |
| `header_lg_device.php` / `header_sm_device.php` | Responsive headers |
| `logged_in_header.php` / `logged_out_header.php` | Auth-state headers |
| `footer.php` / `footer_ejadah.php` | Site footer |
| `home.php` / `home_ejadah.php` | Homepage variants |
| `course_page.php` | Course details |
| `courses_page.php` | Course listing |
| `login.php` / `sign_up.php` | Auth pages |
| `user_profile.php` | Student profile |
| `public_profile.php` | Public portfolio (Ejadah custom) |
| `certificate_center.php` / `certificate_verification.php` | Certificates |
| `shopping_cart.php` | Cart |
| `my_courses.php` / `my_certificates.php` / `my_wishlist.php` | Student dashboard pages |
| `ejadah/` | Ejadah-branded custom partials |
| `includes_top.php` / `includes_bottom.php` | Asset bundles |
| `modal.php` | Modal partials |
| `seo.php` | Meta tags |
| `404.php` | Not found |
