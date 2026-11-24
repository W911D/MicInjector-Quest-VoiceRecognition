package moe.chensi.micinjector

import android.annotation.SuppressLint
import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioManager
import android.media.AudioTrack
import android.media.MediaRecorder
import android.os.Looper
import java.util.Objects
import kotlin.concurrent.thread

object Main {
    private const val MIX_ROLE_INJECTOR = 1
    private const val RULE_MATCH_ATTRIBUTE_CAPTURE_PRESET = 1 shl 1
    private const val ROUTE_FLAG_LOOP_BACK = 1 shl 1

    private fun createAudioAttributes(capturePreset: Int): AudioAttributes {
        val audioAttributesBuilder = AudioAttributes.Builder()
        val setCapturePresetMethod = audioAttributesBuilder.javaClass.getDeclaredMethod(
            "setCapturePreset", Int::class.javaPrimitiveType
        )
        setCapturePresetMethod.invoke(audioAttributesBuilder, capturePreset)
        return audioAttributesBuilder.build()
    }

    private fun parseCapturePreset(name: String?): Int {
        return when (name?.uppercase() ?: "VOICE_RECOGNITION") {
            "VOICE_RECOGNITION" -> MediaRecorder.AudioSource.VOICE_RECOGNITION
            "CAMCORDER" -> MediaRecorder.AudioSource.CAMCORDER
            else -> throw IllegalArgumentException(
                "Unsupported capture preset '$name'. Use VOICE_RECOGNITION or CAMCORDER."
            )
        }
    }

    @JvmStatic
    @SuppressLint("PrivateApi", "DiscouragedPrivateApi")
    fun main(vararg args: String) {
        Thread.setDefaultUncaughtExceptionHandler { _, e ->
            e.printStackTrace()
        }

        Looper.prepare() // Replaced deprecated prepareMainLooper()

        // var systemMain = android.app.ActivityThread.systemMain();
        val activityThreadClass = Class.forName("android.app.ActivityThread")
        val systemMainMethod = activityThreadClass.getDeclaredMethod("systemMain")
        val systemMain = systemMainMethod.invoke(null)
        Objects.requireNonNull(systemMain)

        // var systemContext = systemMain.getSystemContext();
        val getSystemContextMethod = systemMain.javaClass.getDeclaredMethod("getSystemContext")
        val systemContext = getSystemContextMethod.invoke(systemMain) as Context
        Objects.requireNonNull(systemContext)

        // var audioMixRuleBuilder = new AudioMixingRule.Builder();
        val audioMixRuleBuilderClass =
            Class.forName("android.media.audiopolicy.AudioMixingRule\$Builder")
        val audioMixRuleBuilder = audioMixRuleBuilderClass.getDeclaredConstructor().newInstance()

        try {
            // Added in Android 13, but previous versions don't work because lack of permission.
            // audioMixRuleBuilder.setTargetMixRole(MIX_ROLE_INJECTOR);
            val setTargetMixRoleMethod = audioMixRuleBuilder.javaClass.getDeclaredMethod(
                "setTargetMixRole", Int::class.javaPrimitiveType
            )
            setTargetMixRoleMethod.invoke(audioMixRuleBuilder, MIX_ROLE_INJECTOR)
        } catch (ignored: Exception) {
        }

        val addMixRuleMethod = audioMixRuleBuilder.javaClass.getDeclaredMethod(
            "addMixRule", Int::class.javaPrimitiveType, Any::class.java
        )

        // Match the recording preset requested by the receiving Android app.
        // VRChat on this Quest 3S was observed using VOICE_RECOGNITION (source 6).
        val capturePresetName = args.firstOrNull()
        val capturePreset = parseCapturePreset(capturePresetName)
        addMixRuleMethod.invoke(
            audioMixRuleBuilder,
            RULE_MATCH_ATTRIBUTE_CAPTURE_PRESET,
            createAudioAttributes(capturePreset)
        )

        // var audioMixingRule = audioMixRuleBuilder.build();
        val audioMixRuleBuildMethod = audioMixRuleBuilder.javaClass.getDeclaredMethod("build")
        val audioMixingRule = audioMixRuleBuildMethod.invoke(audioMixRuleBuilder)
        Objects.requireNonNull(audioMixingRule)

        // var audioMixBuilder = new AudioMix.Builder(audioMixingRule);
        val audioMixBuilderClass = Class.forName("android.media.audiopolicy.AudioMix\$Builder")
        val audioMixBuilderConstructor =
            audioMixBuilderClass.getDeclaredConstructor(audioMixingRule.javaClass)
        val audioMixBuilder = audioMixBuilderConstructor.newInstance(audioMixingRule)

        val audioFormat =
            AudioFormat.Builder().setEncoding(AudioFormat.ENCODING_PCM_16BIT).setSampleRate(48000)
                .setChannelMask(AudioFormat.CHANNEL_IN_STEREO).build()

        // audioMixBuilder.setFormat(audioFormat);
        val setFormatMethod =
            audioMixBuilder.javaClass.getDeclaredMethod("setFormat", AudioFormat::class.java)
        setFormatMethod.invoke(audioMixBuilder, audioFormat)

        // audioMixBuilder.setRouteFlags(ROUTE_FLAG_LOOP_BACK);
        val setRouteFlagsMethod = audioMixBuilder.javaClass.getDeclaredMethod(
            "setRouteFlags", Int::class.javaPrimitiveType
        )
        setRouteFlagsMethod.invoke(audioMixBuilder, ROUTE_FLAG_LOOP_BACK)

        // var audioMix = audioMixBuilder.build();
        val audioMixBuildMethod = audioMixBuilder.javaClass.getDeclaredMethod("build")
        val audioMix = audioMixBuildMethod.invoke(audioMixBuilder)
        Objects.requireNonNull(audioMix)

        // var audioPolicyBuilder = new AudioPolicy.Builder(systemContext);
        val audioPolicyBuilderClass =
            Class.forName("android.media.audiopolicy.AudioPolicy\$Builder")
        val audioPolicyBuilderConstructor =
            audioPolicyBuilderClass.getDeclaredConstructor(Context::class.java)
        val audioPolicyBuilder = audioPolicyBuilderConstructor.newInstance(systemContext)

        // audioPolicyBuilder.addMix(audioMix);
        val addMixMethod =
            audioPolicyBuilder.javaClass.getDeclaredMethod("addMix", audioMix.javaClass)
        addMixMethod.invoke(audioPolicyBuilder, audioMix)

        // var audioPolicy = audioPolicyBuilder.build();
        val audioPolicyBuildMethod = audioPolicyBuilder.javaClass.getDeclaredMethod("build")
        val audioPolicy = audioPolicyBuildMethod.invoke(audioPolicyBuilder)
        Objects.requireNonNull(audioPolicy)

        val audioManager = systemContext.getSystemService(AudioManager::class.java)

        // audioManager.registerAudioPolicy(audioPolicy);
        val registerAudioPolicyMethod =
            audioManager.javaClass.getDeclaredMethod("registerAudioPolicy", audioPolicy.javaClass)

        // noinspection DataFlowIssue
        val result = registerAudioPolicyMethod.invoke(audioManager, audioPolicy) as Int

        if (result != 0) {
            println("registerAudioPolicy failed")
            return
        }

        // var audioTrack = audioPolicy.createAudioTrackSource(audioMix);
        val createAudioTrackSourceMethod =
            audioPolicy.javaClass.getDeclaredMethod("createAudioTrackSource", audioMix.javaClass)
        val audioTrack = createAudioTrackSourceMethod.invoke(audioPolicy, audioMix) as AudioTrack
        Objects.requireNonNull(audioTrack)

        audioTrack.play()

        val totalWrite = intArrayOf(0)
        thread {
            while (true) {
                Thread.sleep(1000)
                println("${totalWrite[0]}")
            }
        }

        val buffer = ByteArray(480 * 2 * 2)
        while (true) {
            val read = System.`in`.read(buffer)
            if (read <= 0) {
                break
            }
            audioTrack.write(buffer, 0, read, AudioTrack.WRITE_NON_BLOCKING)
            totalWrite[0] += read;
        }
    }
}