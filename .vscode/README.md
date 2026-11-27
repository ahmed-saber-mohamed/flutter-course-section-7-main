# MyAnime — Flutter Anime Explorer

A clean, responsive Flutter application powered by the **Kitsu API** that allows users to browse trending anime, search titles in real time, and manage a personal favourites list per user account.

## Features
- **Multi-User Authentication:** Local login & registration with isolated favourites storage per user using `SharedPreferences`.
- **Browse & Pagination:** Infinite scrolling feed of anime from the Kitsu REST API with smooth loading states.
- **Real-Time Search:** Instant search by title with empty-state and error-handling feedback.
- **Personal Favourites:** Add or remove anime from favourites with persistent local state.
- **Clean Architecture & Error Handling:** Centralized Dio HTTP client (`ApiClient`) with custom `ApiException` handling for network and server errors.

## Tech Stack
- **Framework:** Flutter (Dart)
- **Networking:** `dio`
- **Navigation:** `go_router`
- **Local Storage:** `shared_preferences`
- **API:** [Kitsu API](https://kitsu.docs.apiary.io/)

## How to Run
1. Clone the repository:
   ```bash
   git clone <YOUR_REPO_LINK>