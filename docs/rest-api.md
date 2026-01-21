Here is the **Master Developer Documentation** for your Blackmagic Camera Control App. This version unifies the previous structures and integrates all critical "missing" professional features (Playback, Streaming, Presets, Discovery) into a single, logical reference.

### **1. General Configuration & Discovery**

- **Protocol:** HTTP / REST

- **Format:** JSON

- **Base URL:** `https://<camera-ip-address>/control/api/v1`

- **Network Discovery (mDNS):**
- **Service Type:** `_http._tcp.` or `_blackmagic._tcp.`
- **Domain:** `local.`
- **Logic:** Scan for services, then verify by requesting `GET /system/product`. Use the returned `deviceName` for UI labels, not the hostname.

- **Prerequisites:** Enable "Web media manager" in Camera Setup > Network Access. Connection requires HTTPS (accept self-signed certs).

---

### **2. Camera Control API (Optics & Image)**

_Physical manipulation of the lens and sensor._

#### **2.1. Lens Control**

| Feature       | Method | Endpoint      | Payload / Description                                  |
| ------------- | ------ | ------------- | ------------------------------------------------------ |
| **Get Focus** | `GET`  | `/lens/focus` | Returns `{"normalised": 0.5}` (0.0=Near, 1.0=Infinity) |

|
| **Set Focus** | `PUT` | `/lens/focus` | Body: `{"normalised": 0.6}` (Manual focus)

|
| **Trigger AF** | `PUT` | `/lens/focus/doAutoFocus` | Body: `{"position": {"x": 0.5, "y": 0.5}}` (Center ROI)

|
| **Aperture** | `GET` | `/lens/iris` | Returns `{"apertureStop": 5.6, "normalised": 0.4}`

|
| **Set Aperture** | `PUT` | `/lens/iris` | Body: `{"apertureStop": 4.0}` OR `{"normalised": 0.5}`

|
| **Zoom** | `PUT` | `/lens/zoom` | Body: `{"focalLength": 50}` (mm) or `{"normalised": 0.5}`

|
| **OIS** | `PUT` | `/lens/opticalImageStabilization` | Body: `{"enabled": true}`

|

#### **2.2. Exposure & Sensor**

| Feature     | Method | Endpoint         | Payload / Description                                 |
| ----------- | ------ | ---------------- | ----------------------------------------------------- |
| **Shutter** | `GET`  | `/video/shutter` | Returns `{"shutterSpeed": 50, "shutterAngle": 180.0}` |

|
| **Set Shutter** | `PUT` | `/video/shutter` | Body: `{"shutterSpeed": 100}` OR `{"shutterAngle": 172.8}`

|
| **ISO** | `GET` | `/video/iso` | Returns `{"iso": 400}`

|
| **Set ISO** | `PUT` | `/video/iso` | Body: `{"iso": 800}`

|
| **White Balance** | `PUT` | `/video/whiteBalance` | Body: `{"whiteBalance": 5600}` (Kelvin)

|
| **Auto WB** | `PUT` | `/video/whiteBalance/doAuto` | Triggers Auto WB calculation

|
| **ND Filter** | `PUT` | `/video/ndFilter` | Body: `{"stop": 2.0}` (Stops: 0.0, 2.0, 4.0, 6.0)

|
| **Auto Exposure** | `PUT` | `/video/autoExposure` | Body: `{"mode": "Continuous"}` (Off, Continuous, OneShot)

|

#### **2.3. Color Correction (CCU)**

_Direct control over internal color processing._

- **Endpoints:** `/colorCorrection/lift`, `/colorCorrection/gamma`, `/colorCorrection/gain`, `/colorCorrection/offset`, `/colorCorrection/contrast`

- **Body Example (Lift):** `{"red": -0.05, "green": -0.05, "blue": -0.05, "luma": -0.05}`

---

### **3. Production Workflow API (Media & Transport)**

_Managing the "Action", recording, and reviewing footage._

#### **3.1. Transport (Recording)**

- **Status:** `GET /transports/0/record` → `{"recording": true}`

- **Timecode:** `GET /transports/0/timecode` → `{"display": "01:20:10:05"}`

- **Start Rec:** `POST /transports/0/record` (Body: `{"clipName": "Scene_1_Take_1"}`)

- **Stop Rec:** `POST /transports/0/stop`

#### **3.2. Playback & Review (Missing in previous drafts)**

- **List Clips:** `GET /clips` (Returns array of all clips on card)

- **Timeline:** `GET /timelines/0` (Current playback timeline)

- **Start Play:** `POST /transports/0/play`

- **Transport Control (Scrub):** `PUT /transports/0/playback`
- Body: `{"type": "Shuttle", "speed": 2.0}` (Fast Forward) or `{"type": "Jog", "position": 1500}` (Jump to frame).

- **Current Clip:** `GET /transports/0/clipIndex` (Which clip index is playing)

#### **3.3. Smart Slate (Metadata)**

- **Endpoint:** `/slates/nextClip`

- **Update Body:**

```json
{
  "clip": {
    "scene": "1A",
    "take": 3,
    "goodTake": true, // "Circle" the take
    "shotType": "CU" // WS, MS, MCU, CU, etc.
  }
}
```

#### **3.4. Media Management**

- **Storage Check:** `GET /media/workingset`
- Response includes `remainingRecordTime` (seconds) and `remainingSpace` (bytes).

- **Format Card:**

1.  `GET /media/devices/{name}/doformat` → Returns `key`.

2.  `PUT /media/devices/{name}/doformat` → Body: `{"key": "...", "filesystem": "ExFAT", "volume": "Cam_A"}`.

---

### **4. System & Monitoring API**

_Tools for the Operator and System Health._

#### **4.1. Monitoring Overlays (HUD)**

Requires `{displayName}` (e.g., "LCD", "HDMI") from `GET /monitoring/display`.

- **Focus Peaking:** `PUT /monitoring/{displayName}/focusAssist`
- Body: `{"enabled": true, "mode": "Peak", "color": "Red"}`

- **Zebra:** `PUT /monitoring/{displayName}/zebra` → `{"enabled": true}`

- **False Color:** `PUT /monitoring/{displayName}/falseColor` → `{"enabled": true}`

- **Display LUT:** `PUT /monitoring/{displayName}/displayLUT` → `{"enabled": true}`

- **Frame Guides:** `PUT /monitoring/{displayName}/frameGuide` → `{"enabled": true}`

#### **4.2. Audio Control & Filters**

- **Levels (VU):** `GET /audio/channel/{index}/level`

- **Input Source:** `PUT /audio/channel/{index}/input` → `{"input": "Mic"}` (or "Line")

- **Phantom Power:** `PUT /audio/channel/{index}/phantomPower` → `{"enabled": true}`

- **Low Cut Filter:** `PUT /audio/channel/{index}/lowCutFilter` → `{"enabled": true}`

- **Padding:** `PUT /audio/channel/{index}/padding` → `{"enabled": true}`

---

### **5. Advanced Features**

_Capabilities Discovery, Streaming, and Presets._

#### **5.1. Capabilities Discovery (Dynamic UI)**

_Do not hardcode values; ask the camera what it supports._

- **Supported ISOs:** `GET /video/supportedISOs`

- **Supported Codecs:** `GET /system/supportedCodecFormats`

- **Supported Res/FrameRates:** `GET /system/supportedVideoFormats`

- **Supported ND Stops:** `GET /video/supportedNDFilters`

#### **5.2. Livestreaming Control**

- **Status:** `GET /livestreams/0` (Returns "Streaming", "Idle", "Connecting")

- **Start/Stop:** `PUT /livestreams/0/start` / `stop`

- **Configure Platform:** `PUT /livestreams/0/activePlatform`
- Body: `{"url": "rtmp://...", "key": "...", "quality": "Streaming High"}`

#### **5.3. Presets Management**

- **List Presets:** `GET /presets`

- **Load Preset:** `PUT /presets/active` → Body: `{"preset": "MySetup.cset"}`

- **Save Current State:** `PUT /presets/{presetName}`

---

### **6. Real-Time Notification API (WebSocket)**

- **URL:** `ws://<camera-ip>/control/api/v1/notification`

- **Flow:** Connect -> Handshake -> Subscribe -> Listen.
- **Subscription Payload:**

```json
{
  "action": "subscribe",
  "properties": [
    "/lens/focus",
    "/lens/iris",
    "/video/iso",
    "/video/shutter",
    "/transports/0/record",
    "/transports/0/timecode",
    "/audio/channel/0/level",
    "/media/workingset"
  ]
}
```

- **Event Handling:** Listen for `propertyValueChanged` events and update UI immediately.
