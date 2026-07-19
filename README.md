# ALU Grid

A mobile application that connects ALU students looking for internship experience with student-led startups within the ALU ecosystem. It is built with Flutter and Firebase.

---

## What it does

Students can browse internship opportunities posted by ALU startups, apply with a cover letter and a portfolio link, track their application status, and chat directly with the startup. Startups can post roles, see who applied, accept or decline applicants, and message students all in one place.

---

## Features

**What students can do**
- Register with their ALU email and set up a profile with skills, bio, and year of study
- Browse all available internship opportunities
- Search by keyword or filter by role category
- See a "Match" badge on jobs that match their skills
- Apply with a cover letter and optional portfolio link (GitHub, LinkedIn, etc.)
- Track their applications in real time (Pending / Accepted / Not Selected)
- Message startups directly from the job page

**What startups can do**
- Register with an ALU email and set up a startup profile
- Post internship opportunities with role type, location, duration, and work style
- Edit or delete their posted jobs
- View all applicants, read their cover letters, and open their portfolio links
- Accept applicants, mark them as not selected, or reconsider
- Message students directly from the applicants screen

**Other Features added**
- Skill-based job matching, jobs that fit your skills appear at the top with a green badge
- Real-time chat between students and startups
- Unread message indicator on the Messages tab
- Dark and light mode (toggled from the profile screen)
- Work type tags: Remote, Hybrid, or In-Person
- Account deletion

---

## Tech stack

- **Flutter** — the mobile framework
- **Firebase Auth** — handles login and registration
- **Cloud Firestore** — stores all the app data in real time
- **Provider** — state management across screens
- **url_launcher** — opens portfolio links in the browser

---

## How the project is organized

```
lib/
  main.dart                      ← app entry point, sets up providers
  firebase_options.dart          ← Firebase credentials (not pushed to GitHub)
  providers/
    auth_provider.dart           ← manages logged-in user, role, and session
    theme_provider.dart          ← handles dark/light mode
  screens/
    splash_screen.dart
    login_screen.dart
    register_screen.dart
    home_screen.dart             ← bottom navigation, switches tabs by role
    browse_screen.dart           ← job listings, search, skill matching
    job_detail_screen.dart       ← full job view + apply form
    applications_screen.dart     ← student's application history
    startup_dashboard_screen.dart
    post_job_screen.dart
    edit_job_screen.dart
    applicants_screen.dart       ← applicants for one specific job
    all_applicants_screen.dart   ← all applicants across all jobs
    messages_screen.dart
    chat_screen.dart
    search_users_screen.dart
    profile_screen.dart
  models/
  services/
  widgets/
```

---

## Firebase structure

I used five Firestore collections:

| Collection | What it stores |
|---|---|
| `users` | Profile info for both students and startups |
| `jobs` | Internship opportunities posted by startups |
| `applications` | Each student's application and its status |
| `chats` | Conversation info between two users |
| `chats/{id}/messages` | The actual messages (subcollection) |

---

## Who can sign up

The platform is only for people in the ALU community:

| Role | Email required |
|---|---|
| Student | must end with `@alustudent.com` |
| Startup | `@alustudent.com` or `@alueducation.com` |

Anyone outside these domains gets blocked at registration.

---

## State management

I used **Provider** for this. Two main classes handle global state:

- `AuthProvider` : keeps track of who is logged in, their role (student or startup), their name, loading states, and errors. It listens to Firebase's `authStateChanges()` stream so every screen updates automatically when someone logs in or out.
- `ThemeProvider` : controls dark/light mode. When you tap the toggle on the profile screen, every screen switches instantly.

For live data like job listings, messages, and applications, I used `StreamBuilder`. It listens to a Firestore query and rebuilds the UI the moment the data changes, no manual refresh needed.

---

## Running the project locally

1. Clone the repo
2. Run `flutter pub get`
3. Add your `google-services.json` to `android/app/`
4. Add your `lib/firebase_options.dart` with your Firebase project credentials
5. In Firebase Console: enable Email/Password sign-in under Authentication
6. Create a Firestore database in test mode
7. Run `flutter run`
