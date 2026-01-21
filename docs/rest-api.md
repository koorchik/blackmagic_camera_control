Here is the structured REST API documentation for your Android/Desktop app development, based on the provided Blackmagic Camera API PDF.

### **General Information**

- **Protocol:** HTTP / REST
- **Format:** JSON
- **Base URL:** `https://<camera-ip-address>/control/api/v1`
- _Note:_ You must enable "Web media manager" in the camera's network settings for this to work .

- **Authentication:** Not strictly specified for local control, but ensure the connection uses HTTPS as per the example URLs .

---

### **1. Lens Control (Focus, Aperture, Zoom)**

This is the core functionality you requested.

#### **1.1. Focus Control**

- **Get Current Focus:**
- **GET** `/lens/focus`
- **Response:**

```json
{
  "normalised": 0.5 // Value between 0.0 (near) and 1.0 (infinity)
}
```

- **Set Focus (Manual Focus):**
- **PUT** `/lens/focus`
- **Body:**

```json
{
  "normalised": 0.6 // Set value 0.0 to 1.0
}
```

- **Trigger Autofocus:**
- **PUT** `/lens/focus/doAutoFocus`
- **Body:** (Specify the Region of Interest)

```json
{
  "position": {
    "x": 0.5, // Horizontal center (0.0 - 1.0)
    "y": 0.5 // Vertical center (0.0 - 1.0)
  }
}
```

#### **1.2. Aperture (Iris)**

- **Get Current Aperture:**
- **GET** `/lens/iris`
- **Response:**

```json
{
  "apertureStop": 5.6, // The actual f-stop (e.g., f/5.6)
  "normalised": 0.4, // 0.0 (closed) to 1.0 (open)
  "apertureNumber": 560, // Internal integer representation
  "continuousApertureAutoExposure": false // Is Auto Exposure active?
}
```

- **Set Aperture:**
- **PUT** `/lens/iris`
- **Body:** (Send one of the following)

```json
{
  "apertureStop": 4.0 // Set to f/4.0
}
```

_Or using normalised values:_

```json
{
  "normalised": 0.5 //
}
```

#### **1.3. Zoom Control**

- **Get/Set Zoom:**
- **GET/PUT** `/lens/zoom`
- **Body:** Use `"focalLength"` (mm) or `"normalised"` (0.0-1.0) .

---

### **2. Video & Exposure Control**

Controls for Shutter Speed, ISO, and White Balance.

#### **2.1. Shutter Speed / Angle**

Cameras may operate in Shutter Speed or Shutter Angle mode.

- **Get Current Shutter:**
- **GET** `/video/shutter`
- **Response:**

```json
{
  "shutterSpeed": 50, // 1/50th of a second
  "shutterAngle": 180.0, // 180 degrees
  "continuousShutterAutoExposure": false //
}
```

- **Set Shutter:**
- **PUT** `/video/shutter`
- **Body:**

```json
{
  "shutterSpeed": 100 // Set to 1/100th second
}
```

_Or:_

```json
{
  "shutterAngle": 172.8 //
}
```

#### **2.2. ISO (or Gain)**

- **Get ISO:**
- **GET** `/video/iso`
- **Response:** `{"iso": 400}`

- **Set ISO:**
- **PUT** `/video/iso`
- **Body:** `{"iso": 800}`

- **Get Supported ISOs:**
- **GET** `/video/supportedISOs`
- _Use this to populate a dropdown menu in your app so users select valid values._

#### **2.3. White Balance**

- **Get/Set White Balance:**
- **GET/PUT** `/video/whiteBalance`
- **Body:** `{"whiteBalance": 5600}` (Kelvin) .

- **Trigger Auto White Balance:**
- **PUT** `/video/whiteBalance/doAuto` .

#### **2.4. ND Filter (If supported)**

- **Get/Set ND Filter:**
- **GET/PUT** `/video/ndFilter`
- **Body:** `{"stop": 2.0}` (e.g., 0.0, 2.0, 4.0, 6.0) .

---

### **3. Transport Control (Recording)**

- **Get Recording Status:**
- **GET** `/transports/0/record`
- **Response:** `{"recording": true}` (true = recording, false = stopped) .

- **Start/Stop Recording:**
- **POST** `/transports/0/record`
- **Body:**

```json
{
  "recording": true, // Start recording (deprecated method uses this param)
  // OR strictly for POST use:
  "clipName": "Optional_Clip_Name" //
}
```

- _Note:_ The documentation mentions `POST` to start recording and `POST /transports/0/stop` to stop .

- **Stop Recording:**
- **POST** `/transports/0/stop` .

- **Get Timecode:**
- **GET** `/transports/0/timecode`
- **Response:** `{"display": "00:01:23:10"}` .

---

### **4. System Information**

- **Get Recording Format:**
- **GET** `/system/format`
- **Response:**

```json
{
  "codec": "Blackmagic RAW", //
  "frameRate": "24.00", //
  "recordResolution": {
    "width": 6144,
    "height": 3456 //
  }
}
```

---

### **App Architecture Recommendations**

1. **State Management (Polling vs. WebSocket):**

- **WebSocket:** For the best user experience (especially for manual focus wheels), use the notification service mentioned in the docs.
- **WebSocket URL:** `ws://<camera-ip>/control/api/v1/notification`. You can subscribe to specific events like `/lens/focus` or `/video/iso` to get real-time updates without polling .

2. **Handling 404/400 Errors:**

- **404 Not Found:** Usually means the camera model doesn't support that feature (e.g., trying to control ND filters on a camera that doesn't have them) .
- **400 Bad Request:** You sent an invalid value (e.g., a Shutter Speed that isn't supported) .

Based on the provided documentation, the **Notification Websocket API** allows your application to maintain a persistent connection with the camera to receive real-time updates when settings change (e.g., someone rotates the focus ring manually, or the recording stops). This is far more efficient than constantly polling the REST API.

Here is the detailed description of the Notification API flow and data structures.

### **1. Connection & Handshake**

The WebSocket service is designed to notify subscribers of device state changes.

- **Discovery:** You can use the REST endpoint `GET /event/list` to retrieve the list of events that can be subscribed to via the WebSocket.

- **Connection:** When you open a WebSocket connection to the camera, the server will immediately send a **Websocket Opened Message** to confirm the connection is active.

**Server Greeting (JSON):**

```json
{
  "type": "event",
  "data": {
    "action": "websocketOpened"
  }
}
```

---

### **2. Client Commands (Publishing)**

Once connected, the client (your app) sends messages to the server to manage subscriptions. These are standard JSON objects.

#### **A. Subscribe**

To start receiving updates, you must explicitly subscribe to specific properties (paths).

**Request Structure:**

```json
{
  "action": "subscribe",
  "properties": ["/video/iso", "/lens/focus", "/transports/0/record"]
}
```

- **action:** Must be `"subscribe"`.

- **properties:** An array of strings representing the REST endpoints you want to monitor. You can subscribe to specific paths or use wildcards (though specific paths are recommended for clarity).

#### **B. Other Commands**

- **Unsubscribe:** Stop receiving updates for specific properties. Action: `"unsubscribe"`.

- **List Subscriptions:** Ask the server what you are currently subscribed to. Action: `"listSubscriptions"`.

- **List Properties:** Ask the server what properties are available. Action: `"listProperties"`.

---

### **3. Server Notifications (Events)**

When a subscribed property changes on the camera, the server sends an **Event Message** to the client.

**Event Structure:**

```json
{
  "type": "event",
  "data": {
    "action": "propertyValueChanged",
    "property": "/video/iso",
    "value": {
      "iso": 800
    }
  }
}
```

- **type:** Always `"event"`.

- **data.action:** Always `"propertyValueChanged"`.

- **data.property:** The specific API path that changed (e.g., `/video/iso`).

- **data.value:** The new value object, identical to the JSON body you would get from a standard GET request to that endpoint.

---

### **4. Critical Subscribable Properties**

For your Android/Desktop app goals (Focus, Shutter, Aperture), you should subscribe to the following properties. I have mapped the path to the expected event payload based on the "Device Properties" section of the document.

#### **A. Lens & Focus (The "Main Goal")**

- **Focus:** `/lens/focus`
- **Payload:** `{"normalised": 0.5}`.

- _Use:_ Update your focus slider in real-time if the user adjusts the lens manually.

- **Aperture (Iris):** `/lens/iris`
- **Payload:** `{"apertureStop": 5.6, "normalised": 0.4, ...}`.

- **Zoom:** `/lens/zoom`
- **Payload:** `{"focalLength": 50, "normalised": 0.5}`.

#### **B. Exposure Parameters**

- **Shutter:** `/video/shutter`
- **Payload:** Returns shutter speed or angle depending on camera mode.
- Example: `{"shutterSpeed": 50, "shutterAngle": 180.0, ...}`.

- **ISO:** `/video/iso`
- **Payload:** `{"iso": 800}`.

- **White Balance:** `/video/whiteBalance`
- **Payload:** `{"whiteBalance": 5600}`.

#### **C. Transport (Recording State)**

- **Record Status:** `/transports/0/record`
- **Payload:** `{"recording": true}` or `{"recording": false}`.

- _Use:_ Change your "REC" button color immediately when recording starts/stops.

- **Timecode:** `/transports/0/timecode`
- **Payload:** `{"display": "01:00:00:00", ...}`.

- _Note:_ Subscribing to timecode generates high network traffic (updates every frame). Use cautiously on mobile networks.

### **5. Implementation Summary**

1. **Open WebSocket** connection to `ws://<camera-ip>/control/api/v1/notification` (Standard endpoint convention, though the doc primarily lists the REST path structure).
2. Wait for the `{"action": "websocketOpened"}` message.

3. **Send Subscribe Payload:**

```json
{
  "action": "subscribe",
  "properties": [
    "/lens/focus",
    "/lens/iris",
    "/video/shutter",
    "/video/iso",
    "/transports/0/record"
  ]
}
```

4. **Listen** for `propertyValueChanged` messages and update your Android `ViewModel` or UI State accordingly.
