# Connection and audio setup

This project has two separate connections. They do different jobs and should not be confused.

1. **Windows audio routing** combines or selects the PC audio that MicInjector captures.
2. **ADB transport** carries the captured audio stream from the PC to the Quest.

ADB can connect through a USB data cable or classic ADB TCP/IP over Wi-Fi. Both methods use the same MicInjector Windows client. For Wi-Fi, this launcher uses a USB-first setup: it reads the Quest's current IP address, enables ADB TCP/IP on the selected port, and saves the connection for later use. It does **not** use Android's Wireless Debugging pairing-code flow, ADB mDNS discovery, or Meta Quest Developer Hub.

## 1. Install the optional audio-routing tools

To combine desktop audio and a physical PC microphone into one mix, use:

- [MIXLINE by Logitech G — official page](https://www.logitechg.com/en-eu/software/mixline)
- [VB-Audio VB-CABLE — official download and installation page](https://vb-audio.com/Cable/)

These are third-party tools and are not bundled with MicInjector. For VB-CABLE, download the Windows package from the official page, extract the ZIP, run the setup program as administrator, and restart Windows after installation as instructed by VB-Audio. The launcher's **Software and setup links** menu opens the official download pages.

### Route desktop audio and microphone through MixLine

1. Install and open MIXLINE.
2. Add the desktop/system audio source you want to transmit.
3. Add your physical microphone as another input (for example, a USB Fifine microphone connected to the PC).
4. Add the VB-CABLE playback endpoint as an output.
5. Connect both inputs to that output in MIXLINE.
6. In the MicInjector output-device prompt, select **CABLE Input (VB-Audio Virtual Cable)**.
7. If your MIXLINE desktop/system-audio source depends on the Windows default playback endpoint, configure that routing in Windows/MIXLINE as needed. MicInjector itself can capture CABLE Input directly and does not require it to be the Windows default.

### Important: CABLE Input versus CABLE Output

VB-CABLE has two names for opposite ends of the virtual cable:

- **CABLE Input** — a Windows playback device. This is where MIXLINE sends the combined audio.
- **CABLE Output** — a Windows recording device. It receives the audio forwarded by VB-CABLE.

For MicInjector, select **CABLE Input** in the output-device list. Do not select CABLE Output as the playback destination.

VB-CABLE only routes audio inside Windows. It does not connect the headset to the PC and it does not replace ADB.

## 2. Choose the Windows audio output

After selecting the Quest, the Windows client lists playback endpoints that support the required 48 kHz stereo loopback format. Choose the endpoint that carries the audio you want to send. For the documented MIXLINE setup, choose **CABLE Input**. Speakers, headphones, HDMI audio, and other compatible playback endpoints can also be selected.

The client remembers the last selected output device in a local settings file under the client folder. That settings file is ignored by Git and is not included in the repository. If the saved endpoint is no longer available, the client suggests CABLE Input when present, otherwise the current Windows default output or the first compatible endpoint.

## 3. Choose how ADB connects to the Quest

Before either method, enable Developer Mode for the headset and install [Android Platform Tools (ADB)](https://developer.android.com/tools/releases/platform-tools) on Windows. See [Meta's official ADB guide](https://developers.meta.com/vr/documentation/native/android/ts-adb/), [Meta's device setup guide](https://developers.meta.com/vr/documentation/native/android/mobile-device-setup/), and [Android's debugging options documentation](https://developer.android.com/studio/debug/dev-options). The launcher shows a device-name list with **R** to refresh and troubleshooting steps when no device is visible. For this launcher, use classic ADB TCP/IP setup; do not follow the separate Wireless Debugging pairing-code workflow.

### Option A — USB ADB

Use this option when you want a physical data connection.

1. Enable **Developer Mode** for the headset in the Meta Horizon mobile app.
2. Connect the Quest to the PC using a USB-C cable that supports data, not a charge-only cable.
3. Put on the headset. In the headset's Developer settings, enable **MTP Notification** if available.
4. Accept the **Allow USB debugging** prompt. Choose **Always allow from this computer** only if this is your own trusted PC.
5. If Windows does not detect the Quest over USB, install the [official Meta Oculus ADB Driver](https://developers.meta.com/vr/downloads/package/oculus-adb-drivers/): download and extract it, then right-click `android_winusb.inf` and choose **Install**.
6. Open PowerShell and run:

```powershell
adb devices
```

7. Find the Quest entry. It should show status `device`. If it says `unauthorized`, put on the headset and approve the debugging prompt. If it does not appear, check the cable, Developer Mode and Windows ADB driver.
8. Copy the serial exactly as displayed.

Example output (illustrative only):

```text
List of devices attached
1WMHHXXXXXXXX    device
```

9. From the `client` directory, set the serial and start MicInjector manually, or return to the repository root and run `Start-MicInjector.bat` to select the USB device in its menu:

```powershell
$env:ADB_DEVICE_SERIAL = "<QUEST-SERIAL-FROM-ADB-DEVICES>"
$env:MIC_INJECTOR_PRESET = "VOICE_RECOGNITION"
node src/index.js
```

The launcher also displays these USB checks and lets you press **R** to refresh the device list after reconnecting or approving the prompt.

### Option B — Classic ADB TCP/IP over Wi-Fi (recommended for this launcher)

This is the original USB-first method. It does **not** require the headset's Wireless Debugging pairing-code screen or Meta VR Developer Hub.

#### First-time setup, or refreshing a changed IP address

1. Enable **Developer Mode** for the Quest in the Meta Horizon mobile app.
2. Connect the Quest and PC to the **same local Wi-Fi network**.
3. Connect the Quest to the PC using a USB-C data cable.
4. Put on the headset and approve **Allow USB debugging**.
5. In `Start-MicInjector.bat`, choose **Wi-Fi connection** > **Set up a new Quest using USB**.
6. Select the USB-connected Quest. The launcher runs `adb shell ip -4 route get 1.1.1.1` and reads the Quest's source IP from the route output. You do not type the address.
7. The launcher opens an **Advanced Wi-Fi Port Setting** prompt. Press **Enter** to use the default `5555`, or enter a custom decimal port from `1024` to `65535`. Values outside that range, non-numeric values, and leading zeros are rejected.
8. The launcher runs `adb tcpip <selected-port>`, connects to the Quest's detected IP using that port and verifies the wireless ADB state.
9. It asks for an optional display name. Enter one to distinguish this headset (for example, `Office` or `Bedroom`), or press Enter to keep the default model name.
10. The launcher saves a separate Quest profile on this PC. Once it reports that Wi-Fi ADB is ready, disconnect USB and press a key; the saved-Quest list opens so you can choose which headset to use.

Manual equivalent (replace the placeholders with values from your own Quest):

```powershell
adb -s <USB-QUEST-SERIAL> shell ip -4 route get 1.1.1.1
adb -s <USB-QUEST-SERIAL> tcpip <PORT>
adb connect <QUEST-WIFI-IP>:<PORT>
adb devices
```

The port must be available for the Quest's ADB daemon. If another service is using it, ADB may fail to bind or connect. The Quest and PC must remain on the same local network. Guest Wi-Fi, VPNs, or router client isolation may prevent them from communicating.

**Security note:** Classic ADB TCP/IP is unencrypted regardless of which port you select. Changing the port does not add encryption or authentication. Use it only on a trusted private Wi-Fi network; do not enable it on public or guest networks. Android documents this limitation in its [ADB Wi-Fi architecture notes](https://android.googlesource.com/platform/packages/modules/adb/+/HEAD/docs/dev/adb_wifi.md).

#### Multiple saved Quest connections and reconnecting later

The launcher stores one local profile per Quest IP address in:

```text
%LOCALAPPDATA%\MicInjector\wifi-devices\
```

Each profile records the IP address, selected port, detected Quest model, optional display name and last successful connection time. The profile is stored locally on this Windows PC and is not committed to the repository.

**Important port behavior:** A physical Quest's classic ADB daemon listens on the TCP port most recently selected by `adb tcpip <PORT>`. This command restarts `adbd` in TCP mode on that port; it does not create a second listener for the same headset. For example, after setting the Quest to port `2222`, its earlier `5555` endpoint is no longer expected to respond. The launcher uses the IP address as the unique profile key and stores the selected port as editable connection data. Setting up the same IP again updates its existing profile, including its port and optional name. It does not create a second profile for the same Quest. Older duplicate profile files made by previous versions are hidden from the selection list; they are consolidated when the profile is next saved or all removed.

**After a headset restart:** In the current Quest test, the classic TCP/IP listener is no longer reachable after reboot. The saved profile remembers the address and port; it does not make the Quest keep ADB TCP/IP enabled after a restart. Connect the Quest by USB again and repeat **Set up a new Quest using USB** to re-enable TCP/IP. If the router assigned a new IP, setup reads and saves the new address.

When you reopen MicInjector:

1. Choose **Wi-Fi connection** > **Connect to a saved Quest**.
2. Select the headset using the displayed model, `IP:port`, optional nickname and **Last connected** timestamp.
3. The launcher reconnects to that profile and updates its last-connected time after the ADB device is verified.

To change a nickname later, choose **Manage saved Quest connections**, select a profile, then choose **Edit display name**. Leave the name blank to clear it and show the default model name. Choose **Remove saved connection** to delete an old profile and disconnect that host-side ADB connection.

The previous single-Quest setting at `%LOCALAPPDATA%\MicInjector\quest-wifi-ip.txt` is automatically imported into the new profile list the first time it is found. The old file is then removed to prevent a deleted migrated profile from reappearing.

**When setup is needed again:** If a Quest reboots, the router assigns it a different IP address, the saved address stops responding, or the network changes, connect that Quest by USB and choose **Set up a new Quest using USB** again. This re-enables the TCP/IP listener and creates or refreshes the profile for the current IP and port.

### Switching between USB and Wi-Fi

You do not need a different MicInjector build for each connection type. The Windows client uses the local ADB server for both transports.

The saved-Quest list is also the wireless device chooser. Every entry shows the model, full `IP:port`, optional custom name and last successful connection time. This makes multiple headsets with the same model distinguishable. Newly created profiles are added to the list immediately.

To use USB, connect the data cable and choose **USB connection**. To use Wi-Fi, choose **Connect to a saved Quest**. To create or refresh a profile, choose **Set up a new Quest using USB**. To rename or remove an old profile, choose **Manage saved Quest connections**. Do not confuse ADB transport with VB-CABLE, which only routes audio inside Windows.

## 4. Test status

USB ADB and classic ADB TCP/IP over Wi-Fi have both been used successfully in tests on one Meta Quest 3S with VRChat Standalone. The saved-profile manager, nickname editing/removal, same-IP profile updates, custom-port setup, and reconnect workflow were also tested on that single Quest. Desktop audio and the PC-connected Fifine microphone mix were received successfully in the recorded USB test. Simultaneous operation with two or more physical Quest headsets has not been tested. See [TESTED_CONFIGURATIONS.md](TESTED_CONFIGURATIONS.md) for the test matrix.

## 5. Full signal path

```text
Desktop audio ─┐
               ├─> MIXLINE ─> CABLE Input (VB-CABLE)
PC microphone ─┘                        |
                                        v
                          Selected Windows playback-device capture
                                        |
                                        v
                              MicInjector Windows client
                                        |
                              ADB over USB or Wi-Fi
                                        |
                                        v
                            Quest Android injector
                                        |
                                        v
                               Compatible target app
```

For VRChat, the `VOICE_RECOGNITION` preset was observed and tested on one Quest 3S setup. Compatibility with other headsets, OS versions, or apps is not guaranteed.
