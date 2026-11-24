# Build the Android APK with GitHub Actions

This repository includes a GitHub Actions workflow at `.github/workflows/build-apk.yml`. It builds the debug APK on GitHub-hosted infrastructure, so Android Studio and the Android SDK do not need to be installed on your PC.

## Run the build

1. Open the repository on GitHub.
2. Select the **Actions** tab.
3. Select **Build MicInjector APK**.
4. Select **Run workflow** when manual execution is available, or push a commit to the `main` branch to trigger the workflow.
5. Open the completed workflow run.
6. Under **Artifacts**, download `MicInjector-debug-apk`.
7. Extract the downloaded ZIP. It contains `app-debug.apk`, `ATTRIBUTION.txt`, and `LICENSE-MicInjector`.
8. Keep the attribution and license files with the APK when copying or redistributing it; the MIT license requires the original copyright and permission notice to accompany copies or substantial portions.
9. Place `app-debug.apk` in the repository at:

```text
app/build/outputs/apk/debug/app-debug.apk
```

Keep the filename exactly `app-debug.apk`. The Windows client reads the APK from this location and transfers it to the headset when it starts.

## What this version changes

- The Android injector defaults to `VOICE_RECOGNITION`, matching the capture preset observed in one Quest 3S / VRChat diagnostic session.
- `CAMCORDER` remains available as an optional preset for comparison and testing.
- The Windows client can select a specific ADB device using `ADB_DEVICE_SERIAL`, instead of silently selecting the first connected device.
- The Windows client can enumerate compatible playback endpoints and capture the one chosen by the user. It recommends CABLE Input for the MIXLINE + VB-CABLE setup and remembers the last selected endpoint locally.

## Windows client prerequisites

Install:

- Node.js 22 or newer.
- npm (included with Node.js; the launcher uses it to run pinned pnpm 10.6.5).
- Android Platform Tools (ADB).

The launcher automatically runs `npm exec --yes --package=pnpm@10.6.5 -- pnpm install --no-frozen-lockfile` in the `client` directory before starting. This installs or updates the Windows ADB and audio-capture dependencies. Node.js 22 or newer with npm must be installed; Corepack and a global pnpm installation are not required.

## Connect the headset

This project supports both USB ADB and classic Wireless ADB through TCP/IP. The default port is 5555; advanced users can select another decimal port from 1024 to 65535 during first-time setup. Follow the connection instructions in [CONNECTION_METHODS.md](CONNECTION_METHODS.md).

- **USB:** connect a data-capable USB-C cable, accept the USB debugging prompt in the headset, then verify with `adb devices`.
- **First-time Wi-Fi setup:** connect the Quest and PC to the same Wi-Fi network, connect USB, and choose **Set up a new Quest using USB** in the launcher. It reads the Quest's IP through `adb shell ip -4 route get 1.1.1.1`, asks for the TCP/IP port (Enter keeps 5555), asks for an optional nickname, then saves a profile with its IP, port, model and timestamp.
- **Reconnect:** reopen the launcher and choose **Connect to a saved Quest**. Select the required profile from the list showing model, IP:port, optional nickname and last-connected time. Use **Manage saved Quest connections** to rename or remove profiles. If a Quest restarts or its IP changes, repeat setup over USB for that headset. Changing ports does not encrypt ADB.

## Audio-routing software

For the optional PC desktop-audio + physical-microphone mix, install:

- [MIXLINE by Logitech G](https://www.logitechg.com/en-eu/software/mixline)
- [VB-Audio VB-CABLE Virtual Audio Device](https://vb-audio.com/Cable/)

See [CONNECTION_METHODS.md](CONNECTION_METHODS.md) for the MixLine routing layout and the difference between the Windows audio cable and the USB/Wi-Fi ADB connection.

## Start the client

On Windows, the easiest option is to place the downloaded APK at the path above, return to the repository root, and double-click `Start-MicInjector.bat`. Choose USB or Wi-Fi, select the Quest from the detected ADB devices, and then choose the Windows playback endpoint to capture. CABLE Input is suggested when VB-CABLE is installed.

The launcher installs the APK through ADB if it is not already installed. The current APK has no launcher Activity, so no Quest app-library icon is created. The launcher then transfers the APK to a temporary location and starts its injector entry point separately with Android's `app_process` through ADB.

For manual startup, install the client dependencies with `npm exec --yes --package=pnpm@10.6.5 -- pnpm install` from the `client` folder, then continue with the commands below. The client will display the playback-device selection menu before starting audio capture.


Run this from the `client` directory, replacing the placeholder with the serial shown by `adb devices`:

```powershell
$env:ADB_DEVICE_SERIAL = "<QUEST-SERIAL-FROM-ADB-DEVICES>"
$env:MIC_INJECTOR_PRESET = "VOICE_RECOGNITION"
node src/index.js
```

**Important:** This is an experimental compatibility change. A successful APK build does not prove that a given headset OS or Android app will accept the injected audio. Verify microphone delivery in the target app before relying on it.
