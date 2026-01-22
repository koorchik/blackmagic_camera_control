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

#### **3.1. Transport Control API**

| Feature | Method | Endpoint | Payload / Description |
| --- | --- | --- | --- |
| **Get Transport Info** | `GET` | `/transports/0` | Get device's basic transport status. |
| **Set Transport Info** | `PUT` | `/transports/0` | Set device's basic transport status. |
| **Get Stop Status** | `GET` | `/transports/0/stop` | Determine if transport is stopped. |
| **Stop Transport (Deprecated)** | `PUT` | `/transports/0/stop` | Stop transport. Deprecated, use `POST /transports/0/stop` instead. |
| **Stop Transport** | `POST` | `/transports/0/stop` | Stop transport. |
| **Get Play Status** | `GET` | `/transports/0/play` | Determine if transport is playing. |
| **Play Transport (Deprecated)** | `PUT` | `/transports/0/play` | Start playing on transport. Deprecated, use `POST /transports/0/play` instead. |
| **Play Transport** | `POST` | `/transports/0/play` | Start playing on transport. |
| **Get Playback State** | `GET` | `/transports/0/playback` | Get playback state. |
| **Set Playback State** | `PUT` | `/transports/0/playback` | Set playback state. |
| **Get Record State** | `GET` | `/transports/0/record` | Get record state. |
| **Set Record State (Deprecated)** | `PUT` | `/transports/0/record` | Set record state. Deprecated, use `POST /transports/0/record` instead. |
| **Start Recording** | `POST` | `/transports/0/record` | Start recording. |
| **Get Clip Index** | `GET` | `/transports/0/clipIndex` | Get the clip index of the currently playing clip on the timeline. |
| **Get Timecode** | `GET` | `/transports/0/timecode` | Get device timecode. |
| **Get Clip by Device and Path**| `GET` | `/cloud/clips/{deviceName}/{path}` | Retrieve specific clip data by device and path. |

#### **3.2.2. Timeline Control API**

| Feature | Method | Endpoint | Payload / Description |
| --- | --- | --- | --- |
| **Get Playback Timeline** | `GET` | `/timelines/0` | Get the playback timeline. |
| **Clear Playback Timeline (Deprecated)** | `DELETE` | `/timelines/0` | Clear the current playback timeline. Deprecated, prefer to use `POST /timelines/0/clear` instead. |
| **Add Clip to Timeline** | `POST` | `/timelines/0` | Add a clip to the timeline. |
| **Add Clip to Timeline (Deprecated)** | `POST` | `/timelines/0/add` | Add a clip to the end of the timeline. Deprecated, use `POST /timelines/0` to add clips within the timeline. |
| **Clear Playback Timeline** | `POST` | `/timelines/0/clear` | Clear the playback timeline. |
| **Delete Clip from Timeline** | `DELETE` | `/timelines/0/clips/{timelineClipIndex}` | Remove the specified clip from the timeline. |

#### **3.3. Slate Control API**

| Feature | Method | Endpoint | Payload / Description |
| --- | --- | --- | --- |
| **Get Next Clip Slate** | `GET` | `/slates/nextClip` | Retrieve the digital slate for the next clip. |
| **Update Next Clip Slate** | `PUT` | `/slates/nextClip` | Update the slate data for the next clip. |
| **Reset Next Clip Project Data** | `POST` | `/slates/nextClip/resetProjectData` | Reset the project data for the next clip's slate. |
| **Reset Clip Project Data** | `POST` | `/slates/clips/{deviceName}/{path}/resetProjectData` | Reset the project data for the next clip's slate. |
| **Reset Next Clip Lens Data** | `POST` | `/slates/nextClip/resetLensData` | Reset the lens data for the next clip's slate. |
| **Reset Clip Lens Data** | `POST` | `/slates/clips/{deviceName}/{path}/resetLensData` | Reset the lens data for the next clip's slate. |
| **Get Clip Slate Data** | `GET` | `/slates/clips/{deviceName}/{path}` | Retrieve slate data for a specific clip. |
| **Update Clip Slate Data** | `PUT` | `/slates/clips/{deviceName}/{path}` | Update the slate data for a specific clip. |
#### **3.4. Media Control API**

| Feature | Method | Endpoint | Payload / Description |
| --- | --- | --- | --- |
| **Get Media Workingset** | `GET` | `/media/workingset` | Get the list of media devices currently in the working set. |
| **Get Active Media Device** | `GET` | `/media/active` | Get the currently active media device. |
| **Set Active Media Device** | `PUT` | `/media/active` | Set the currently active media device. |
| **Get Supported Filesystems** | `GET` | `/media/devices/doformatSupportedFilesystems` | Get the list of filesystems available to format a media device. |
| **Get Device Info** | `GET` | `/media/devices/{deviceName}` | Get information about a requested device. |
| **Get Format Key** | `GET` | `/media/devices/{deviceName}/doformat` | Get a format key, used to format the device with a PUT request. |
| **Format Device** | `PUT` | `/media/devices/{deviceName}/doformat` | Perform a format of the specified media device. |

---

### **4. System & Monitoring API**

_Tools for the Operator and System Health._

#### **4.0. Event Control API**
| Feature | Method | Endpoint | Payload / Description |
| --- | --- | --- | --- |
| **Get Events List** | `GET` | `/event/list` | Get the list of events that can be subscribed to using the websocket API. |

#### **4.1. Monitoring Overlays (HUD)**

Requires `{displayName}` (e.g., "LCD", "HDMI") from `GET /monitoring/display`.

| Feature | Method | Endpoint | Payload / Description |
| --- | --- | --- | --- |
| **Get Display Names** | `GET` | `/monitoring/display` | Retrieve a list of all display names. |
| **Get Clean Feed** | `GET` | `/monitoring/{displayName}/cleanFeed` | Get the clean feed enable state for a specific display. |
| **Set Clean Feed** | `PUT` | `/monitoring/{displayName}/cleanFeed` | Set the clean feed enable state for a specific display. Body: `{"enabled": true}` |
| **Get Display LUT** | `GET` | `/monitoring/{displayName}/displayLUT` | Get the display LUT enable state for a specific display. |
| **Set Display LUT** | `PUT` | `/monitoring/{displayName}/displayLUT` | Set the display LUT enable state for a specific display. Body: `{"enabled": true}` |
| **Get Zebra** | `GET` | `/monitoring/{displayName}/zebra` | Get the zebra enable state for a specific display. |
| **Set Zebra** | `PUT` | `/monitoring/{displayName}/zebra` | Set the zebra enable state for a specific display. Body: `{"enabled": true}` |
| **Get Focus Assist** | `GET` | `/monitoring/{displayName}/focusAssist` | Get the focus assist enable state for a specific display. |
| **Set Focus Assist** | `PUT` | `/monitoring/{displayName}/focusAssist` | Set the focus assist enable state for a specific display. Body: `{"mode": "Peak", "color": "Red", "intensity": 50}` |
| **Get Global Focus Assist**| `GET` | `/monitoring/focusAssist` | Get the focus assist settings. |
| **Set Global Focus Assist**| `PUT` | `/monitoring/focusAssist` | Set the focus assist settings. Body: `{"mode": "Peak", "color": "Red", "intensity": 50}` |
| **Get Frame Guide** | `GET` | `/monitoring/{displayName}/frameGuide` | Get the frame guide enable state for a specific display. |
| **Set Frame Guide** | `PUT` | `/monitoring/{displayName}/frameGuide` | Set the frame guide enable state for a specific display. Body: `{"enabled": true}` |
| **Get Frame Guide Ratio**| `GET` | `/monitoring/frameGuideRatio` | Get the current frame guide ratio. |
| **Set Frame Guide Ratio**| `PUT` | `/monitoring/frameGuideRatio` | Set the frame guide ratio. Body: `{"ratio": "1.85:1"}` |
| **Get Frame Guide Ratio Presets** | `GET` | `/monitoring/frameGuideRatio/presets` | Get the presets for frame guide ratios. |
| **Get Frame Grids** | `GET` | `/monitoring/{displayName}/frameGrids` | Get the frame grids enable state for a specific display. |
| **Set Frame Grids** | `PUT` | `/monitoring/{displayName}/frameGrids` | Set the frame grids enable state for a specific display. Body: `{"enabled": true}` |
| **Get Global Frame Grids** | `GET` | `/monitoring/frameGrids` | Get the global frame grids settings. |
| **Set Global Frame Grids** | `PUT` | `/monitoring/frameGrids` | Set the global frame grids settings. Body: `{"frameGrids": ["Thirds", "Crosshair"]}` |
| **Get Safe Area** | `GET` | `/monitoring/{displayName}/safeArea` | Get the safe area enable state for a specific display. |
| **Set Safe Area** | `PUT` | `/monitoring/{displayName}/safeArea` | Set the safe area enable state for a specific display. Body: `{"enabled": true}` |
| **Get Safe Area Percent**| `GET` | `/monitoring/safeAreaPercent` | Get the current safe area percentage. |
| **Set Safe Area Percent**| `PUT` | `/monitoring/safeAreaPercent` | Set the safe area percentage. Body: `{"percent": 80}` |
| **Get False Color** | `GET` | `/monitoring/{displayName}/falseColor` | Get the false color enable state for a specific display. |
| **Set False Color** | `PUT` | `/monitoring/{displayName}/falseColor` | Set the false color enable state for a specific display. Body: `{"enabled": true}` |

#### **4.2. Audio Control & Filters**

- **Levels (VU):** `GET /audio/channel/{index}/level`

- **Input Source:** `PUT /audio/channel/{index}/input` → `{"input": "Mic"}` (or "Line")

- **Phantom Power:** `PUT /audio/channel/{index}/phantomPower` → `{"enabled": true}`

- **Low Cut Filter:** `PUT /audio/channel/{index}/lowCutFilter` → `{"enabled": true}`

- **Padding:** `PUT /audio/channel/{index}/padding` → `{"enabled": true}`

#### **4.3. System Control API**

| Feature | Method | Endpoint | Payload / Description |
| --- | --- | --- | --- |
| **Get System Info** | `GET` | `/system` | Get device system information. |
| **Get Product Info** | `GET` | `/system/product` | Get device product information. |
| **Get Supported Codec Formats** | `GET` | `/system/supportedCodecFormats` | Get the list of supported codecs. |
| **Get Codec Format** | `GET` | `/system/codecFormat` | Get the currently selected codec. |
| **Set Codec Format** | `PUT` | `/system/codecFormat` | Update the system codec. |
| **Get Video Format** | `GET` | `/system/videoFormat` | Get the currently selected video format. |
| **Set Video Format** | `PUT` | `/system/videoFormat` | Set the system video format. |
| **Get Supported Video Formats** | `GET` | `/system/supportedVideoFormats` | Get the list of supported video formats for the current system state. |
| **Get Supported Formats** | `GET` | `/system/supportedFormats` | Get supported formats. |
| **Get Format** | `GET` | `/system/format` | Get current format. |
| **Set Format** | `PUT` | `/system/format` | Set the format. |
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

| Feature                             | Method   | Endpoint                                       | Payload / Description                                                                                                                                                                                                                                                                                                                                                                                          |
| ----------------------------------- | -------- | ---------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Get Status**                      | `GET`    | `/livestreams/0`                               | Returns `{"status": "Idle", "bitrate": 0, "effectiveVideoFormat": "1080p25", "duration": 0, "cache": 0}`. Status can be: `Idle`, `Connecting`, `Streaming`, `Flushing`, `Interrupted`.                                                                                                                                                                                                                         |
| **Get Start Status**                | `GET`    | `/livestreams/0/start`                         | Returns `{"active": true}` when the livestream is active.                                                                                                                                                                                                                                                                                                                                                      |
| **Start Livestream**                | `PUT`    | `/livestreams/0/start`                         | Starts the livestream.                                                                                                                                                                                                                                                                                                                                                                                         |
| **Get Stop Status**                 | `GET`    | `/livestreams/0/stop`                          | Returns `{"active": true}` when the livestream is inactive.                                                                                                                                                                                                                                                                                                                                                    |
| **Stop Livestream**                 | `PUT`    | `/livestreams/0/stop`                          | Stops the livestream.                                                                                                                                                                                                                                                                                                                                                                                          |
| **Get Active Platform**             | `GET`    | `/livestreams/0/activePlatform`                | Returns the currently selected platform configuration. Example: `{"platform": "Facebook", "server": "Default", "key": "...", "passphrase": "...", "quality": "Streaming High", "url": "rtmp://..."}`                                                                                                                                                                                                          |
| **Set Active Platform**             | `PUT`    | `/livestreams/0/activePlatform`                | Sets the currently selected platform configuration.                                                                                                                                                                                                                                                                                                                                                            |
| **Get Available Platforms**         | `GET`    | `/livestreams/platforms`                       | Returns a list of available platforms. Example: `["Facebook", "YouTube", "Twitch"]`                                                                                                                                                                                                                                                                                                                             |
| **Get Platform Configuration**      | `GET`    | `/livestreams/platforms/{platformName}`        | Returns the service configuration for a specific platform.                                                                                                                                                                                                                                                                                                                                                     |
| **Get Custom Platform List**        | `GET`    | `/livestreams/customPlatforms`                 | Get a list of custom platform files.                                                                                                                                                                                                                                                                                                                                                                           |
| **Delete Custom Platforms**         | `DELETE` | `/livestreams/customPlatforms`                 | Remove all custom configuration files.                                                                                                                                                                                                                                                                                                                                                                         |
| **Get Custom Platform File**        | `GET`    | `/livestreams/customPlatforms/{filename}`      | Get a custom platform file.                                                                                                                                                                                                                                                                                                                                                                                    |
| **Create/Update Custom Platform**   | `PUT`    | `/livestreams/customPlatforms/{filename}`      | Update a custom platform file if it exists, if not, create a new file with the given file name.                                                                                                                                                                                                                                                                                                                |
| **Delete Custom Platform**          | `DELETE` | `/livestreams/customPlatforms/{filename}`      | Remove the given custom platform file.                                                                                                                                                                                                                                                                                                                                                                         |

#### **5.3. Preset Control API**

| Feature | Method | Endpoint | Payload / Description |
| --- | --- | --- | --- |
| **List Presets** | `GET` | `/presets` | Get the list of the presets on the camera. |
| **Send Preset File** | `POST` | `/presets` | Send a preset file to the camera. |
| **Get Active Preset** | `GET` | `/presets/active` | Get the currently active preset on the camera. |
| **Set Active Preset** | `PUT` | `/presets/active` | Set the active preset on the camera. |
| **Download Preset File** | `GET` | `/presets/{presetName}` | Download the preset file. |
| **Save Current State as Preset** | `PUT` | `/presets/{presetName}` | Save current camera state as a preset. |
| **Delete Preset** | `DELETE` | `/presets/{presetName}` | Delete a preset from the camera. |

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
