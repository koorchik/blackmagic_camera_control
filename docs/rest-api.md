Here is the unified and logically structured documentation for your Android/Desktop application. This guide consolidates all endpoints into functional groups (Control, Workflow, System) and integrates the WebSocket notification logic for a complete developer reference.

### **1. General Configuration**

- **Protocol:** HTTP / REST
- **Format:** JSON
- **Base URL:** `https://<camera-ip-address>/control/api/v1`
- **Prerequisites:**
- Enable **"Web media manager"** in the camera's _Blackmagic Camera Setup_ > _Network Access_ settings.
- **HTTPS:** The connection should use HTTPS. Certificates may be self-signed on local networks.

---

### **2. Camera Control API (Optics & Image)**

This section covers the physical manipulation of the camera lens and sensor parameters.

#### **2.1. Lens Control**

| Feature          | Method    | Endpoint                  | Payload / Description                                       |
| ---------------- | --------- | ------------------------- | ----------------------------------------------------------- |
| **Get Focus**    | `GET`     | `/lens/focus`             | Returns `{"normalised": 0.5}` (0.0=Near, 1.0=Infinity)      |
| **Set Focus**    | `PUT`     | `/lens/focus`             | Body: `{"normalised": 0.6}`                                 |
| **Auto Focus**   | `PUT`     | `/lens/focus/doAutoFocus` | Body: `{"position": {"x": 0.5, "y": 0.5}}` (Center trigger) |
| **Get Aperture** | `GET`     | `/lens/iris`              | Returns `{"apertureStop": 5.6, "normalised": 0.4}`          |
| **Set Aperture** | `PUT`     | `/lens/iris`              | Body: `{"apertureStop": 4.0}` OR `{"normalised": 0.5}`      |
| **Zoom**         | `GET/PUT` | `/lens/zoom`              | Body: `{"focalLength": 50}` or `{"normalised": 0.5}`        |

#### **2.2. Exposure & Sensor**

| Feature           | Method    | Endpoint                     | Payload / Description                                             |
| ----------------- | --------- | ---------------------------- | ----------------------------------------------------------------- |
| **Shutter**       | `GET`     | `/video/shutter`             | Returns `{"shutterSpeed": 50, "shutterAngle": 180.0}`             |
| **Set Shutter**   | `PUT`     | `/video/shutter`             | Body: `{"shutterSpeed": 100}` OR `{"shutterAngle": 172.8}`        |
| **ISO**           | `GET`     | `/video/iso`                 | Returns `{"iso": 400}`                                            |
| **Set ISO**       | `PUT`     | `/video/iso`                 | Body: `{"iso": 800}` (Use `/video/supportedISOs` for valid list)  |
| **White Balance** | `GET/PUT` | `/video/whiteBalance`        | Body: `{"whiteBalance": 5600}` (Kelvin)                           |
| **Auto WB**       | `PUT`     | `/video/whiteBalance/doAuto` | Triggers Auto White Balance calculation                           |
| **ND Filter**     | `GET/PUT` | `/video/ndFilter`            | Body: `{"stop": 2.0}` (Valid stops: 0.0, 2.0, 4.0, 6.0 typically) |

#### **2.3. Color Correction**

Direct control over the camera's internal color processing (similar to CCU).

- **Endpoints:** `/colorCorrection/lift`, `/colorCorrection/gamma`, `/colorCorrection/gain`
- **Body Example (Lift):**

```json
{
  "red": -0.1,
  "green": -0.1,
  "blue": -0.1,
  "luma": -0.1
}
```

---

### **3. Production Workflow API (Media & Metadata)**

These functions are essential for the "Remote Assistant" aspect of your app, handling recording, metadata, and storage.

#### **3.1. Transport Control**

- **Status:** `GET /transports/0/record` → `{"recording": true}`
- **Timecode:** `GET /transports/0/timecode` → `{"display": "01:00:00:00"}`
- **Action:**
- **Start:** `POST /transports/0/record` with body `{"clipName": "Scene_1"}` (Optional name).
- **Stop:** `POST /transports/0/stop`.

#### **3.2. Smart Slate (Metadata)**

Manage metadata for the _next_ clip to be recorded.

- **Endpoint:** `/slates/nextClip`
- **Method:** `GET` (Read current), `PUT` (Update)
- **Body (Update):**

```json
{
  "clip": {
    "scene": "1A",
    "take": 2, // Increment this via a "+1" button in your app
    "goodTake": true, // Tags clip as "Good" in metadata
    "shotType": "WS" // Options: WS, MS, MCU, CU, BCU, ECU
  }
}
```

#### **3.3. Media Management**

- **Check Storage:** `GET /media/workingset`
- **Response:** Returns array including `remainingRecordTime` (seconds) and `remainingSpace` (bytes). **Crucial** for "Card Full" warnings.

- **Format Card:**

1. `GET /media/devices/{name}/doformat` (Get protection key).
2. `PUT /media/devices/{name}/doformat` (Send key + filesystem + volume name).

---

### **4. System & Monitoring API**

Tools to assist the camera operator and monitor system health.

#### **4.1. Monitoring Overlays**

Control what appears on the camera's LCD/HDMI out.

- **Focus Peaking:** `PUT /monitoring/{displayName}/focusAssist`
- Body: `{"enabled": true, "mode": "Peak", "color": "Red"}`

- **Zebra:** `PUT /monitoring/{displayName}/zebra` → `{"enabled": true}`
- **Frame Guides:** `PUT /monitoring/{displayName}/frameGuide` → `{"enabled": true}`
- _Note:_ Get valid `{displayName}` (e.g., "LCD") via `GET /monitoring/display`.

#### **4.2. Audio Control**

- **Levels (VU):** `GET /audio/channel/{index}/level` → `{"normalised": 0.8, "gain": -6.0}`.
- **Input Source:** `PUT /audio/channel/{index}/input` → `{"input": "Mic"}` (or "Line").
- **Phantom Power:** `PUT /audio/channel/{index}/phantomPower` → `{"enabled": true}`.

#### **4.3. System Format**

- **Get Format:** `GET /system/format`
- Returns Codec (e.g., "Blackmagic RAW"), Resolution (`6144x3456`), and Frame Rate (`24.00`).

---

### **5. Real-Time Notification API (WebSocket)**

Use this for high-performance UI updates (Focus wheels, VU meters, Tally) instead of polling.

- **URL:** `ws://<camera-ip>/control/api/v1/notification`

#### **5.1. Connection Flow**

1. **Connect:** Open WebSocket.
2. **Handshake:** Receive `{"type": "event", "data": {"action": "websocketOpened"}}`.
3. **Subscribe:** Send a JSON message specifying which REST paths to watch.

#### **5.2. Subscription Command**

```json
{
  "action": "subscribe",
  "properties": [
    "/lens/focus",
    "/lens/iris",
    "/video/iso",
    "/video/shutter",
    "/transports/0/record",
    "/audio/channel/0/level",
    "/media/workingset"
  ]
}
```

#### **5.3. Event Message Structure**

When a setting changes, the camera sends:

```json
{
  "type": "event",
  "data": {
    "action": "propertyValueChanged",
    "property": "/lens/focus",
    "value": {
      "normalised": 0.65
    }
  }
}
```

- **Handling:** Parse `data.property` to identify _what_ changed, and apply `data.value` to your UI component immediately.

---

### **6. App Architecture & Best Practices**

- **Hybrid Approach:** Use **REST (GET/PUT)** for initial setup and user actions (button clicks), and **WebSocket** for listening to state changes. This ensures your UI never falls out of sync if the camera is adjusted physically.
- **Error Handling:**
- **404:** Feature not supported (e.g., ND filter on a camera without one). Hide this UI element.
- **400:** Invalid value. Revert UI to the last known good value.

- **Discovery:** Use **mDNS** (Service type `_http._tcp.`) to auto-discover cameras on the LAN instead of asking users to type IP addresses. Look for devices named `*.local` (e.g., `ursa-broadcast-g2.local`).
