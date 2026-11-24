# MicInjector — Quest Voice Recognition experiment

An experimental modification of [yume-chan/MicInjector](https://github.com/yume-chan/MicInjector) that changes the Android audio-policy capture preset from the original `CAMCORDER` route to `VOICE_RECOGNITION` by default.

The change was made after observing VRChat on one Meta Quest 3S request the `VOICE_RECOGNITION` capture source. It was then tested with that Quest 3S setup. Compatibility with other headsets, Horizon OS versions, Android apps, and VRChat versions is **not guaranteed**.

> This is an unofficial community experiment. It is not affiliated with or endorsed by Meta or VRChat.

> **Licensing:** Upstream-derived code from [yume-chan/MicInjector](https://github.com/yume-chan/MicInjector) is licensed under the MIT License. Include the original copyright and permission notice in copies or substantial portions. See [LICENSE-MicInjector](LICENSE-MicInjector) and [UPSTREAM.md](UPSTREAM.md).

> **APK attribution:** The downloadable APK is an unofficial modified derivative of MicInjector by Simon Chan; modifications and Quest testing by W911D. It is not an official upstream release. The APK artifact includes [ATTRIBUTION.txt](ATTRIBUTION.txt) and the MIT license notice.

## How it works

1. The Windows client lists available Windows playback devices and captures the device selected by the user using WASAPI loopback.
2. The client sends 48 kHz audio to the Quest over ADB.
3. The Android-side code registers an audio-policy loopback route matching the selected capture preset.
4. An Android app that requests that same preset may receive the injected audio as its microphone input.

The receiver must use a matching Android capture preset. Changing the preset does not force an app to use it.

## Requirements

- A compatible Android 13+ headset. Only one Quest 3S setup has been verified so far.
- A Windows PC.
- Android Platform Tools (ADB).
- Node.js 22 or newer with npm (included with Node.js). The launcher runs the pinned pnpm 10.6.5 version through npm; no separate Corepack or pnpm installation is required.
- ADB debugging enabled on the headset. Connect using USB ADB or classic ADB TCP/IP over Wi-Fi; see [CONNECTION_METHODS.md](CONNECTION_METHODS.md).
- The APK built by GitHub Actions, placed at `app/build/outputs/apk/debug/app-debug.apk`.
- Internet access on the first launch so npm can download the pinned pnpm version and client dependencies.

For the optional PC microphone + desktop-audio mixing setup, install [MIXLINE by Logitech G](https://www.logitechg.com/en-eu/software/mixline) and [VB-Audio VB-CABLE](https://vb-audio.com/Cable/). The detailed setup is in [CONNECTION_METHODS.md](CONNECTION_METHODS.md).

## Windows audio routing

At startup, the client lists compatible Windows playback devices and lets the user choose which one to capture. For the MIXLINE + VB-CABLE setup, route the combined mix to `CABLE Input (VB-Audio Virtual Cable)` in MIXLINE, then select **CABLE Input** in MicInjector. The selected device is remembered locally and suggested on the next launch. The Windows default output does not have to be changed just for MicInjector; configure it only if your chosen MIXLINE desktop-audio routing needs it.

Do not confuse the two VB-CABLE endpoints: `CABLE Input` is the playback destination; `CABLE Output` is the recording endpoint. VB-CABLE routes audio inside Windows. It does not connect the Quest to the PC. ADB transfers the captured audio to the Quest over USB or Wi-Fi.

## Quick start on Windows

After the APK is available at the expected path (or ready to select when the launcher prompts), double-click **`Start-MicInjector.bat`** in the repository root.

The launcher and Windows audio-output selector are English-only. All launcher text is included directly in `Start-MicInjector.bat`; no external language folder or language selection is required.

The launcher displays a **Mic Translation notice** before starting the PC client: open the Quest menu that shows your apps, close it again, then press Enter in the launcher to continue. If audio is still missing, the notice reminds you to check VRChat mute status, Noise Suppression, Mic Activation Threshold, Mic Output Volume, and microphone permission.

The launcher provides a menu to:

- Start using a USB-connected Quest.
- Save and connect to multiple Quest headsets independently, each with its own IP address, TCP/IP port, model, optional nickname and last successful connection time.

  The saved-profile interface supports multiple Quest entries, but simultaneous use with two or more physical headsets has not yet been tested. The current hardware testing has used one Quest; see [TESTED_CONFIGURATIONS.md](TESTED_CONFIGURATIONS.md).
- Set up a new wireless Quest through USB. The launcher reads its IP automatically and offers port 5555 by default, with an optional custom port from 1024–65535.
- Give a new Quest a custom display name during setup, or leave it blank to use the default model name.
- Open **Manage saved Quest connections** to edit or clear a nickname, or remove an old saved connection.
- Choose which saved Quest to connect to from a list showing its model, `IP:port`, optional nickname and last connected time. The timestamp updates after a successful connection.
- Automatically migrate the previous single-Quest saved IP/port setting into the new list on first use. Existing saved connection details are retained.
- Refresh the device list and view USB or Wi-Fi troubleshooting steps if the Quest is not detected.
- Select the Windows playback device to capture (CABLE Input is suggested when available).
- Remember the last selected playback device locally.
- Check and refresh the Windows client dependencies automatically at startup.
- Check whether the MicInjector Android package is already installed on the selected Quest; use two ADB package queries to avoid unnecessary installation. Only show the installation warning when both checks find no installed package. Choosing No cancels the launch without installing the APK.
- Transfer the injector APK to the headset's temporary location and start its audio process.

The launcher looks for `adb.exe` on Windows PATH, in a `platform-tools` folder beside the launcher, or asks you to enter its path. It requires Node.js 22+ with npm. It checks the Node.js version and uses npm to run the project's pinned pnpm 10.6.5 version, so users do not need to install or enable Corepack or pnpm themselves.

**Important:** Before the first APK installation, the launcher shows a warning and asks for confirmation. This is unofficial experimental software and may be unstable, incompatible with your headset or target app, or stop working after a software update. Install it only if you trust the source and understand the risks. The project is provided without warranty. The current APK has no launcher Activity, so it does not create an icon in the Quest app library. The injector audio process is started separately through ADB using Android's `app_process`.

## Build the Android APK

See [CLOUD_BUILD.md](CLOUD_BUILD.md) for the GitHub Actions build instructions.

The client expects the built APK at:

```text
app/build/outputs/apk/debug/app-debug.apk
```

You can override this path with the `MIC_INJECTOR_APK_PATH` environment variable. For example:

```powershell
$env:MIC_INJECTOR_APK_PATH = "C:\Users\YourName\Downloads\app-debug.apk"
```

The PC client transfers this file to the headset and starts the Android-side entry point through `app_process`. There is no normal launcher workflow; keep the PC client running while testing.

## Software requirements and installation

See [SETUP_SOFTWARE.md](SETUP_SOFTWARE.md) for required tools, optional audio-routing software, automatic checks, and official download links. The Windows launcher downloads and runs the project's pinned pnpm 10.6.5 version through npm, then installs or refreshes the local client dependencies.

## Connect the Quest to the PC

ADB can use a direct **USB cable** or classic **ADB TCP/IP over Wi-Fi**. For each new Quest, connect it over USB and choose **Set up a new Quest using USB**. The launcher reads the Quest's current Wi-Fi IP, offers port 5555 by default (or a custom port from 1024 to 65535), then stores one local profile keyed by the Quest's IP address, with the selected TCP/IP port recorded in that profile. You can add an optional nickname during setup. The profile identifies a network endpoint, not a physical headset independently of its address. A Quest can listen for classic ADB TCP/IP on only the port most recently selected with `adb tcpip`; setting it to `2222`, for example, moves the listener away from `5555`, so the old port cannot still connect to that same Quest. The launcher keeps one profile per IP address: repeating setup for the same IP updates the existing profile's port and optional name instead of creating another entry. Older duplicate files created by earlier versions are consolidated when the profile is saved or removed. On later launches, choose **Connect to a saved Quest** and select the intended headset by its model, `IP:port`, optional nickname and last-connected time. Use **Manage saved Quest connections** to edit names or remove old profiles. After a Quest restart, connect it by USB and choose **Set up a new Quest using USB** to re-enable TCP/IP. If its IP has changed, the refreshed address is saved as a new endpoint. A custom port does not encrypt ADB; use classic TCP/IP only on a trusted private Wi-Fi network. See [CONNECTION_METHODS.md](CONNECTION_METHODS.md).

The client selects the headset from the devices reported by the local ADB server. If exactly one ADB device is connected, it is selected automatically. If several devices are connected, set `ADB_DEVICE_SERIAL` to the exact Quest serial shown by `adb devices`.

## Run the Windows client

Start the client from the `client` directory. Replace the example serial with the Quest serial displayed by `adb devices`:

```powershell
$env:ADB_DEVICE_SERIAL = "<QUEST-SERIAL-FROM-ADB-DEVICES>"
$env:MIC_INJECTOR_PRESET = "VOICE_RECOGNITION"
node src/index.js
```

To compare with the original demo's capture source, set `MIC_INJECTOR_PRESET` to `CAMCORDER`.

The client requires the local ADB server to be running and listening on the default local port (`127.0.0.1:5037`). If more than one ADB device is connected, set `ADB_DEVICE_SERIAL` explicitly.

## Important limitations

- The project uses Android audio-policy APIs through reflection. These are implementation-sensitive and may change between Android/Horizon OS versions.
- An app only receives the injected audio when its requested capture preset matches the preset selected in MicInjector.
- The Windows client requires a playback endpoint that supports 48 kHz, stereo loopback capture in a supported format. The output-device selector only lists compatible endpoints.
- Audio capture, ADB transport, and injection add latency.
- A successful APK build or a running client does not prove that a particular app is receiving the audio. Test with a second person before relying on it.
- This project has only been verified with one Quest 3S configuration. Contributions with reproducible test details are welcome.

## Tested configuration

The recorded end-to-end test used USB ADB and classic ADB TCP/IP over Wi-Fi on one Meta Quest 3S with VRChat Standalone. PC desktop audio and a Fifine USB microphone mixed through MIXLINE and VB-CABLE were both audible. See [TESTED_CONFIGURATIONS.md](TESTED_CONFIGURATIONS.md) for details; this is not a guarantee of compatibility with other devices.

## Troubleshooting

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common ADB, APK, audio-device, and microphone-delivery problems. See [CONNECTION_METHODS.md](CONNECTION_METHODS.md) for USB and Wi-Fi connection instructions.

## Project status

Experimental proof of concept. The Windows playback-device selector, dependency bootstrap and newer launcher workflows still need broader testing on additional Windows PCs and Quest headsets. See [TESTED_CONFIGURATIONS.md](TESTED_CONFIGURATIONS.md) for the current test status.

## Project credits

- **Project idea, direction, and testing:** [W911D](https://github.com/W911D).
- **AI-assisted development and implementation:** ChatGPT (OpenAI), assisting with code creation, debugging, and project documentation.

The project owner defines the requirements, makes the final decisions, and performs the physical-device testing. AI assistance is acknowledged transparently as part of the development process.
