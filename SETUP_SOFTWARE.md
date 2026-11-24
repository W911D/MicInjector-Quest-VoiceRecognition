# Software setup

The Windows launcher checks the required tools and can open the official download pages from its **Software and setup links** menu. Third-party drivers and desktop applications are not bundled with MicInjector.

## Required

### 1. Android Platform Tools (ADB)

Official download: [Android SDK Platform Tools](https://developer.android.com/tools/releases/platform-tools)

The launcher looks for `adb.exe` in this order:

1. Windows PATH.
2. A `platform-tools` folder beside `Start-MicInjector.bat`.
3. A full path entered by the user when prompted.

ADB is used for USB connections and classic ADB TCP/IP over Wi-Fi. The selected Quest must be authorized and appear with state `device`. This launcher does not use Android's separate Wireless Debugging pairing-code workflow.

For USB connections on Windows, Meta also provides the [official Oculus ADB Driver](https://developers.meta.com/vr/downloads/package/oculus-adb-drivers/). Download and extract the package, then right-click `android_winusb.inf` and choose **Install**. This is a Windows USB driver; it is not a replacement for Android Platform Tools or `adb.exe`.

### 2. Node.js 22 or newer

Official download: [Node.js](https://nodejs.org/en/download)

The launcher checks the installed Node.js major version and stops with a download link if it is older than 22. The updated Windows audio-device selector uses `node-cpal` 1.0.0, which requires Node.js 22 or newer.

### 3. pnpm (handled by the launcher)

The client declares `pnpm@10.6.5` in its `package.json`. You do not need to install pnpm or Corepack separately.

The launcher uses npm (included with Node.js) to run the exact pnpm version required by the project:

```powershell
npm exec --yes --package=pnpm@10.6.5 -- pnpm install --no-frozen-lockfile
```

npm downloads pnpm into its local cache when needed, then pnpm refreshes the client dependencies. This includes the ADB transport libraries and `node-cpal` for playback-device discovery and WASAPI loopback capture.

### 4. MicInjector APK

Build the APK using [CLOUD_BUILD.md](CLOUD_BUILD.md). Download and extract the `MicInjector-debug-apk` artifact from GitHub Actions. The launcher prompts for the APK path if it is not at the expected location.

If the package is not installed, the launcher first displays an experimental-software warning and asks the user to confirm. Choosing No cancels the launch without installing the APK. After confirmation, ADB installs the package and the launcher starts the injector process separately through `app_process`.

## Optional audio-routing software

### MIXLINE by Logitech G

Official page: [Download MIXLINE](https://www.logitechg.com/en-eu/software/mixline)

Use MIXLINE to combine desktop/system audio and a physical PC microphone into one output mix.

### VB-Audio VB-CABLE

Official download and instructions: [VB-CABLE](https://vb-audio.com/Cable/)

VB-CABLE is a virtual Windows audio driver. For the normal Windows installation:

1. Download the ZIP package.
2. Extract all files to a folder.
3. Run the setup program as Administrator.
4. Restart Windows after installation.

This driver installation requires explicit user action and may require administrator approval and a Windows restart. The launcher does not install or silently modify audio drivers.

### How the MIXLINE + VB-CABLE path is used

1. Add desktop/system audio and the physical microphone as MIXLINE inputs.
2. Route both sources to the VB-CABLE playback endpoint.
3. In MicInjector's playback-device menu, select **CABLE Input (VB-Audio Virtual Cable)**.
4. The selected playback endpoint is captured with WASAPI loopback and sent to the Quest over USB or Wi-Fi ADB.

`CABLE Input` is the playback endpoint. `CABLE Output` is the recording endpoint. Do not choose CABLE Output as the playback source in MicInjector.

The output-device selector can also capture compatible speakers, headphones, HDMI audio, and other Windows playback devices. VB-CABLE is optional if the user does not need to mix multiple PC audio sources.

## Launcher interface

The launcher and Windows playback-device selector are English-only. All launcher text is included directly in `Start-MicInjector.bat`; no external language folder or language selection is required. The launcher also displays a Mic Translation notice before starting the client: open the Quest menu that shows your apps, close it again, then press Enter to continue. If audio is still missing, check in VRChat that the microphone is not muted, Noise Suppression is Off, Mic Activation Threshold is 0, and Mic Output Volume is set to an audible level. Also confirm VRChat has microphone permission in Quest settings.

## APK installation confirmation

When the Android package is not already installed on the selected Quest, the launcher displays a warning before installation. It identifies the APK as unofficial experimental software that may be unstable, incompatible with the headset or target app, or stop working after a software update. Install it only if you trust the source and understand the risks. The project provides no warranty. Choose **1 = Yes** to install or **2 = No** to cancel. The APK is not installed when you decline.

## What the launcher handles automatically

- Checks that ADB is available and asks for its path if necessary.
- Checks that Node.js 22 or newer and npm are available.
- Runs the project's pinned pnpm 10.6.5 through npm, without requiring a separate Corepack or global pnpm installation.
- Offers USB ADB and classic ADB TCP/IP over Wi-Fi, defaulting to port 5555 with an optional custom port.
- Reads the Quest's Wi-Fi IP automatically over USB using `adb shell ip -4 route get 1.1.1.1`.
- Defaults to ADB TCP/IP port 5555, with an optional validated custom decimal port from 1024 to 65535.
- Verifies the wireless connection and stores one local profile per Quest, including IP, port, model, optional nickname and last successful connection time.
- Reconnects to the selected saved Quest profile after the launcher is closed and reopened, without a pairing code or manual IP/port entry.
- Offers a **Manage saved Quest connections** menu to edit/clear nicknames or remove old profiles.
- Updates a profile's last-connected time only after ADB confirms the Quest is available.
- Imports the previous single-Quest saved settings automatically on first use.
- Lists device names instead of making users choose by long ADB serials.
- Shows `unauthorized` and `offline` devices with explanations.
- Provides an **R = Refresh** option and connection troubleshooting steps when the Quest is not detected.
- Installs or refreshes the PC client dependencies.
- Prompts for the APK path if it is not in the expected folder.
- Asks for explicit confirmation before installing the Android package when it is not already installed.
- Lists compatible Windows playback endpoints and remembers the user's selection.

## What still needs user action

- Download/install Node.js if it is missing or too old.
- Download/extract Android Platform Tools if ADB is not already installed.
- Download the APK artifact from GitHub Actions.
- Install MIXLINE and VB-CABLE when the user wants the combined desktop-audio + microphone workflow.
- Enable Developer Mode, approve USB debugging, and connect the Quest to USB once to enable TCP/IP Wi-Fi. Keep the Quest and PC on the same local Wi-Fi network for later reconnects.
- Install Meta's Windows USB ADB driver if Windows does not detect the Quest over USB.

External installers and audio drivers are linked from the launcher but are not silently installed.
