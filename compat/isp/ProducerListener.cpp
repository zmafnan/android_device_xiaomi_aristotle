// SPDX-License-Identifier: Apache-2.0

#include <android/log.h>

// HOS2 libgui's default BnProducerListener callback only logged the slot.
// The ISP JNI blob references that default; Android 16 removed its symbol.
extern "C" void _ZN7android18BnProducerListener16onBufferDetachedEi(void*, int slot) {
    __android_log_print(ANDROID_LOG_ERROR, "IspProducerListener",
                        "Unhandled buffer detach notification: %d", slot);
}
