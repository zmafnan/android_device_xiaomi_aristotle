# Aristotle HOS2 Leica integration

The bundled APK enumerates all vendor keys in CameraCapabilities on this AOSP ROM, as it does on stock. The original non-MIUI branch enumerates only capture request keys, incorrectly rejecting characteristic-only ispMetaSizeForYuv/Raw. This leaves the tuning ImageReader null and causes OfflineSingleYuvShot to stop after the first shutter tap.

Reproduce with patch_camera.py --top <ROM source> --stock <original HOS2 MiuiCamera.apk> --output <VT>/leica/MiuiCamera.apk --keystore <private keystore>, with CAMERA_KEYSTORE_PASSWORD in the environment. Required key alias: aristotle-camera. The script checks the exact stock APK hash, changes only vendor-key discovery, preserves other ZIP payloads, aligns and signs the APK. This is APK repackaging, not a ROM build.

Keep the signing keystore private and back it up; never commit it. Reuse the same key for subsequent updates. The Android.bp module stays presigned/preprocessed and uses no platform signature. Official Xiaomi-signed APK updates cannot replace this custom-signed APK. An installed Xiaomi-signed /data update must be removed before testing the system version; user data migration/removal requires a deliberate user action.

This correction targets the null tuning ImageReader. It does not fix the separate empty offline session/duplicate surface failure when switching styles. Runtime photo saving and camera startup still need testing after server build and manual flash.

The final-image path also completes the capture state when the BGService completion notification is missing. Completion uses an atomic compare-and-set guard per shot to prevent duplicate completion when the vendor callback arrives later. The capture-start requirement and existing failure timeout remain. Validate normal photo, HDR/night, rapid repeated photos and immediate gallery navigation on-device.

Watermark styles receive the device-specific brand/model pair Xiaomi / 13T from s9/b, avoiding missing internal model configuration on AOSP. This APK must only be bundled on Aristotle.

Live Photo uses the stock V1 recorder and rendering architecture on Aristotle.
The V2 persistent-surface path (`ni/c` + `oi/e`) failed in MediaCodec.setInputSurface
due to lack of persistent input surface support on the MTK Dimensity 8200 AVC encoder.
The feature flag `tc/b->a1()Z` in `classes3.dex` is patched to return `false` to uniformly
select the working V1 circular recorder pipeline (`ni/b` + `oi/d`).
In addition, `tc/b->Z0()Z` is decoupled from `a1()` and returns `true`, ensuring the
gyroscope motion stabilizer (`ni/l` / `CaptureModule`) remains active so motion is smooth.
In `classes.dex`, `ni/b` always uses the capture timestamp (`fh/q.e`) so the 1.5s video
window is centered directly on the shutter click moment, `oi/d` safely handles input surfaces
to prevent `-EINVAL (-22)` crashes in `VideoEncodingThread`, and `IspInterface` is protected
against `UnsatisfiedLinkError` when loaded outside the system partition.


