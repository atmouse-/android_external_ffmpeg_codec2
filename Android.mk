#
# Copyright (C) 2022 Michael Goffioul <michael.goffioul@gmail.com>
# Copyright (C) 2023 KonstaKANG
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := android.hardware.media.c2@1.2-service-ffmpeg
LOCAL_MODULE_TAGS := optional
LOCAL_PROPRIETARY_MODULE := true
LOCAL_MODULE_RELATIVE_PATH := hw
LOCAL_VINTF_FRAGMENTS := android.hardware.media.c2@1.2-service-ffmpeg.xml
LOCAL_INIT_RC := android.hardware.media.c2@1.2-service-ffmpeg.rc

LOCAL_REQUIRED_MODULES := \
    android.hardware.media.c2@1.2-ffmpeg.policy \
    media_codecs_ffmpeg_c2.xml

LOCAL_SRC_FILES := \
    C2FFMPEGAudioDecodeComponent.cpp \
    C2FFMPEGAudioDecodeInterface.cpp \
    C2FFMPEGVideoDecodeComponent.cpp \
    C2FFMPEGVideoDecodeInterface.cpp \
    C2FFMPEGVideoUtils.cpp \
    service.cpp

LOCAL_SHARED_LIBRARIES := \
    android.hardware.media.c2@1.2 \
    libavcodec \
    libavutil \
    libavservices_minijail \
    libbase \
    libbinder \
    libcodec2_hidl@1.2 \
    libcodec2_soft_common \
    libcodec2_vndk \
    libffmpeg_utils \
    libhidlbase \
    liblog \
    libstagefright_foundation \
    libswresample \
    libswscale \
    libutils

FFMPEG_ARCH := $(TARGET_ARCH)

FFMPEG_2ND_ARCH := false
ifneq ($(TARGET_2ND_ARCH_VARIANT),)
   ifeq ($(FFMPEG_MULTILIB),32)
      FFMPEG_2ND_ARCH := true
   endif
endif

ifeq ($(FFMPEG_2ND_ARCH), true)
    FFMPEG_ARCH := $(TARGET_2ND_ARCH)
endif

ifeq ($(FFMPEG_ARCH),arm64)
    FFMPEG_ARCH := aarch64
endif

FFMPEG_ARCH_VARIANT := $(TARGET_ARCH_VARIANT)
ifeq ($(FFMPEG_2ND_ARCH), true)
   FFMPEG_ARCH_VARIANT := $(TARGET_2ND_ARCH_VARIANT)
endif

ifneq ($(filter x86 x86_64, $(FFMPEG_ARCH)),)
    TARGET_CONFIG := config-$(FFMPEG_ARCH)-$(FFMPEG_ARCH_VARIANT).h
    TARGET_CONFIG_ASM := config-$(FFMPEG_ARCH).asm
else
    TARGET_CONFIG := config-$(FFMPEG_ARCH_VARIANT).h
    TARGET_CONFIG_ASM := config-$(FFMPEG_ARCH_VARIANT).asm
endif

LOCAL_CFLAGS := \
    -DTARGET_CONFIG=\"$(TARGET_CONFIG)\"

include $(BUILD_EXECUTABLE)

include $(CLEAR_VARS)
LOCAL_MODULE := android.hardware.media.c2@1.2-ffmpeg.policy
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_PROPRIETARY_MODULE := true
LOCAL_MODULE_RELATIVE_PATH := seccomp_policy
LOCAL_SRC_FILES_x86 := seccomp_policy/android.hardware.media.c2@1.2-ffmpeg-x86.policy
LOCAL_SRC_FILES_x86_64 := seccomp_policy/android.hardware.media.c2@1.2-ffmpeg-x86_64.policy
LOCAL_SRC_FILES_arm := seccomp_policy/android.hardware.media.c2@1.2-ffmpeg-arm.policy
LOCAL_SRC_FILES_arm64 := seccomp_policy/android.hardware.media.c2@1.2-ffmpeg-arm64.policy
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := media_codecs_ffmpeg_c2.xml
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_PROPRIETARY_MODULE := true
LOCAL_SRC_FILES := media_codecs_ffmpeg_c2.xml
include $(BUILD_PREBUILT)

include $(call all-makefiles-under,$(LOCAL_PATH))
