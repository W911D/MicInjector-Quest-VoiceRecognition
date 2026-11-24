import {
  Adb,
  AdbServerClient,
  AdbSubprocessNoneProtocol,
} from "@yume-chan/adb";
import { AdbServerNodeTcpConnector } from "@yume-chan/adb-server-node-tcp";
import {
  ReadableStream,
  SplitStringStream,
  TextDecoderStream,
  WritableStream,
} from "@yume-chan/stream-extra";
import {
  createReadStream,
  readFileSync,
  statSync,
  writeFileSync,
} from "node:fs";
import { resolve } from "node:path";
import { createInterface } from "node:readline/promises";
import cpal from "node-cpal";

const SETTINGS_PATH = resolve(import.meta.dirname, "../.micinjector-settings.json");
const TARGET_SAMPLE_RATE = 48000;
const TARGET_CHANNELS = 2;

const UI_TEXT = {
    nodeCpalOld: "The installed node-cpal version is too old. Run the launcher again to update client dependencies.",
    noOutput: "No compatible Windows playback device supports 48 kHz stereo loopback capture. Check Windows Sound settings and reconnect the output device.",
    outputTitle: "SELECT WINDOWS AUDIO OUTPUT",
    outputIntro: "Choose the playback device MicInjector should capture.",
    mixlineHelp: "For MIXLINE + VB-CABLE, select CABLE Input.",
    cableMissing: "VB-CABLE playback endpoint was not detected.",
    cableMissingHelp: "You can still capture another playback device, or install VB-CABLE from:",
    suggested: "suggested",
    mixlineMark: "MIXLINE + VB-CABLE",
    defaultMark: "Windows default",
    lastUsed: "Last used: ",
    recommended: "Recommended for the documented MIXLINE setup: CABLE Input.",
    suggestedDefault: "Suggested: your current Windows default playback device.",
    nonInteractive: "[client] Non-interactive session; using ",
    selectOutput: "Select 1-{count}, or press ENTER for [{choice}]: ",
    invalidOutput: "Invalid audio output selection.",
    deviceNotFound: "ADB device not found: ",
    connectedDevices: "Connected devices:",
    checkAdb: "Check ADB and select the Quest in the launcher.",
    expectedOneDevice: "Expected exactly one ADB device, but found:",
    setDeviceSerial: "Set ADB_DEVICE_SERIAL or select a device in the launcher.",
    selectedOutput: "[client] selected output device: ",
    captureStarted: "[client] audio capture started. Press Ctrl+C to stop MicInjector.",
    audioCaptureFailed: "[client] Audio capture error: "
};

function ui(key) {
  return UI_TEXT[key] ?? key;
}

function uiFormat(key, values = {}) {
  return ui(key).replace(/\{(\w+)\}/g, (_, name) => String(values[name] ?? ""));
}

function loadSettings() {
  try {
    const settings = JSON.parse(readFileSync(SETTINGS_PATH, "utf8"));
    return settings && typeof settings === "object" ? settings : {};
  } catch {
    return {};
  }
}

function saveSettings(settings) {
  try {
    writeFileSync(SETTINGS_PATH, JSON.stringify(settings, null, 2) + "\n", "utf8");
  } catch (error) {
    console.warn("[client] Could not save local settings:", error.message);
  }
}

function isCompatibleLoopbackConfig(config) {
  return (
    config.channels === TARGET_CHANNELS &&
    config.minSampleRate <= TARGET_SAMPLE_RATE &&
    config.maxSampleRate >= TARGET_SAMPLE_RATE &&
    ["f32", "i16"].includes(config.sampleFormat)
  );
}

function getOutputDevices() {
  const audio = cpal.convenience;
  if (!audio || typeof audio.getDevices !== "function") {
    throw new Error(
      "The installed node-cpal version is too old. Run the launcher again to update client dependencies.",
    );
  }

  return audio
    .getDevices({ direction: "output" })
    .filter((device) => device.supportsLoopback)
    .map((device) => {
      const configs = audio.getSupportedLoopbackConfigs(device.deviceId);
      const supported = configs.filter(isCompatibleLoopbackConfig);
      const config =
        supported.find((item) => item.sampleFormat === "f32") ??
        supported.find((item) => item.sampleFormat === "i16");

      return config ? { ...device, captureConfig: config } : null;
    })
    .filter(Boolean);
}

function getSuggestedDeviceIndex(devices, settings) {
  if (settings.outputDeviceId) {
    const savedIndex = devices.findIndex(
      (device) => device.deviceId === settings.outputDeviceId,
    );
    if (savedIndex >= 0) return savedIndex;
  }

  if (settings.outputDeviceName) {
    const savedNameIndex = devices.findIndex(
      (device) => device.name === settings.outputDeviceName,
    );
    if (savedNameIndex >= 0) return savedNameIndex;
  }

  const cableIndex = devices.findIndex((device) =>
    /CABLE Input/i.test(device.name),
  );
  if (cableIndex >= 0) return cableIndex;

  const defaultIndex = devices.findIndex((device) => device.isDefaultOutput);
  return defaultIndex >= 0 ? defaultIndex : 0;
}

async function chooseOutputDevice() {
  const audio = cpal.convenience;
  const settings = loadSettings();
  const devices = getOutputDevices();

  if (devices.length === 0) {
    throw new Error(
      "No compatible Windows playback device supports 48 kHz stereo loopback capture. Check Windows Sound settings and reconnect the output device.",
    );
  }

  const requestedId = process.env.MIC_INJECTOR_OUTPUT_DEVICE_ID;
  if (requestedId) {
    const requested = devices.find((device) => device.deviceId === requestedId);
    if (requested) return requested;
    console.warn("[client] MIC_INJECTOR_OUTPUT_DEVICE_ID was not found; showing the device menu.");
  }

  const requestedName = process.env.MIC_INJECTOR_OUTPUT_DEVICE;
  if (requestedName) {
    const requested = devices.find(
      (device) => device.name.toLowerCase() === requestedName.toLowerCase(),
    );
    if (requested) return requested;
    console.warn("[client] MIC_INJECTOR_OUTPUT_DEVICE was not found; showing the device menu.");
  }

  const suggestedIndex = getSuggestedDeviceIndex(devices, settings);
  const hasCableInput = devices.some((device) => /CABLE Input/i.test(device.name));

  console.log("\n============================================================");
  console.log("                 " + ui("outputTitle"));
  console.log("============================================================");
  console.log(ui("outputIntro"));
  console.log(ui("mixlineHelp"));
  console.log("");

  devices.forEach((device, index) => {
    const marks = [];
    if (index === suggestedIndex) marks.push(ui("suggested"));
    if (/CABLE Input/i.test(device.name)) marks.push(ui("mixlineMark"));
    if (device.isDefaultOutput) marks.push(ui("defaultMark"));
    const marker = marks.length ? " [" + marks.join(" | ") + "]" : "";
    console.log("  [" + (index + 1) + "] " + device.name + marker);
  });

  if (!hasCableInput) {
    console.log("");
    console.log("[client] " + ui("cableMissing"));
    console.log(ui("cableMissingHelp"));
    console.log("https://vb-audio.com/Cable/");
  }

  console.log("");
  if (settings.outputDeviceName && suggestedIndex >= 0) {
    console.log(ui("lastUsed") + devices[suggestedIndex].name);
  } else if (/CABLE Input/i.test(devices[suggestedIndex].name)) {
    console.log(ui("recommended"));
  } else if (devices[suggestedIndex].isDefaultOutput) {
    console.log(ui("suggestedDefault"));
  }

  if (!process.stdin.isTTY || !process.stdout.isTTY) {
    const selected = devices[suggestedIndex];
    console.log(ui("nonInteractive") + selected.name);
    return selected;
  }

  const readline = createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  try {
    const answer = (
      await readline.question(
        uiFormat("selectOutput", { count: devices.length, choice: suggestedIndex + 1 }),
      )
    ).trim();

    if (!answer) return devices[suggestedIndex];

    const choice = Number.parseInt(answer, 10);
    if (!Number.isInteger(choice) || choice < 1 || choice > devices.length) {
      throw new Error(ui("invalidOutput"));
    }

    return devices[choice - 1];
  } finally {
    readline.close();
  }
}

const adbClient = new AdbServerClient(
  new AdbServerNodeTcpConnector({ host: "127.0.0.1", port: 5037 }),
);
const adbDevices = await adbClient.getDevices();
const requestedSerial = process.env.ADB_DEVICE_SERIAL;
let adbDevice;

if (requestedSerial) {
  adbDevice = adbDevices.find((device) => device.serial === requestedSerial);
  if (!adbDevice) {
    console.error(ui("deviceNotFound") + requestedSerial);
    console.error(
      "Connected devices:",
      adbDevices.map((device) => device.serial).join(", ") || "none",
    );
    console.error("Check ADB and select the Quest in the launcher.");
    process.exit(1);
  }
} else if (adbDevices.length === 1) {
  [adbDevice] = adbDevices;
} else {
  console.error(
    "Expected exactly one ADB device, but found:",
    adbDevices.map((device) => device.serial).join(", ") || "none",
  );
  console.error("Set ADB_DEVICE_SERIAL or select a device in the launcher.");
  process.exit(1);
}

console.log("[client] using ADB device", adbDevice.serial);
const adb = new Adb(await adbClient.createTransport(adbDevice));

const capturePreset = (
  process.env.MIC_INJECTOR_PRESET ?? "VOICE_RECOGNITION"
).toUpperCase();
if (!["VOICE_RECOGNITION", "CAMCORDER"].includes(capturePreset)) {
  console.error("MIC_INJECTOR_PRESET must be VOICE_RECOGNITION or CAMCORDER");
  process.exit(1);
}

const defaultApkPath = resolve(
  import.meta.dirname,
  "../../app/build/outputs/apk/debug/app-debug.apk",
);
const apkPath = resolve(process.env.MIC_INJECTOR_APK_PATH || defaultApkPath);

let apkStats;
try {
  apkStats = statSync(apkPath);
} catch {
  console.error("[client] APK not found: " + apkPath);
  console.error("Build/download the APK or set MIC_INJECTOR_APK_PATH to its location.");
  process.exit(1);
}

if (!apkStats.isFile() || apkStats.size === 0) {
  console.error("[client] APK is not a valid non-empty file: " + apkPath);
  process.exit(1);
}

console.log("[client] using APK " + apkPath + " (" + apkStats.size + " bytes)");

let selectedOutput;
try {
  selectedOutput = await chooseOutputDevice();
} catch (error) {
  console.error("[client] Audio output selection failed: " + error.message);
  process.exit(1);
}

saveSettings({
  outputDeviceId: selectedOutput.deviceId,
  outputDeviceName: selectedOutput.name,
});

console.log(ui("selectedOutput") + selectedOutput.name);
console.log(
  "[client] loopback format: " + TARGET_SAMPLE_RATE + " Hz, " +
  TARGET_CHANNELS + " channels, " + selectedOutput.captureConfig.sampleFormat,
);

const sync = await adb.sync();
const ServerPath = "/data/local/tmp/micinjector.jar";
try {
  await sync.write({
    filename: ServerPath,
    file: ReadableStream.from(createReadStream(apkPath)),
  });
} finally {
  await sync.dispose();
}

const server = await adb.subprocess.spawn(
  ["app_process", "-cp", ServerPath, "/", "moe.chensi.micinjector.Main", capturePreset],
  { protocols: [AdbSubprocessNoneProtocol] },
);

let totalWrite = 0;
server.stdout
  .pipeThrough(new TextDecoderStream())
  .pipeThrough(new SplitStringStream("\n"))
  .pipeTo(
    new WritableStream({
      write(chunk) {
        const serverWritten = Number.parseInt(chunk);
        if (Number.isFinite(serverWritten)) {
          console.log(
            "client written",
            totalWrite,
            "server written",
            serverWritten,
            "delta",
            totalWrite - serverWritten,
          );
        } else if (chunk.trim()) {
          console.log("[Quest]", chunk);
        }
      },
    }),
  )
  .catch((error) => {
    if (connectionInterrupted || stopping) return;
    console.error("[client] Quest output stream ended:", error.message);
  });

let stopping = false;
let connectionInterrupted = false;

const serverWriter = server.stdin.getWriter();

const audioStream = await cpal.convenience.createLoopbackStream({
  deviceId: selectedOutput.deviceId,
  config: {
    channels: TARGET_CHANNELS,
    sampleRate: TARGET_SAMPLE_RATE,
    sampleFormat: selectedOutput.captureConfig.sampleFormat,
    bufferSize: { type: "default" },
  },
  autoStart: true,
  onData(data) {
    if (stopping || connectionInterrupted) return;

    let pcmBytes;

    if (selectedOutput.captureConfig.sampleFormat === "f32") {
      const pcm16 = new Int16Array(data.length);
      for (let i = 0; i < data.length; i++) {
        const sample = Math.max(-1, Math.min(1, data[i]));
        pcm16[i] = sample < 0
          ? Math.round(sample * 0x8000)
          : Math.round(sample * 0x7fff);
      }
      pcmBytes = new Uint8Array(pcm16.buffer);
    } else {
      pcmBytes = new Uint8Array(data.buffer, data.byteOffset, data.byteLength);
    }

    const safeCopy = new Uint8Array(pcmBytes.length);
    safeCopy.set(pcmBytes);

    void serverWriter.write(safeCopy).catch(() => {
      if (connectionInterrupted || stopping) return;

      connectionInterrupted = true;
      console.error(
        "[client] Connection to Quest interrupted. Audio sending has stopped. Check the USB/Wi-Fi connection and reconnect the headset.",
      );
      void stopClient(1);
    });
    totalWrite += safeCopy.byteLength;
  },
  onError(error) {
    if (stopping || connectionInterrupted) return;
    console.error(ui("audioCaptureFailed"), error.message);
  },
});

console.log(ui("captureStarted"));

async function stopClient(exitCode = 0) {
  if (stopping) return;
  stopping = true;
  try {
    await audioStream.close();
  } catch {}
  try {
    await serverWriter.close();
  } catch {}
  process.exit(exitCode);
}
process.once("SIGINT", () => void stopClient());
process.once("SIGTERM", () => void stopClient());
