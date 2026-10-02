# Swifty Companion - my notes

This file is ignored by git. It is only for me.

Contents:
1. The big ideas (API, OAuth, Flutter)
2. The folders and files
3. How to run the app
4. What happens in the code
5. Words I must know
6. Packages and why
7. The evaluation sheet, question by question
8. Other questions I may get

---

## 1. The big ideas

### What is an API?

API = Application Programming Interface.

It is a way for two programs to talk. One program asks, the other answers.

Think of a restaurant:
- I am the customer (my app).
- The kitchen has the food (the 42 database).
- I cannot walk into the kitchen. I give my order to the waiter.
- The waiter is the API. He takes my order and brings back the food.

In my app:
- The order is a URL: `https://api.intra.42.fr/v2/users/aputri-a`
- The food is the answer: text in JSON format with the user's info.

The 42 API is a "REST" API. That means I talk to it with normal web requests (HTTP), the same way a browser opens a web page.

### What is OAuth2?

OAuth2 is a safe way to log in with another service.

The problem: my app needs 42 data, but my app must never see the user's 42 password.

The answer: the user logs in on the real 42 page, and 42 gives my app a **token** (a temporary pass).

Think of a hotel:
- I show my passport at the front desk (I log in on the 42 page).
- The desk gives me a key card (the token).
- The key card opens my room for a few days (the token works for 2 hours).
- The doors never see my passport, only the card (the API never gets the password from my app).

The steps in my app:
1. The app opens the 42 login page (`/oauth/authorize`).
2. The user logs in and presses "Authorize".
3. 42 sends the user back to my app with a short **code**. It finds my app with the redirect URI `com.swiftycompanion://callback`.
4. My app sends the code + UID + SECRET to `/oauth/token`.
5. 42 answers with an **access token** and a **refresh token**.
6. Every request after that carries the access token.

UID and SECRET are the name and password of my *app* (not of the user). I got them when I made the app on intra.

### What is Flutter?

Flutter is a tool from Google to build apps. It is a "framework": a big box of ready pieces (buttons, text, lists, screens).

- I write the code in a language called **Dart**.
- Flutter turns that one code into an Android app and an iOS app.
- Everything on the screen is a **widget**. I build a screen by putting widgets inside widgets.

### Why Flutter?

- **One code base.** I write once, it runs on Android and iOS. With Kotlin or Swift I would write the app two times.
- **Hot reload.** I save the file and see the change in one second.
- **Layout is flexible by default.** `Row`, `Column`, `Expanded` fit any screen size. The subject asks for this.
- **Good packages.** OAuth, HTTP and image cache already exist on pub.dev.
- **The subject names it.** The goals list "Mobile Frameworks (Flutter)".
- **It is used in real jobs.**

---

## 2. The folders and files

### Made by `flutter create` (I did not write these)

`flutter create swifty_companion` makes the whole project skeleton.

| Folder / file | What it is | Do I change it? |
|---|---|---|
| `android/` | A real Android project. It wraps my Dart code so it runs on Android. | Only 2 small lines (see below). |
| `ios/` | A real iOS project. Same job for iPhone. | Only 1 small block (see below). |
| `linux/`, `macos/`, `windows/`, `web/` | The same wrappers for desktop and web. | No. I do not use them. |
| `lib/` | Where my Dart code lives. It starts with only `main.dart`. | Yes. All my work is here. |
| `test/` | For automatic tests. It had one example test for a counter app. | I deleted the example. It tested an app that is not mine. |
| `pubspec.yaml` | The ID card of the project: name, version, packages. | Yes. I added my packages and `.env`. |
| `pubspec.lock` | The exact version of every package. Flutter writes it. | No. Never by hand. |
| `analysis_options.yaml` | Rules for the code checker (`flutter analyze`). | No. |
| `.gitignore` | Files git must not save. | Yes. I added `.env` and `notes.md`. |
| `.metadata` | Flutter's own info (which version made the project). | No. |
| `README.md` | The project description. | Yes. I wrote my own. |

### Made by Flutter when I build or run (not in git)

| Folder / file | What it is |
|---|---|
| `.dart_tool/` | Flutter's work folder. Made by `flutter pub get`. It remembers where the packages are. |
| `build/` | The result of the build: the `.apk` file and temp files. Made by `flutter run` or `flutter build`. |
| `.flutter-plugins-dependencies` | A list of the plugins that have native code. Made by `flutter pub get`. |

I can delete all three. `flutter clean` deletes them. `flutter pub get` and `flutter run` make them again. That is why they are in `.gitignore`.

### Written by me

| File | What it does |
|---|---|
| `lib/main.dart` | Start of the app. Loads `.env`, then shows the search screen. |
| `lib/screens/search_screen.dart` | View 1. Login button, then the text field and Search button. |
| `lib/screens/profile_screen.dart` | View 2. Picture, details, level, projects, skills. |
| `lib/services/api_service.dart` | All talking to the 42 API: login, token, refresh, get user. |
| `lib/models/user_model.dart` | Turns the JSON from the API into Dart objects (`User`, `Skill`, `Project`, `Coalition`). |
| `lib/theme/app_theme.dart` | Colors and the look of buttons and text fields. |
| `.env` | My UID and SECRET. Not in git. |
| `.env-example` | Shows which names go in `.env`, with no real values. In git. |

Why three folders in `lib/`? To keep things apart:
- `screens` = what the user sees
- `services` = talking to the internet
- `models` = the shape of the data

### The small changes I made in generated files

| File | What I added | Why |
|---|---|---|
| `pubspec.yaml` | `http`, `flutter_appauth`, `flutter_dotenv`, `cached_network_image`, and `.env` under `assets` | My packages. `.env` must be an asset so the app can read it. |
| `android/app/build.gradle.kts` | `manifestPlaceholders["appAuthRedirectScheme"] = "com.swiftycompanion"` | So Android knows that links starting with `com.swiftycompanion://` open my app. Needed for the 42 login to come back. |
| `android/app/src/main/AndroidManifest.xml` | `<uses-permission android:name="android.permission.INTERNET"/>` | Android blocks the internet unless the app asks for it. |
| `ios/Runner/Info.plist` | `CFBundleURLSchemes` with `com.swiftycompanion` | The same redirect thing, for iPhone. |
| `.gitignore` | `.env`, `notes.md` | Keep secrets and my notes out of git. |

Other changes in `ios/` and `macos/` (Podfile and so on) were made by the tools when I added packages. I did not write them.

---

## 3. How to run the app

```
flutter pub get      # download the packages
flutter devices      # see which phone / emulator is ready
flutter run          # build and start the app
```

The file `.env` must exist in the project folder:

```
UID=my_app_uid
SECRET=my_app_secret
```

I get these on intra: Settings -> API -> my application.
The redirect URI on that page must be `com.swiftycompanion://callback`.
The secret on intra expires after some weeks. Check it before the evaluation.

Never commit `.env`. If the secret is in git, the mark is 0.

On this school computer, Java 25 from Android Studio is too new for the project. Use Java 21:

```
flutter config --jdk-dir /sgoinfre/goinfre/Perso/aputri-a/jdk21
```

---

## 4. What happens in the code

**Start** (`main.dart`)
1. `dotenv.load` reads `.env`.
2. `runApp(MyApp())` starts Flutter.
3. `MaterialApp` sets the theme and opens `SearchScreen`.

**Login** (`search_screen.dart` `_login` -> `api_service.dart` `login`)
1. Read UID and SECRET from `.env`.
2. `authorizeAndExchangeCode` opens the 42 page and returns the tokens.
3. Save access token, refresh token and expiry time in `ApiService`.
4. `_isLoggedIn = true`, so the screen shows the search field.

**Search** (`_search` -> `getUser`)
1. Empty text -> message "Please enter a login."
2. `_refreshIfNeeded` checks the token. Still good -> keep it. Less than 1 minute left -> refresh.
3. GET `/users/LOGIN`.
   - 404 -> return `null` -> "User not found."
   - not 200 -> "Server error".
   - 200 -> `User.fromJson`.
4. Two more GETs for the coalition, score and rank. If they fail, the profile still opens.
5. No internet -> `SocketException`. More than 10 seconds -> `TimeoutException`. Each has its own message.
6. If a user comes back, `Navigator.push` opens `ProfileScreen`.

**Reading the user** (`user_model.dart`)
- `cursus_users` is the list of the user's cursus. I take the one with slug `42cursus`. If there is none I take the last one. Level and skills come from there.
- `projects_users` is the list of projects.
- `image.link` is the picture.

**Profile screen** (`profile_screen.dart`)
- Banner color comes from the coalition.
- Level bar: level 5.42 means level 5 and 42%.
- Skills: the bar and the percent are `level / 21`, because 21 is the top level.
- Projects: I show cursus 21 (42cursus) projects. If the user has none (piscine or staff), I show all projects. Green = validated, red = failed, blue = in progress. First 5 are shown, "show all" opens the rest.
- Back arrow: `Navigator.pop`.

---

## 5. Words I must know

### Internet words

**Endpoint** - one URL of the API. I use three:
- `/users/LOGIN` - all info of one user
- `/users/LOGIN/coalitions` - the coalition (name and color)
- `/coalitions_users?filter[user_id]=ID` - score and rank in the coalition

**HTTP GET** - a request that only reads data.

**Header** - extra info sent with a request. My token goes here: `Authorization: Bearer THE_TOKEN`.

**Status code** - a number in the answer.
- 200 = OK
- 401 = token is bad or expired
- 404 = not found (the login does not exist)
- 429 = too many requests
- 500 = the server has a problem

**JSON** - the text format of the answer: `{"login": "aputri-a", "wallet": 50}`. `jsonDecode` turns it into a Dart map. `User.fromJson` picks the fields I need.

**Access token** - the temporary pass. A 42 token lives 2 hours.

**Refresh token** - a second pass. The app sends it to `/oauth/token` to get a new access token. The user does not log in again.

**Redirect URI** - the address 42 uses to send the user back to my app after login.

**.env** - a file with secret values, kept out of git.

### Flutter words

**Widget** - every piece of the screen: text, button, row, the whole screen.

**StatelessWidget** - a widget that never changes. Example: `MyApp`.

**StatefulWidget** - a widget with values that can change. Example: `SearchScreen` has `_isLoading` and `_isLoggedIn`.

**setState** - tells Flutter "a value changed, draw the screen again".

**build** - the function that returns what the screen looks like. Flutter calls it after every `setState`.

**async / await / Future** - network calls are slow. `await` waits for the answer without freezing the screen. A `Future` is a value that will come later.

**try / catch** - if something breaks, the code jumps to `catch` and I show a message. The app does not crash.

**Navigator.push / Navigator.pop** - `push` opens a screen on top. `pop` closes it and goes back.

**SnackBar** - the small message at the bottom of the screen. I use it for errors.

**mounted** - true if the screen still exists. I check it before I use `context` after an `await`.

**`?? ''`** - if the left value is null, use the right value.

**`!`** - I promise Dart this value is not null.

**`?`** after a type (`String?`) - this value is allowed to be null.

### Layout words

- `Column` / `Row` - put things under or next to each other
- `Expanded` - take all the space that is left
- `LayoutBuilder` - gives me the real width. I use it for the level bar and the skill bars.
- `SingleChildScrollView` - the content can scroll if it is longer than the screen
- `SafeArea` - keeps content away from the notch and the status bar
- `double.infinity` - as wide as possible

---

## 6. Packages and why

I must explain each one. They are listed in `pubspec.yaml`.

| Package | Why I use it | Without it |
|---|---|---|
| `http` | Sends GET requests to the 42 API. | I would write low level network code by hand. |
| `flutter_appauth` | Does the OAuth2 login and the token refresh. Opens the secure system browser. | I would build the login page flow and the redirect by hand. It is easy to make it unsafe. |
| `flutter_dotenv` | Reads UID and SECRET from `.env`. | The secrets would be written in the code and go to git. |
| `cached_network_image` | Loads the profile picture, keeps it in a cache, shows a fallback if it fails. | The picture would download again every time, and a broken link would show an error. |

---

## 7. The evaluation sheet, question by question

### Preliminaries

**"There is something in the git repository"**
- Show: `git log` and the files.

**"No cheating, student must be able to explain the code"**
- Be ready to open any file in `lib/` and say what it does. Use section 4.

**"Credentials must be in a .env file. If they are in git, the mark is 0."**
- Show: `.gitignore` has the line `.env`.
- Show: `git ls-files | grep env` gives only `.env-example`.
- Show: `.env-example` has no real values.
- Show: `api_service.dart` reads them with `dotenv.env['UID']` and `dotenv.env['SECRET']`. They are not written in the code.
- In the evaluation I create `.env` by hand with my UID and SECRET.

### Mandatory

**"Compilation: the project compiles and launches the simulator"**
- Do: `flutter pub get`, then `flutter run`.
- Start the emulator before the evaluator comes.

**"Views: at least 2 views. The first has a text input to search for logins. The second shows the user information."**
- Show: the search screen and the profile screen.
- Files: `lib/screens/search_screen.dart` (the `TextField`), `lib/screens/profile_screen.dart`.
- The move between them: `Navigator.push` in `_search`.

**"API: the most recent 42 API is used"**
- Show: `_baseUrl = 'https://api.intra.42.fr/v2'` in `lib/services/api_service.dart`.
- Say: v2 is the latest version of the 42 API.

**"Search User: a login of a student or staff of your campus, and a login that does not exist"**
- Do: search my own login. Search a staff login. Search `zzzzzzzz`.
- Fake login shows: `User "zzzzzzzz" not found.`
- File: `api_service.dart` -> `if (userResponse.statusCode == 404) return null;`
- File: `search_screen.dart` -> `if (user == null) errorMessage = ...`
- Also show: empty field, and wifi turned off. Each has its own message.
- Say: I throw `ApiException` for network problems, so "not found" and "no internet" are not mixed.

**"Dashboard -> Profile View: at least four details and the picture"**
- Show: display name, login, email, level, location, wallet, eval points, coalition rank and score, picture.
- Files: `profile_screen.dart` -> `_buildInfo`, `_buildAvatar`, `_buildLevelBar`, `_buildStats`, `_buildBanner`.
- The data comes from `User.fromJson` in `user_model.dart`.
- Say: there is no phone number because 42 hides it for privacy. The subject allows this.

**"Dashboard -> Skills: skills with level and percentage"**
- Show: each skill has a name, a bar, the level and the percent.
- File: `profile_screen.dart` -> `_buildSkills`, `_buildSkillRow`.
- Say: the percent is `level / 21 * 100`. 21 is the highest level, so the bar shows how far the skill is from the top.
- The skills come from `cursus_users` in `user_model.dart`.

**"Dashboard -> Projects: all projects completed, including failed ones"**
- Show: tap "show all". Point at a green one (validated) and a red one (failed).
- File: `profile_screen.dart` -> `_buildProjects`, `_buildProjectRow`.
- Say: the list first shows 5 to keep the screen short. "show all" opens the full list.
- Say: I hide projects with status `parent`. They are only containers for other projects.

**"Autolayout: runs on phones with different screen sizes"**
- Do: run on two emulators (a small and a big phone). Rotate the phone.
- Say: I never use a fixed screen size. I use `Expanded`, `LayoutBuilder`, `double.infinity`, `SafeArea` and `SingleChildScrollView`.
- Files: `search_screen.dart` and `profile_screen.dart`.

**"Token API: the app does not create a new token for each request"**
- Show: `_accessToken`, `_refreshToken`, `_tokenExpiry` at the top of `ApiService`.
- Show: `login()` is the only place that gets the first token. It runs one time, when I press "Login with 42".
- Show: `getUser` sends the saved token in the header for all three requests.
- Show: `_refreshIfNeeded` returns `true` and does nothing while the token is still good.
- Say: `SearchScreen` makes one `ApiService` and keeps it, so the token stays in memory for the whole session.

### Bonus

**"The token has an expiration date. If it expires, the app refreshes it."**
- Show: `_refreshIfNeeded` in `api_service.dart`.
- Say: 42 gives the expiry time with the token. I save it in `_tokenExpiry`.
- Say: before each search I compare it with `DateTime.now()`. If less than 1 minute is left, I call `_appAuth.token(...)` with the refresh token and save the new token.
- Say: the user does not need to log in again. If the refresh fails, the app says "Session expired. Please log in again."

---

## 8. Other questions I may get

**Where is the token stored?**
In memory, in `ApiService`. It is gone when the app closes. Then the user logs in again.

**Why not save the token on the phone?**
Memory is simpler and safer for this project. Nothing secret stays on the phone.

**Why 3 requests for one search?**
The user endpoint has no coalition score. All three use the same token.

**Why is the secret inside the app?**
The 42 API needs it to give a token. In a real product the secret should be on a server. For this project the subject asks for a `.env` file.

**What does the logout button do?**
It clears the tokens in memory and shows the login view again.

**What is the timeout for?**
If the API does not answer in 10 seconds, I stop waiting and show "Request timed out".

**What is `ApiException`?**
My own error type. It carries a message for the user.

**What is `factory User.fromJson`?**
A function that builds a `User` from the JSON map.

**Why `StatefulWidget` for the screens?**
They have values that change: loading, logged in, "show all" open or closed.

**What does `flutter pub get` do?**
It reads `pubspec.yaml` and downloads the packages.

**What does `flutter clean` do?**
It deletes `build/` and `.dart_tool/`. They are made again on the next run.
