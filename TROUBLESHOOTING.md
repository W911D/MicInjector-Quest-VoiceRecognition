# Troubleshooting

## The CMD launcher says ADB was not found

Add Android Platform Tools to the Windows PATH, or extract the Platform Tools folder as `platform-tools` beside `Start-MicInjector.bat`. Download them from [Android's official Platform Tools page](https://developer.android.com/tools/releases/platform-tools).

## The launcher does not find the Quest under USB or Wi-Fi

The launcher displays device names, includes devices in `unauthorized` or `offline` states, and provides **R = Refresh**. A device in `unauthorized` state needs approval inside the headset before it can be used. For a device in `offline` state, wake the Quest, check that it is still on the same local Wi-Fi network, or reconnect it through USB and set up Wi-Fi again. This launcher uses classic ADB TCP/IP, not Android's separate Wireless Debugging pairing flow.

## The launcher says the Windows client dependencies are missing

The launcher uses `npm exec --yes --package=pnpm@10.6.5 -- pnpm install --no-frozen-lockfile` in the `client` folder before each start. This uses npm, which is included with Node.js, and does not require a separate Corepack or pnpm installation. Confirm Node.js 22+ and internet access when dependencies need to be downloaded.

## The launcher says the APK is missing

Download the `MicInjector-debug-apk` artifact from the repository's Actions workflow, extract `app-debug.apk`, and put it under `app/build/outputs/apk/debug/` in the repository, or enter its full path when prompted. The launcher checks that the file exists before proceeding.

## The launcher asks before installing the Android package

The launcher checks the selected Quest for package `moe.chensi.micinjector` using both `pm path` and an exact `pm list packages` match. When either check finds it, the launcher should skip installation and report that MicInjector is already installed.

If the launcher still asks to install it, verify that the selected ADB device is the same Quest where MicInjector was installed. You can inspect the package manually with:

```text
adb -s <QUEST-SERIAL> shell pm list packages moe.chensi.micinjector
```

When the package is not installed, the launcher displays an experimental-software warning and asks for confirmation. The APK may be unstable, incompatible with the headset or target app, or stop working after a software update. Install it only if you trust the APK and its source. Choose **1 = Yes** to install or **2 = No** to cancel. The injector process is started separately through `app_process`.

If installation fails after confirmation, check that the selected Quest is authorized for ADB and appears as `device` in `adb devices`.


## `adb devices` shows no Quest

**For USB ADB:**

- Enable Developer Mode for the headset in the Meta Horizon mobile app.
- Use a USB-C cable that supports data, not charge-only.
- Put on the headset and accept the USB debugging authorization prompt. Choose **Always allow from this computer** only on a trusted PC.
- In the headset Developer settings, enable **MTP Notification** if available.
- On Windows, install the [official Meta Oculus ADB driver](https://developers.meta.com/vr/downloads/package/oculus-adb-drivers/) if Windows does not detect the headset.
- Try another USB port or data cable, then press **R = Refresh** in the launcher.

**For classic ADB TCP/IP over Wi-Fi:**

- Put the Quest and PC on the same local Wi-Fi network. Guest Wi-Fi, VPNs, or router client isolation may prevent device-to-device communication.
- For first-time setup, connect the Quest to the PC using a USB-C data cable and approve USB debugging.
- To add a Quest, choose **Wi-Fi connection** > **Set up a new Quest using USB**. The launcher reads the IP with `adb shell ip -4 route get 1.1.1.1`, then asks for a TCP/IP port. Press Enter for `5555`, or choose a custom decimal port from `1024` to `65535`.
- After ADB is enabled and verified, enter an optional nickname. Press Enter to keep the default model name.
- The launcher creates a separate profile for that headset in `%LOCALAPPDATA%\MicInjector\wifi-devices\`. It records the IP, port, Quest model, optional name and last successful connection time.
- To reconnect, choose **Connect to a saved Quest** and select the required profile. Its last-connected timestamp updates after a successful connection.
- To change a nickname, choose **Manage saved Quest connections** > select the profile > **Edit display name**. Leave it blank to clear the nickname. Use **Remove saved connection** to disconnect and delete an old profile.
- If reconnect fails after a Quest restart, connect it to the PC by USB and repeat **Set up a new Quest using USB**. The saved profile remembers the IP and port, but classic `adb tcpip` does not guarantee that the TCP listener stays enabled after reboot.
- If you change the same Quest from port `5555` to `2222`, the ADB daemon moves to the newly selected port; the old port stops responding. The launcher keeps one saved profile per IP, so setting up the same IP again updates its port and nickname instead of adding a second Quest. Older duplicate files from previous versions are consolidated when the profile is next saved or all removed.
- Different ports on the same IP are not separate headsets. Use a separate saved profile for each physical Quest on the network; each Quest should have its own IP address.
- The old single-entry `quest-wifi-ip.txt` is imported automatically into the profiles once, then removed.
- A different port does not encrypt ADB or make it inherently secure. Classic ADB TCP/IP remains unencrypted; use only a trusted private Wi-Fi network.
- See [CONNECTION_METHODS.md](CONNECTION_METHODS.md) for the complete setup and reconnect procedure.
## Mic Translation does not start working

Before the client starts sending audio, the launcher displays a notice. On the Quest, open the menu that shows your apps, then close it again. Return to the launcher and press **Enter** to continue. This can make Mic Translation start working.

If audio is still missing after that, check the following in **VRChat**:

- Make sure the microphone is not muted.
- Set **Noise Suppression** to **Off**.
- Set **Mic Activation Threshold** to **0**.
- Make sure **Mic Output Volume** is high enough to be audible.
- Confirm VRChat has permission to access the microphone in the Quest's app permission settings.

## The client says the ADB device was not found

From the `client` directory, check the current devices with:

```powershell
adb devices
```

Then copy the Quest serial exactly into:

```powershell
$env:ADB_DEVICE_SERIAL = "<QUEST-SERIAL-FROM-ADB-DEVICES>"
```

The PC client talks to the local ADB server at `127.0.0.1:5037`. Ensure Android Platform Tools are installed and the ADB server is running. For Wi-Fi, use the launcher's saved-address reconnect option or refresh the address through USB if the Quest's IP has changed.

## The client cannot find the APK

The client expects this exact path relative to the repository:

```text
app/build/outputs/apk/debug/app-debug.apk
```

Download the `MicInjector-debug-apk` artifact from a successful GitHub Actions build, extract it, and place `app-debug.apk` at that location. Keep the filename unchanged. Alternatively, set `MIC_INJECTOR_APK_PATH` to the full path of the APK before starting the client:

```powershell
$env:MIC_INJECTOR_APK_PATH = "C:\Users\YourName\Downloads\app-debug.apk"
```

The client checks that the selected file exists and is not empty before transferring it.

## The client captures the wrong sound device

The client displays a numbered list of compatible Windows playback endpoints before it starts audio capture.

- Select `CABLE Input (VB-Audio Virtual Cable)` when using the documented MIXLINE setup.
- Select Speakers, headphones, HDMI audio, or another compatible output if that is where the audio you want is playing.
- The last selected device is remembered in `client/.micinjector-settings.json`.
- Delete that local settings file to clear the remembered selection and return to the suggested device.

Remember: `CABLE Input` is the playback endpoint; `CABLE Output` is the recording endpoint. The MicInjector output selector does not require CABLE Input to be the Windows default playback device.

## USB or Wi-Fi connection is interrupted

If the Quest disconnects while audio is being sent, the client now prints one message: **Connection to Quest interrupted. Audio sending has stopped.** It then stops the client instead of repeatedly printing an error for every audio packet. Reconnect the headset over USB or Wi-Fi ADB, then start MicInjector again.

## The client starts, but the target app does not hear audio

A running PC client or a successful APK build does not prove audio is being received by the target app.

Check that:

1. The client reports the expected ADB device.
2. The client reports the expected selected Windows playback device.
3. The Android process starts without an audio-policy registration error.
4. The selected capture preset matches the preset requested by the target app.
5. The target app is actively using its microphone.

The default preset in this project is `VOICE_RECOGNITION`. `CAMCORDER` is available for comparison, but an app must request the matching preset to receive the route.

## Audio is delayed, choppy, or drops out

Audio passes through Windows capture, ADB transport, and Android audio injection. Each stage can add latency. Try a direct USB ADB connection to compare behavior with Wi-Fi; this changes only the PC-to-headset ADB transport, not the Windows MixLine/VB-CABLE audio routing. The project does not currently guarantee low latency or uninterrupted audio.

## What to include in a bug report

Include the headset model and OS version, Windows version, target app version, capture preset, the client startup output, and what part of the audio chain works. Redact private IP addresses, Wi-Fi names, pairing codes, usernames, and other personal information before posting logs.
