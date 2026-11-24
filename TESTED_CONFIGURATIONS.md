# Tested configurations

This file records observed test results. A result applies only to the exact setup described; it does not guarantee compatibility with other headsets, operating-system versions, Windows configurations, or apps.

## Meta Quest 3S — VRChat Standalone

| Test | Result | Notes |
|---|---|---|
| Classic ADB TCP/IP over Wi-Fi | Passed | The USB-first TCP/IP connection was tested successfully on the single available Quest. |
| Saved Quest profile registry and reconnect manager | Passed with one Quest | Creating a profile, reconnecting, editing and clearing its nickname, removing it, and updating the same-IP profile were tested. Simultaneous operation with two or more physical Quests remains untested because only one headset was available. |
| Custom TCP/IP port setup and persistence | Passed with one Quest | Default and custom port setup and saved-profile updates were tested on one headset. The Quest listens on the most recently selected TCP/IP port; this does not test multiple headsets. |
| Changing the port on the same Quest | Observed | Switching the Quest from `5555` to `2222` makes the previous port unreachable; classic `adb tcpip <PORT>` restarts the daemon to listen on the selected port. The launcher now stores one profile per IP, updating the selected port and optional name in that record rather than creating duplicate profiles. |
| USB ADB transport | Passed | MicInjector ran using the USB-connected Quest serial. |
| Desktop audio | Passed | PC desktop/music audio was audible in VRChat through the injected audio path. |
| External PC microphone | Passed | A Fifine USB microphone connected to the PC was mixed with desktop audio in MIXLINE and delivered through VB-CABLE and MicInjector. |
| Both sources together | Passed | Desktop audio and the Fifine microphone were heard together in VRChat. |
| USB-session stability | Passed in the observed test | The recorded USB test completed cleanly. |

### Wireless-session observation

During one earlier Wi-Fi test, the received volume varied occasionally. The same audio setup subsequently worked cleanly over USB. The cause of the Wi-Fi-session variation was not isolated, so this observation should not be treated as proof of a MicInjector defect or as a measured Wi-Fi limitation.

## Automated client validation

GitHub Actions validates the Node.js 22 setup, npm-based pnpm 10.6.5 dependency installation, JavaScript syntax, and static structure of the Windows launcher. The current launcher validation checks automatic IP discovery, custom-port validation and persistence, migration of the old single-Quest setting, multi-profile list loading/saving, nickname validation/editing, remove/disconnect and last-used timestamp handling. These checks do not test actual wireless reconnection, the management UI on a physical PC, WASAPI loopback or audio capture on a Quest/Windows device.

## Windows audio-output selection status

The updated playback-device selector has been tested on the available Windows PC. It enumerates compatible playback endpoints, supports selecting the desired output for loopback capture, and remembers the last selection locally. Compatibility with additional Windows PCs and audio-device configurations has not yet been established.

## Windows launcher status

`Start-MicInjector.bat` has been tested end-to-end with one physical Quest, including USB/Wi-Fi setup, saved-profile reconnect, profile management, custom-port changes, playback-device selection, and the installation/reconnect paths. Testing with two or more physical Quest headsets at the same time remains outstanding. Automated checks do not replace that multi-headset test.

## Test environment notes

- Headset: Meta Quest 3S.
- Target app: VRChat Standalone.
- Android/Horizon OS version at the time of initial diagnostics: Android 14.
- Android capture preset selected by MicInjector: `VOICE_RECOGNITION`.
- PC audio mixer: MIXLINE.
- Virtual audio device: VB-Audio VB-CABLE.
- External microphone: Fifine USB microphone connected to the PC.
- Windows client: Windows, Node.js client, ADB transport.

The exact Windows build, VRChat build, headset firmware build, microphone model, and network topology were not recorded for every test. Do not infer those details from this document.

### Restart behavior reported during current testing

After restarting the Quest, its previously saved classic ADB TCP/IP endpoint was no longer reachable. Reconnect the headset over USB and run **Set up a new Quest using USB** again to re-enable the TCP/IP listener. The saved profile stores connection details; it does not itself keep the ADB daemon listening after reboot.

## How to report another test

When adding a test result, record the exact headset model, OS/firmware version, target app and version, capture preset, ADB connection method (USB or Wi-Fi), and which audio sources were confirmed audible. Distinguish between a client starting successfully and a second person actually hearing the injected audio.
