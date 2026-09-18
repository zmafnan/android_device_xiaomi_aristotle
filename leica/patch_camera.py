#!/usr/bin/env python3
"""Patch stock HOS2 camera vendor-key discovery and sign with a dedicated key.

Requires CAMERA_KEYSTORE_PASSWORD in the environment. Keep the keystore private
and reuse it for future camera updates. Does not build the ROM or install APKs.
"""
import argparse
import hashlib
import os
from pathlib import Path
import subprocess
import shutil
import tempfile
import zipfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--top", type=Path, required=True)
parser.add_argument("--stock", type=Path, required=True)
parser.add_argument("--output", type=Path, required=True)
parser.add_argument("--keystore", type=Path, required=True)
args = parser.parse_args()
assert os.environ.get("CAMERA_KEYSTORE_PASSWORD"), "Set CAMERA_KEYSTORE_PASSWORD"
assert hashlib.sha256(args.stock.read_bytes()).hexdigest() == (
    "650dcefe5bf0a463d68e2d5bedb28bf7fcaf9e6476d6c060de3358dfb741522a"
), "Unexpected stock APK: review bytecode before porting this fix"
top = args.top.resolve()
smali = top / "prebuilts/extract-tools/common/smali"
sdk = top / "prebuilts/sdk/tools/linux/bin"

def run(*command):
    subprocess.run([str(x) for x in command], check=True)

work_dir = Path("/home/zmafnan/Project/.work-hos2") if Path("/home/zmafnan/Project/.work-hos2").is_dir() else None
with tempfile.TemporaryDirectory(prefix="aristotle-camera-", dir=work_dir) as tmp:
    work = Path(tmp)
    with zipfile.ZipFile(args.stock) as apk:
        (work / "original.dex").write_bytes(apk.read("classes2.dex"))
        (work / "classes-original.dex").write_bytes(apk.read("classes.dex"))
        (work / "features-original.dex").write_bytes(apk.read("classes3.dex"))

    # 1. Patch classes2.dex
    run("java", "-jar", smali / "baksmali.jar", "d", "-j", "4",
        "-o", work / "smali", work / "original.dex")
    target = work / "smali/ca/c.smali"
    source = target.read_text()
    before = "    invoke-static {}, Lbd/f;->f()Z\n\n    move-result p2\n\n    if-eqz p2, :cond_485"
    after = "    const/4 p2, 0x1\n\n    if-eqz p2, :cond_485"
    assert source.count(before) == 1, "Vendor-key discovery branch changed"
    target.write_text(source.replace(before, after))
    # This APK is bundled exclusively for Xiaomi 13T (aristotle).
    watermark = work / "smali/s9/b.smali"
    text = watermark.read_text()
    model_lookup = "    invoke-virtual {v0}, Ltc/b;->w()Ljava/lang/String;\n\n    move-result-object v2\n\n    invoke-virtual {v0}, Ltc/b;->x()Ljava/lang/String;\n\n    move-result-object v0"
    assert text.count(model_lookup) == 1, "Watermark model provider changed"
    watermark.write_text(text.replace(model_lookup,
        '    const-string v2, "Xiaomi"\n\n    const-string v0, "13T"', 1))
    shot = work / "smali/ca/x1.smali"
    body = shot.read_text()
    assert ".method public final E()V" in body
    guard = "    :cond_43\n    new-instance v1, Ljava/lang/StringBuilder;"
    assert body.count(guard) == 1
    body = body.replace(guard, "    :cond_43\n    iget-object v1, p0, Lca/x1;->P:Ljava/util/concurrent/atomic/AtomicInteger;\n\n    const/4 v4, 0x3\n\n    const/4 v5, 0x7\n\n    invoke-virtual {v1, v4, v5}, Ljava/util/concurrent/atomic/AtomicInteger;->compareAndSet(II)Z\n\n    move-result v1\n\n    if-nez v1, :aristotle_complete_once\n\n    return-void\n\n    :aristotle_complete_once\n    iget-object v5, p0, Lca/w0;->a:Ljava/lang/String;\n\n    new-instance v1, Ljava/lang/StringBuilder;", 1)
    final_image = "    invoke-virtual {p0, p1, v0, v1, p2}, Lca/x1;->H(Lfh/q;Landroid/hardware/camera2/TotalCaptureResult;Landroid/hardware/camera2/CameraCharacteristics;Ljava/lang/String;)V\n\n    goto :goto_d6"
    assert body.count(final_image) == 1
    body = body.replace(final_image, final_image.replace("    goto :goto_d6", "    sget p1, Lca/x1;->S:I\n\n    invoke-virtual {p0, p1}, Lca/x1;->A(I)V\n\n    invoke-virtual {p0}, Lca/x1;->E()V\n\n    goto :goto_d6"), 1)
    shot.write_text(body)
    run("java", "-jar", smali / "smali.jar", "a", "-a", "35", "-j", "4",
        "-o", work / "patched.dex", work / "smali")

    # 2. Patch classes.dex (Codec input surface handling, Live Photo timestamp, and IspInterface JNI protection)
    run("java", "-jar", smali / "baksmali.jar", "d", "-j", "4",
        "-o", work / "classes-smali", work / "classes-original.dex")
    # 2a. oi/d.smali: prevent createInputSurface failure when persistent surface exists
    oid = work / "classes-smali/oi/d.smali"
    oid_text = oid.read_text(encoding="utf-8")
    target_oid = """    invoke-virtual {v2, v4, v6, v6, v5}, Landroid/media/MediaCodec;->configure(Landroid/media/MediaFormat;Landroid/view/Surface;Landroid/media/MediaCrypto;I)V

    invoke-virtual {p0}, Loi/d;->x()Landroid/view/Surface;

    move-result-object v2

    iput-object v2, p0, Loi/d;->D:Landroid/view/Surface;

    iget-object v2, p0, Loi/d;->F:Landroid/view/Surface;

    if-eqz v2, :cond_35

    iget-object v4, p0, Loi/c;->k:Landroid/media/MediaCodec;

    invoke-virtual {v4, v2}, Landroid/media/MediaCodec;->setInputSurface(Landroid/view/Surface;)V"""
    replacement_oid = """    invoke-virtual {v2, v4, v6, v6, v5}, Landroid/media/MediaCodec;->configure(Landroid/media/MediaFormat;Landroid/view/Surface;Landroid/media/MediaCrypto;I)V

    iget-object v2, p0, Loi/d;->F:Landroid/view/Surface;

    if-eqz v2, :cond_use_input_surface

    :try_start_set_input
    iget-object v4, p0, Loi/c;->k:Landroid/media/MediaCodec;

    invoke-virtual {v4, v2}, Landroid/media/MediaCodec;->setInputSurface(Landroid/view/Surface;)V

    iput-object v2, p0, Loi/d;->D:Landroid/view/Surface;
    :try_end_set_input
    .catch Ljava/lang/Exception; {:try_start_set_input .. :try_end_set_input} :catch_surface

    goto :cond_35

    :cond_use_input_surface
    :try_start_create_input
    invoke-virtual {p0}, Loi/d;->x()Landroid/view/Surface;

    move-result-object v2

    iput-object v2, p0, Loi/d;->D:Landroid/view/Surface;
    :try_end_create_input
    .catch Ljava/lang/Exception; {:try_start_create_input .. :try_end_create_input} :catch_surface

    goto :cond_35

    :catch_surface
    move-exception v2

    const-string v4, "CircularMediaRecorder"

    const-string v5, "setup surface failed"

    invoke-static {v4, v5, v2}, Lcom/android/camera/log/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I"""
    assert oid_text.count(target_oid) == 1, "oi/d target not found"
    oid.write_text(oid_text.replace(target_oid, replacement_oid, 1), encoding="utf-8")

    # 2b. ni/b.smali: ensure snapshotTimeUs is always read from capture result timestamp
    nib = work / "classes-smali/ni/b.smali"
    nib_text = nib.read_text(encoding="utf-8")
    target_nib = """    invoke-virtual {v3}, Ltc/b;->a1()Z

    move-result v3"""
    assert nib_text.count(target_nib) == 1, "ni/b target not found"
    nib.write_text(nib_text.replace(target_nib, "    const/4 v3, 0x1", 1), encoding="utf-8")

    # 2c. IspInterface.smali: avoid nativeClassInit crash if loadLibrary fails
    isp = work / "classes-smali/com/xiaomi/camera/isp/IspInterface.smali"
    isp_text = isp.read_text(encoding="utf-8")
    target_isp = """    :catch_14
    move-exception v0

    sget-object v1, Lcom/xiaomi/camera/isp/IspInterface;->TAG:Ljava/lang/String;

    const-string v2, "load library libcamera_ispinterface_jni.xiaomi.so failed"

    invoke-static {v1, v2, v0}, Lcom/xiaomi/engine/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    :goto_1c
    invoke-static {}, Lcom/xiaomi/camera/isp/IspInterface;->nativeClassInit()V

    return-void"""
    replacement_isp = """    :catch_14
    move-exception v0

    sget-object v1, Lcom/xiaomi/camera/isp/IspInterface;->TAG:Ljava/lang/String;

    const-string v2, "load library libcamera_ispinterface_jni.xiaomi.so failed"

    invoke-static {v1, v2, v0}, Lcom/xiaomi/engine/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    return-void

    :goto_1c
    :try_start_native
    invoke-static {}, Lcom/xiaomi/camera/isp/IspInterface;->nativeClassInit()V
    :try_end_native
    .catch Ljava/lang/UnsatisfiedLinkError; {:try_start_native .. :try_end_native} :catch_native

    :catch_native
    return-void"""
    assert isp_text.count(target_isp) == 1, "IspInterface target not found"
    isp.write_text(isp_text.replace(target_isp, replacement_isp, 1), encoding="utf-8")

    run("java", "-jar", smali / "smali.jar", "a", "-a", "35", "-j", "4",
        "-o", work / "classes-patched.dex", work / "classes-smali")

    # 3. Patch classes3.dex (Select V1 recorder path via a1()=false and restore Gyro Shake Stabilizer via Z0()=true)
    run("java", "-jar", smali / "baksmali.jar", "d", "-j", "4",
        "-o", work / "features-smali", work / "features-original.dex")
    features = work / "features-smali/tc/b.smali"
    features_text = features.read_text(encoding="utf-8")
    a1_header = ".method public final a1()Z\n"
    start = features_text.index(a1_header)
    end = features_text.index(".end method", start) + len(".end method")
    new_a1 = """.method public final a1()Z
    .registers 1

    const/4 v0, 0x0

    return v0
.end method"""
    features_text = features_text[:start] + new_a1 + features_text[end:]

    z0_header = ".method public final Z0()Z\n"
    start_z0 = features_text.index(z0_header)
    end_z0 = features_text.index(".end method", start_z0) + len(".end method")
    new_z0 = """.method public final Z0()Z
    .registers 1

    const/4 v0, 0x1

    return v0
.end method"""
    features_text = features_text[:start_z0] + new_z0 + features_text[end_z0:]

    features.write_text(features_text, encoding="utf-8")
    run("java", "-jar", smali / "smali.jar", "a", "-a", "35", "-j", "4",
        "-o", work / "features-patched.dex", work / "features-smali")

    # Package modified DEX files into unsigned APK
    with zipfile.ZipFile(args.stock) as src, zipfile.ZipFile(work / "unsigned.apk", "w") as dst:
        for entry in src.infolist():
            # Remove old JAR signatures; APK signing blocks are not ZIP entries.
            name = entry.filename.upper()
            if name.startswith("META-INF/") and name.endswith((".RSA", ".DSA", ".EC", ".SF", "MANIFEST.MF")):
                continue
            if entry.filename == "classes.dex":
                data = (work / "classes-patched.dex").read_bytes()
            elif entry.filename == "classes2.dex":
                data = (work / "patched.dex").read_bytes()
            elif entry.filename == "classes3.dex":
                data = (work / "features-patched.dex").read_bytes()
            else:
                data = src.read(entry)
            dst.writestr(entry, data)
    run(sdk / "zipalign", "-p", "-f", "4", work / "unsigned.apk", work / "aligned.apk")
    run("java", "-jar", sdk.parent / "lib/apksigner.jar", "sign", "--ks", args.keystore.resolve(),
        "--ks-key-alias", "aristotle-camera", "--ks-pass", "env:CAMERA_KEYSTORE_PASSWORD",
        "--out", work / "signed.apk", work / "aligned.apk")
    run("java", "-jar", sdk.parent / "lib/apksigner.jar", "verify", "--verbose", work / "signed.apk")
    run(sdk / "zipalign", "-c", "-p", "4", work / "signed.apk")
    shutil.move(str(work / "signed.apk"), str(args.output))
