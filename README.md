
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

Navigate to the project directory:

```bash
cd animal_map
```

Run the application:

```bash
flutter run -d <DEVICE_ID>
```

To prevent Flutter from attempting Linux desktop builds:

```bash
flutter config --no-enable-linux-desktop
```

---

# 📂 Project Structure

```
animal_map/
│
├── lib/                # Dart application source code
│   └── main.dart
│
├── android/            # Android build configuration
├── ios/                # iOS build configuration
├── web/                # Web configuration (optional)
├── test/               # Widget/unit tests
│
├── pubspec.yaml        # Dependencies and metadata
└── build/              # Generated artifacts (ignored)
```

The primary development work occurs in:

```
lib/
```

---

# 🔐 Google Maps API Key

Google Maps requires an API key.

Add the key to:

```
android/app/src/main/AndroidManifest.xml
```

Example:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

For security, always restrict the key by:

- package name
- SHA‑1 certificate fingerprint

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