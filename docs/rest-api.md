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

#### **2.1. Lens Control API**

| Feature | Method | Endpoint | Payload / Description |
| --- | --- | --- | --- |
| **Get Iris** | `GET` | `/lens/iris` | Get lens' aperture. |
| **Set Iris** | `PUT` | `/lens/iris` | Set lens' aperture. Body: `{"apertureStop": 4.0, "normalised": 0.5, "apertureNumber": 4, "adjustmentStep": 1}` |
| **Get Zoom** | `GET` | `/lens/zoom` | Get lens' zoom. |
| **Set Zoom** | `PUT` | `/lens/zoom` | Set lens' zoom. Body: `{"focalLength": 50, "normalised": 0.5, "adjustmentFocalLength": 5, "adjustmentNormalised": 0.1}` |
| **Get Focus** | `GET` | `/lens/focus` | Get lens' focus. |
| **Set Focus** | `PUT` | `/lens/focus` | Set lens' focus. Body: `{"normalised": 0.5, "focusDistance": 2000}` |
| **Perform Autofocus** | `PUT` | `/lens/focus/doAutoFocus` | Perform auto focus. Body: `{"position": {"x": 0.5, "y": 0.5}}` |
| **Get Optical Image Stabilization Status** | `GET` | `/lens/opticalImageStabilization` | Get optical image stabilization status. |
| **Set Optical Image Stabilization** | `PUT` | `/lens/opticalImageStabilization` | Enable or disable optical image stabilization. Body: `{"enabled": true}` |
| **Get Iris Description** | `GET` | `/lens/iris/description` | Get detailed description of lens' iris capabilities. |
| **Get Zoom Description** | `GET` | `/lens/zoom/description` | Get detailed description of lens' zoom capabilities. |
| **Get Focus Description** | `GET` | `/lens/focus/description` | Get detailed description of lens' focus capabilities. |

#### **2.2. Video Control API**

| Feature | Method | Endpoint | Payload / Description |
| --- | --- | --- | --- |
| **Get ISO** | `GET` | `/video/iso` | Get current ISO. |
| **Set ISO** | `PUT` | `/video/iso` | Set current ISO. Body: `{"iso": 800}` |
| **Get Supported ISOs** | `GET` | `/video/supportedISOs` | Get the list of supported ISO settings. |
| **Get Gain** | `GET` | `/video/gain` | Get current gain value in decibels. |
| **Set Gain** | `PUT` | `/video/gain` | Set current gain value. Body: `{"gain": 0}` |
| **Get Supported Gains** | `GET` | `/video/supportedGains` | Get the list of supported gain settings in decibels. |
| **Get White Balance** | `GET` | `/video/whiteBalance` | Get current white balance. |
| **Set White Balance** | `PUT` | `/video/whiteBalance` | Set current white balance. Body: `{"whiteBalance": 5600}` |
| **Get White Balance Description** | `GET` | `/video/whiteBalance/description` | Get white balance range. |
| **Set White Balance Automatically** | `PUT` | `/video/whiteBalance/doAuto` | Set current white balance automatically. |
| **Get White Balance Tint** | `GET` | `/video/whiteBalanceTint` | Get white balance tint. |
| **Set White Balance Tint** | `PUT` | `/video/whiteBalanceTint` | Set white balance tint. Body: `{"whiteBalanceTint": 0}` |
| **Get White Balance Tint Description** | `GET` | `/video/whiteBalanceTint/description` | Get white balance tint range. |
| **Get ND Filter** | `GET` | `/video/ndFilter` | Get ND filter stop. |
| **Set ND Filter** | `PUT` | `/video/ndFilter` | Set ND filter stop. Body: `{"stop": 2.0}` |
| **Get Supported ND Filters** | `GET` | `/video/supportedNDFilters` | Get the list of available ND filter stops. |
| **Get Supported ND Filter Display Modes** | `GET` | `/video/supportedNDFilterDisplayModes` | Get the list of supported ND filter display modes. |
| **Get ND Filter Display Mode** | `GET` | `/video/ndFilter/displayMode` | Get ND filter display mode on the camera. |
| **Set ND Filter Display Mode** | `PUT` | `/video/ndFilter/displayMode` | Set ND filter display mode on the camera. Body: `{"displayMode": "Stop"}` |
| **Get ND Filter Selectable** | `GET` | `/video/ndFilterSelectable` | Check if ND filter adjustments are selectable via a slider. |
| **Get Shutter** | `GET` | `/video/shutter` | Get current shutter. |
| **Set Shutter** | `PUT` | `/video/shutter` | Set current shutter. Body: `{"shutterSpeed": 100}` or `{"shutterAngle": 172.8}` |
| **Get Shutter Measurement Mode** | `GET` | `/video/shutter/measurement` | Get the current shutter measurement mode. |
| **Set Shutter Measurement Mode** | `PUT` | `/video/shutter/measurement` | Set the shutter measurement mode. Body: `{"measurement": "ShutterSpeed"}` |
| **Get Supported Shutters** | `GET` | `/video/supportedShutters` | Get supported shutter settings based on current camera configuration. |
| **Get Flicker-Free Shutters** | `GET` | `/video/flickerFreeShutters` | Get flicker-free shutter settings based on current camera configuration. |
| **Get Auto Exposure** | `GET` | `/video/autoExposure` | Get current auto exposure mode. |
| **Set Auto Exposure** | `PUT` | `/video/autoExposure` | Set auto exposure. Body: `{"mode": "Continuous"}` |
| **Get Detail Sharpening** | `GET` | `/video/detailSharpening` | Get the current state of detail sharpening. |
| **Set Detail Sharpening** | `PUT` | `/video/detailSharpening` | Enable or disable detail sharpening. Body: `{"enabled": true}` |
| **Get Detail Sharpening Level** | `GET` | `/video/detailSharpeningLevel` | Get the current detail sharpening level. |
| **Set Detail Sharpening Level** | `PUT` | `/video/detailSharpeningLevel` | Set the detail sharpening level. Body: `{"level": "Medium"}` |

#### **2.2.1. Camera Control API**

| Feature | Method | Endpoint | Payload / Description |
| --- | --- | --- | --- |
| **Get Color Bars Status** | `GET` | `/camera/colorBars` | Get the status of color bars display. |
| **Set Color Bars Status** | `PUT` | `/camera/colorBars` | Set the status of color bars display. Body: `{"enabled": true}` |
| **Get Program Feed Display Status** | `GET` | `/camera/programFeedDisplay` | Get the status of program feed display. |
| **Set Program Feed Display Status** | `PUT` | `/camera/programFeedDisplay` | Set the status of program feed display. Body: `{"enabled": true}` |
| **Get Tally Status** | `GET` | `/camera/tallyStatus` | Get the tally status of the camera. |
| **Get Power Status** | `GET` | `/camera/power` | Get the power status of the camera. |
| **Get Power Display Mode** | `GET` | `/camera/power/displayMode` | Get the power display mode of the camera. |
| **Set Power Display Mode** | `PUT` | `/camera/power/displayMode` | Set the power display mode of the camera. Body: `{"mode": "Percentage"}` |
| **Get Timing Reference Lock Status** | `GET` | `/camera/timingReferenceLock` | Get the timing reference lock status. |

#### **2.2.2. Immersive Control API**

| Feature | Method | Endpoint | Payload / Description |
| --- | --- | --- | --- |
| **Get Eye View** | `GET` | `/immersive/display/{displayName}/eye` | Get the current eye view for a specific display. |
| **Set Eye View** | `PUT` | `/immersive/display/{displayName}/eye` | Set the eye view for a specific display. Body: `{"eye": "Left"}` |

#### **2.3. Color Correction Control API**

| Feature | Method | Endpoint | Payload / Description |
| --- | --- | --- | --- |
| **Get Lift** | `GET` | `/colorCorrection/lift` | Get color correction lift. |
| **Set Lift** | `PUT` | `/colorCorrection/lift` | Set color correction lift. Body: `{"red": -0.05, "green": -0.05, "blue": -0.05, "luma": -0.05}` |
| **Get Gamma** | `GET` | `/colorCorrection/gamma` | Get color correction gamma. |
| **Set Gamma** | `PUT` | `/colorCorrection/gamma` | Set color correction gamma. Body: `{"red": 0.0, "green": 0.0, "blue": 0.0, "luma": 0.0}` |
| **Get Gain** | `GET` | `/colorCorrection/gain` | Get color correction gain. |
| **Set Gain** | `PUT` | `/colorCorrection/gain` | Set color correction gain. Body: `{"red": 0.0, "green": 0.0, "blue": 0.0, "luma": 0.0}` |
| **Get Offset** | `GET` | `/colorCorrection/offset` | Get color correction offset. |
| **Set Offset** | `PUT` | `/colorCorrection/offset` | Set color correction offset. Body: `{"red": 0.0, "green": 0.0, "blue": 0.0, "luma": 0.0}` |
| **Get Contrast** | `GET` | `/colorCorrection/contrast` | Get color correction contrast. |
| **Set Contrast** | `PUT` | `/colorCorrection/contrast` | Set color correction contrast. Body: `{"pivot": 0.5, "adjust": 1.0}` |
| **Get Color Properties** | `GET` | `/colorCorrection/color` | Get color correction color properties. |
| **Set Color Properties** | `PUT` | `/colorCorrection/color` | Set color correction color properties. Body: `{"hue": 0.0, "saturation": 1.0}` |
| **Get Luma Contribution** | `GET` | `/colorCorrection/lumaContribution` | Get color correction luma contribution. |
| **Set Luma Contribution** | `PUT` | `/colorCorrection/lumaContribution` | Set color correction luma contribution. Body: `{"lumaContribution": 1.0}` |

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

#### **4.2. Audio Control API**

| Feature | Method | Endpoint | Payload / Description |
| --- | --- | --- | --- |
| **Get Audio Channels** | `GET` | `/audio/channels` | Get the total number of audio channels available. |
| **Get Supported Inputs** | `GET` | `/audio/supportedInputs` | Get the list of supported audio inputs. |
| **Get Channel Input** | `GET` | `/audio/channel/{channelIndex}/input` | Get the audio input (source and type) for the selected channel. |
| **Set Channel Input** | `PUT` | `/audio/channel/{channelIndex}/input` | Set the audio input for the selected channel. Body: `{"input": "Mic"}` |
| **Get Channel Input Description** | `GET` | `/audio/channel/{channelIndex}/input/description` | Get the description of the current input of the selected channel. |
| **Get Channel Supported Inputs** | `GET` | `/audio/channel/{channelIndex}/supportedInputs` | Get the list of supported inputs and their availability to switch to for the selected channel. |
| **Get Channel Level** | `GET` | `/audio/channel/{channelIndex}/level` | Get the audio input level for the selected channel. |
| **Set Channel Level** | `PUT` | `/audio/channel/{channelIndex}/level` | Set the audio input level for the selected channel. Body: `{"gain": 0.0, "normalised": 0.5}` |
| **Get Channel Phantom Power** | `GET` | `/audio/channel/{channelIndex}/phantomPower` | Get the audio input phantom power status for the selected channel. |
| **Set Channel Phantom Power** | `PUT` | `/audio/channel/{channelIndex}/phantomPower` | Set the audio phantom power for the selected channel. Body: `{"enabled": true}` |
| **Get Channel Padding** | `GET` | `/audio/channel/{channelIndex}/padding` | Get the audio input padding status for the selected channel. |
| **Set Channel Padding** | `PUT` | `/audio/channel/{channelIndex}/padding` | Set the audio input padding for the selected channel. Body: `{"enabled": true}` |
| **Get Channel Low Cut Filter** | `GET` | `/audio/channel/{channelIndex}/lowCutFilter` | Get the audio input low cut filter status for the selected channel. |
| **Set Channel Low Cut Filter** | `PUT` | `/audio/channel/{channelIndex}/lowCutFilter` | Set the audio input low cut filter for the selected channel. Body: `{"enabled": true}` |
| **Get Channel Availability** | `GET` | `/audio/channel/{channelIndex}/available` | Get the audio input's current availability for the selected channel. |

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

Service that notifies subscribers of device state changes.

| Feature | Method | Endpoint | Payload / Description |
| --- | --- | --- | --- |
| **Subscribe** | `WEBSOCKET` | `ws://<camera-ip>/control/api/v1/notification` | Subscribe to messages from the server/device. On websocket opened, send `{"action": "subscribe", "properties": ["/property/to/subscribe"]}`. Response contains `action` ("subscribe", "unsubscribe", "listSubscriptions", "listProperties", "websocketOpened"), `properties` (array of device properties), `values` (object of property names and values), and `success` (boolean). |
| **Event Message** | `WEBSOCKET` | N/A | Listen for `propertyValueChanged` events. The event message will have `data.action` as "propertyValueChanged", `data.property` as the property name, and `data.value` as the new value. |
| **Device Properties** | `WEBSOCKET` | N/A | The value JSON returned via the eventResponse when device properties change. Properties include `/media/workingset`, `/media/active`, `/system`, `/system/codecFormat`, `/system/videoFormat`, `/system/format`, `/system/supportedFormats`, `/timelines/0`, `/transports/0`, `/transports/0/stop`, `/transports/0/play`, `/transports/0/playback`, `/transports/0/record`, `/transports/0/timecode`, `/transports/0/timecode/source`, `/transports/0/clipIndex`, `/slates/nextClip`, `/monitoring/{displayName}/cleanFeed`, `/monitoring/{displayName}/displayLUT`, `/monitoring/{displayName}/zebra`, `/monitoring/{displayName}/focusAssist`, `/monitoring/{displayName}/frameGuide`, `/monitoring/{displayName}/frameGrids`, `/monitoring/{displayName}/safeArea`, `/monitoring/{displayName}/falseColor`, `/monitoring/focusAssist`, `/monitoring/frameGuideRatio`, `/monitoring/frameGrids`, `/monitoring/safeAreaPercent`, `/audio/channel/{channelIndex}/input`, `/audio/channel/{channelIndex}/supportedInputs`, `/audio/channel/{channelIndex}/level`, `/audio/channel/{channelIndex}/phantomPower`, `/audio/channel/{channelIndex}/padding`, `/audio/channel/{channelIndex}/lowCutFilter`, `/audio/channel/{channelIndex}/available`, `/audio/channel/{channelIndex}/input/description`, `/colorCorrection/lift`, `/colorCorrection/gamma`, `/colorCorrection/gain`, `/colorCorrection/offset`, `/colorCorrection/contrast`, `/colorCorrection/color`, `/colorCorrection/lumaContribution`, `/lens/iris`, `/lens/iris/description`, `/lens/focus`, `/lens/focus/description`, `/lens/zoom`, `/lens/zoom/description`, `/presets`, `/presets/active`, `/camera/colorBars`, `/camera/programFeedDisplay`, `/camera/tallyStatus`, `/camera/power`, `/camera/power/displayMode`, `/camera/timingReferenceLock`, `/video/iso`, `/video/supportedISOs`, `/video/gain`, `/video/supportedGains`, `/video/whiteBalance`, `/video/whiteBalance/description`, `/video/whiteBalanceTint`, `/video/whiteBalanceTint/description`, `/video/ndFilter`, `/video/supportedNDFilters`, `/video/ndFilter/displayMode`, `/video/supportedNDFilterDisplayModes`, `/video/ndFilterSelectable`, `/video/shutter`, `/video/shutter/measurement`, `/video/supportedShutters`, `/video/flickerFreeShutters`, `/video/autoExposure`, `/video/detailSharpening`, `/video/detailSharpeningLevel`. |
