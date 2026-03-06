
# 🐾 Animal Presence Map (Flutter MVP)

A mobile application that overlays **real-time animal presence alerts**
on a Google Maps interface and provides **verbal notifications** to
drivers.

This project serves as a **Minimum Viable Product (MVP)** that connects
a **computer vision animal detection system** (running externally on a
Raspberry Pi or server) with a **mobile visualization and alerting client**.

The mobile app does **not perform detection itself**. It receives
detection events from the detection system and converts them into
clear visual and audio warnings for drivers.

---

# 🚗 Project Purpose

Wildlife crossing roads is a major cause of vehicle accidents worldwide.
Drivers often have very little warning before encountering animals such
as deer, coyotes, or other wildlife.

This project explores a simple concept:

**Use roadside computer vision to detect animals and notify nearby drivers
through a mobile application.**

The system therefore consists of two independent parts:

1. **Detection System (Raspberry Pi / Server)** – performs animal detection
2. **Mobile Application (this repository)** – displays detections and alerts drivers

The mobile application acts as a **real‑time hazard visualization layer**.

Its responsibilities include:

- displaying animal detections on a map
- converting raw detection events into map markers
- determining whether a detection is relevant to the driver
- providing optional voice alerts

---

# 🏗 System Architecture

The system architecture is intentionally modular so that detection and
mobile visualization evolve independently.

Overall pipeline:

Camera → Detection System → Event Stream → Mobile App → Driver Alerts

## Detection System (External Component)

The detection system is responsible for:

- capturing camera frames
- detecting animals using computer vision / ML models
- estimating geographic coordinates
- generating detection events
- broadcasting those events to connected clients

This component may run on:

- Raspberry Pi
- Edge GPU device
- Cloud server

The detection implementation is **not included in this repository**.

## Mobile Application (This Repository)

The Flutter application is responsible for:

- connecting to the detection system
- receiving detection events
- displaying animal icons on a map
- filtering events based on relevance
- notifying drivers verbally

The mobile app therefore acts as the **presentation and driver alert layer**.

---

# 🔄 Data Flow

The runtime pipeline operates as follows:

1. A camera observes the road.
2. The detection system identifies an animal.
3. A detection event is generated.
4. The detection event is transmitted to the mobile app.
5. The mobile app parses the event.
6. The app creates a marker on the map.
7. The app determines if the animal is close enough to warn the driver.
8. If relevant, the app triggers a voice alert.
9. After a time period, stale detections expire and disappear.

This pipeline ensures drivers only see **recent and relevant hazards**.

---

# 📡 Detection Event Format

Detection events are transmitted from the detection system to the app.

Example:

```json
{
  "id": "event_123",
  "lat": 33.6512,
  "lng": -117.6789,
  "animal": "deer",
  "confidence": 0.92,
  "timestamp": 1739150000
}
```

| Field | Description |
|------|-------------|
| id | Unique identifier for the detection event |
| lat / lng | Geographic coordinates |
| animal | Type of detected animal |
| confidence | Detection confidence score |
| timestamp | Unix timestamp of detection |

The mobile application converts these events into map markers and alerts.

---

# 📱 Technology Stack

## Mobile Client

- **Flutter**
- **Dart**
- **Google Maps Flutter SDK**
- **Android SDK**
- **ADB for deployment**

Planned additions:

- WebSocket client for real‑time events
- Text‑to‑Speech engine for driver alerts

Flutter was chosen because it enables **fast iteration and cross‑platform
mobile development from a single codebase**.

---

# 🧠 Mobile Application Responsibilities

The mobile client performs several tasks beyond simply displaying data.

## Map Rendering

The application embeds a Google Map and allows the user to:

- pan
- zoom
- view current location

The map becomes the visual canvas for detection events.

## Marker Visualization

Each detection event is rendered as a marker.

Different animal types use different icons:

- deer
- coyote
- etc.

Unknown types fall back to a default marker.

Markers represent **recent detections**, not permanent map objects.

## Marker Lifecycle

Each detection event has a limited lifespan.

Markers automatically expire after a configured TTL to prevent the map
from accumulating outdated hazards.

## Event Filtering

The app determines which detections are relevant to the driver based on:

- distance from driver
- confidence threshold
- marker age
- user settings

## Voice Alerts

When a driver approaches a relevant detection, the app can produce a
spoken alert such as:

"Animal ahead: deer"

Alerts are rate‑limited to avoid distracting the driver.

---

# 🛠 Development Environment

## Requirements

- Ubuntu 24.04 (or similar Linux)
- Flutter (stable channel)
- Android SDK (API 36+)
- A physical Android device
- USB debugging enabled on the device

---

# ⚙ Installing Flutter

Example installation:

```bash
git clone https://github.com/flutter/flutter.git -b stable ~/flutter
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
source ~/.bashrc
```

Verify installation:

```bash
flutter doctor
```

---

# ⚙ Android SDK Setup

Install required packages:

```bash
sdkmanager "platform-tools" "platforms;android-36" "build-tools;36.0.0"
```

Accept licenses:

```bash
flutter doctor --android-licenses
```

---

# 🔌 Connecting an Android Device

Enable on the phone:

- Developer Mode
- USB Debugging

Verify device:

```bash
adb devices
flutter devices
```

---

# ▶ Running the Application

## Prerequisites

Before running the app, ensure:

1. Flutter is installed and `flutter doctor` reports no errors.
2. An Android device is connected via USB with USB debugging enabled.
3. `android/local.properties` contains a valid `MAPS_API_KEY` entry
   (see [Google Maps API Key](#-google-maps-api-key)).

## Verify Device Connection

```bash
adb devices
flutter devices
```

Both commands should list the connected device.

## Build and Run

Navigate to the project root and run:

```bash
cd animal_map
flutter clean
flutter pub get
flutter run -d <DEVICE_ID>
```

`flutter clean` removes stale build artifacts.
`flutter pub get` fetches all dependencies.
Replace `<DEVICE_ID>` with the device identifier shown by `flutter devices`.

To prevent Flutter from attempting a Linux desktop build (if not needed):

```bash
flutter config --no-enable-linux-desktop
```

## Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| Map shows blank white / grey tiles | Device has no internet connection | Connect to Wi‑Fi or mobile data |
| Map shows blank white / grey tiles | GCP billing not enabled | Enable billing on the Cloud project |
| Map shows blank white / grey tiles | API key missing or invalid | Verify `MAPS_API_KEY` in `android/local.properties` |
| Build fails with missing API key | `local.properties` not created | Create the file and add the key (see above) |
| `flutter run` finds no devices | USB debugging not enabled | Enable Developer Mode and USB Debugging on device |
| `flutter run` finds no devices | USB cable is charge‑only | Use a data‑capable cable |

---

# 🧪 Running Tests

Run the full test suite:

```bash
flutter test
```

Run a specific test file:

```bash
flutter test test/config/map_config_test.dart
```

## Test Organisation

| Directory | Purpose |
|-----------|---------|
| `test/config/` | Unit tests for configuration constants |
| `test/screens/` | Widget tests for screen widgets |
| `test/services/` | Unit tests for service interfaces and fakes |
| `test/fakes/` | Configurable fake implementations for DI |
| `test/stories/` | BDD‑style scenario tests grouped by user story |

Widget tests inject fakes via constructor parameters to avoid
real platform calls during testing.

---

# 📂 Project Structure

```
animal_map/
│
├── lib/
│   ├── main.dart                          # Entry point, map renderer init
│   ├── app.dart                           # Root MaterialApp with DI
│   ├── config/
│   │   └── map_config.dart                # Map constants (center, zoom)
│   ├── screens/
│   │   └── map/
│   │       └── map_screen.dart            # Google Map widget
│   └── services/
│       ├── location_permission_service.dart       # Abstract interface
│       └── location_permission_service_impl.dart  # Concrete implementation
│
├── test/
│   ├── config/
│   │   └── map_config_test.dart           # MapConfig unit tests
│   ├── fakes/
│   │   └── fake_location_permission_service.dart  # Configurable fake
│   ├── screens/
│   │   └── map/
│   │       └── map_screen_test.dart       # Widget tests with DI
│   ├── services/
│   │   └── location_permission_service_test.dart  # Service unit tests
│   └── stories/
│       └── story1/
│           └── map_renders_test.dart      # BDD scenario tests
│
├── android/                               # Android build configuration
├── ios/                                   # iOS build configuration
├── web/                                   # Web configuration
├── pubspec.yaml                           # Dependencies and metadata
└── build/                                 # Generated artifacts (ignored)
```

Architecture follows **Dependency Inversion Principle (DIP)**:

- Services are defined as abstract interfaces in `lib/services/`
- Concrete implementations live alongside their interfaces
- Widgets accept services via constructor injection
- Tests substitute fakes from `test/fakes/`

---

# 🔐 Google Maps API Key

Google Maps requires an API key obtained from the
[Google Cloud Console](https://console.cloud.google.com/).

## Obtaining a Key

1. Create a Google Cloud project (or reuse an existing one).
2. Enable **Maps SDK for Android** under APIs & Services.
3. Create an API key under **Credentials**.
4. Restrict the key by **Android application** with:
   - package name (`com.example.animal_map`)
   - SHA‑1 certificate fingerprint

## Configuring the Key

The key is **never committed to version control**.

Create or edit `android/local.properties` and add:

```properties
MAPS_API_KEY=YOUR_API_KEY_HERE
```

The build pipeline wires the key automatically:

```
android/local.properties          (source of truth, gitignored)
  → android/app/build.gradle.kts  (reads key, sets manifestPlaceholders)
    → AndroidManifest.xml          (references ${MAPS_API_KEY} placeholder)
```

No manual editing of `AndroidManifest.xml` is required.

---

# 🎯 MVP Goals

Current objectives for the MVP:

- Display Google Map in Flutter
- Render custom animal markers
- Receive real‑time detection events
- Remove stale markers automatically
- Trigger proximity‑based voice alerts
- Allow configurable alert radius
- Support confidence filtering

---

# 🚦 Future Improvements

Potential future features include:

- marker clustering for dense detections
- route‑aware hazard filtering
- background alert support
- integration with navigation SDKs
- backend authentication
- historical detection analytics
- multiple detection nodes along highways

---

# 📜 License

Private repository for experimental development.

---

# 👤 Author

Mark Tikhonv (mtik.philosopher@gmail.com)

Experimental project exploring:

- embedded AI systems
- real‑time geospatial visualization
- mobile safety applications

---

**Status:** Early‑stage MVP under active development