# Local modifications:
# * removed com.google.android.geo.API_KEY key. This should be added to
#      the manifest files in java/com/android/incallui/calllocation/impl/
#      and /java/com/android/incallui/maps/impl/
# * b/62417801 modify translation string naming convention:
#      $ find . -type d | grep 262 | rename 's/(values)\-([a-zA-Z\+\-]+)\-(mcc262-mnc01)/$1-$3-$2/'
# * b/37077388 temporarily disable proguard with javac
# * b/62875795 include manually generated GRPC service class:
#      $ protoc --plugin=protoc-gen-grpc-java=prebuilts/tools/common/m2/repository/io/grpc/protoc-gen-grpc-java/1.0.3/protoc-gen-grpc-java-1.0.3-linux-x86_64.exe \
#               --grpc-java_out=lite:"packages/apps/Dialer/java/com/android/voicemail/impl/" \
#               --proto_path="packages/apps/Dialer/java/com/android/voicemail/impl/transcribe/grpc/" "packages/apps/Dialer/java/com/android/voicemail/impl/transcribe/grpc/voicemail_transcription.proto"
LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

# The base directory for Dialer sources.
BASE_DIR := java/com/android

# Exclude files incompatible with AOSP.
EXCLUDE_FILES := \
	$(BASE_DIR)/incallui/calllocation/impl/AuthException.java \
	$(BASE_DIR)/incallui/calllocation/impl/CallLocationImpl.java \
	$(BASE_DIR)/incallui/calllocation/impl/CallLocationModule.java \
	$(BASE_DIR)/incallui/calllocation/impl/DownloadMapImageTask.java \
	$(BASE_DIR)/incallui/calllocation/impl/GoogleLocationSettingHelper.java \
	$(BASE_DIR)/incallui/calllocation/impl/HttpFetcher.java \
	$(BASE_DIR)/incallui/calllocation/impl/LocationFragment.java \
	$(BASE_DIR)/incallui/calllocation/impl/LocationHelper.java \
	$(BASE_DIR)/incallui/calllocation/impl/LocationPresenter.java \
	$(BASE_DIR)/incallui/calllocation/impl/LocationUrlBuilder.java \
	$(BASE_DIR)/incallui/calllocation/impl/ReverseGeocodeTask.java \
	$(BASE_DIR)/incallui/calllocation/impl/TrafficStatsTags.java \
	$(BASE_DIR)/incallui/maps/impl/MapsImpl.java \
	$(BASE_DIR)/incallui/maps/impl/MapsModule.java \
	$(BASE_DIR)/incallui/maps/impl/StaticMapFragment.java \

# Exclude testing only class, not used anywhere here
EXCLUDE_FILES += \
	$(BASE_DIR)/contacts/common/format/testing/SpannedTestUtils.java

# Exclude build variants for now
EXCLUDE_FILES += \
	$(BASE_DIR)/dialer/constants/googledialer/ConstantsImpl.java \
	$(BASE_DIR)/dialer/binary/google/GoogleStubDialerRootComponent.java \
	$(BASE_DIR)/dialer/binary/google/GoogleStubDialerApplication.java \

# * b/62875795
ifneq ($(wildcard packages/apps/Dialer/java/com/android/voicemail/impl/com/google/internal/communications/voicemailtranscription/v1/VoicemailTranscriptionServiceGrpc.java),)
$(error Please remove file packages/apps/Dialer/java/com/android/voicemail/impl/com/google/internal/communications/voicemailtranscription/v1/VoicemailTranscriptionServiceGrpc.java )
endif

EXCLUDE_RESOURCE_DIRECTORIES := \
	java/com/android/incallui/maps/impl/res \

# All Dialers resources.
RES_DIRS := $(call all-subdir-named-dirs,res,.)
RES_DIRS := $(filter-out $(EXCLUDE_RESOURCE_DIRECTORIES),$(RES_DIRS))

EXCLUDE_MANIFESTS := \
	$(BASE_DIR)/dialer/binary/aosp/testing/AndroidManifest.xml \
	$(BASE_DIR)/dialer/binary/google/AndroidManifest.xml \
	$(BASE_DIR)/incallui/calllocation/impl/AndroidManifest.xml \
	$(BASE_DIR)/incallui/maps/impl/AndroidManifest.xml \

# Dialer manifest files to merge.
DIALER_MANIFEST_FILES := $(call all-named-files-under,AndroidManifest.xml,.)
DIALER_MANIFEST_FILES := $(filter-out $(EXCLUDE_MANIFESTS),$(DIALER_MANIFEST_FILES))

# Merge all manifest files.
LOCAL_FULL_LIBS_MANIFEST_FILES := \
	$(addprefix $(LOCAL_PATH)/, $(DIALER_MANIFEST_FILES))

LOCAL_SRC_FILES := $(call all-java-files-under, $(BASE_DIR))
LOCAL_SRC_FILES += $(call all-proto-files-under, $(BASE_DIR))
LOCAL_SRC_FILES := $(filter-out $(EXCLUDE_FILES),$(LOCAL_SRC_FILES))

LOCAL_PROTOC_FLAGS := --proto_path=$(LOCAL_PATH)

LOCAL_RESOURCE_DIR := $(addprefix $(LOCAL_PATH)/, $(RES_DIRS))

EXCLUDE_EXTRA_PACKAGES := \
	com.android.dialer.binary.aosp.testing \
	com.android.dialer.binary.google \
	com.android.incallui.calllocation.impl \
	com.android.incallui.maps.impl \

# We specify each package explicitly to glob resource files.
include ${LOCAL_PATH}/packages.mk

LOCAL_AAPT_FLAGS := $(filter-out $(EXCLUDE_EXTRA_PACKAGES),$(LOCAL_AAPT_FLAGS))
LOCAL_AAPT_FLAGS := $(addprefix --extra-packages , $(LOCAL_AAPT_FLAGS))
LOCAL_AAPT_FLAGS += \
	--auto-add-overlay \
	--extra-packages me.leolin.shortcutbadger \

LOCAL_STATIC_JAVA_LIBRARIES := \
	android-common \
	android-support-dynamic-animation \
	com.android.vcard \
	dialer-commons-io-target \
	dialer-dagger2-target \
	dialer-disklrucache-target \
	dialer-gifdecoder-target \
	dialer-glide-target \
	dialer-grpc-all-target \
	dialer-grpc-context-target \
	dialer-grpc-core-target \
	dialer-grpc-okhttp-target \
	dialer-grpc-protobuf-lite-target \
	dialer-grpc-stub-target \
	dialer-javax-annotation-api-target \
	dialer-javax-inject-target \
	dialer-libshortcutbadger-target \
	dialer-mime4j-core-target \
	dialer-mime4j-dom-target \
	dialer-error-prone-target \
	dialer-guava-target \
	jsr305 \
	libbackup \
	libphonenumber \
	volley \

LOCAL_STATIC_ANDROID_LIBRARIES := \
	android-support-core-ui \
	android-support-design \
	android-support-transition \
	android-support-v13 \
	android-support-v4 \
	android-support-v7-appcompat \
	android-support-v7-cardview \
	android-support-v7-recyclerview \

LOCAL_JAVA_LIBRARIES := \
	dialer-auto-value-target \
	org.apache.http.legacy \

LOCAL_ANNOTATION_PROCESSORS := \
	dialer-auto-value \
	dialer-dagger2 \
	dialer-dagger2-compiler \
	dialer-dagger2-producers \
	dialer-guava \
	dialer-javax-annotation-api \
	dialer-javax-inject \

LOCAL_ANNOTATION_PROCESSOR_CLASSES := \
  com.google.auto.value.processor.AutoValueProcessor,dagger.internal.codegen.ComponentProcessor


# Begin Bug: 37077388
LOCAL_DX_FLAGS := --multi-dex
LOCAL_JACK_FLAGS := --multi-dex native

LOCAL_PROGUARD_ENABLED := disabled
ifdef LOCAL_JACK_ENABLED


# Proguard includes
LOCAL_PROGUARD_FLAG_FILES := $(call all-named-files-under,proguard.*flags,$(BASE_DIR))
LOCAL_PROGUARD_ENABLED := custom

LOCAL_PROGUARD_ENABLED += optimization
endif

# End Bug: 37077388

LOCAL_SDK_VERSION := system_current
LOCAL_MODULE_TAGS := optional
LOCAL_PACKAGE_NAME := Dialer
LOCAL_CERTIFICATE := shared
LOCAL_PRIVILEGED_MODULE := true
LOCAL_USE_AAPT2 := true

# b/37483961 - Jack Not Compiling Dagger Class Properly
LOCAL_JACK_ENABLED := javac_frontend

include $(BUILD_PACKAGE)

# Cleanup local state
BASE_DIR :=
EXCLUDE_FILES :=
RES_DIRS :=
DIALER_MANIFEST_FILES :=
EXCLUDE_MANIFESTS :=
EXCLUDE_EXTRA_PACKAGES :=

# Create references to prebuilt libraries.
include $(CLEAR_VARS)

LOCAL_PREBUILT_STATIC_JAVA_LIBRARIES := \
    dialer-auto-value:../../../prebuilts/tools/common/m2/repository/com/google/auto/value/auto-value/1.3/auto-value-1.3$(COMMON_JAVA_PACKAGE_SUFFIX) \
    dialer-dagger2-compiler:../../../prebuilts/tools/common/m2/repository/com/google/dagger/dagger-compiler/2.7/dagger-compiler-2.7$(COMMON_JAVA_PACKAGE_SUFFIX) \
    dialer-dagger2:../../../prebuilts/tools/common/m2/repository/com/google/dagger/dagger/2.7/dagger-2.7$(COMMON_JAVA_PACKAGE_SUFFIX) \
    dialer-dagger2-producers:../../../prebuilts/tools/common/m2/repository/com/google/dagger/dagger-producers/2.7/dagger-producers-2.7$(COMMON_JAVA_PACKAGE_SUFFIX) \
    dialer-grpc-all:../../../prebuilts/tools/common/m2/repository/io/grpc/grpc-all/1.0.3/grpc-all-1.0.3$(COMMON_JAVA_PACKAGE_SUFFIX) \
    dialer-grpc-core:../../../prebuilts/tools/common/m2/repository/io/grpc/grpc-core/1.0.3/grpc-core-1.0.3$(COMMON_JAVA_PACKAGE_SUFFIX) \
    dialer-grpc-okhttp:../../../prebuilts/tools/common/m2/repository/io/grpc/grpc-okhttp/1.0.3/grpc-okhttp-1.0.3$(COMMON_JAVA_PACKAGE_SUFFIX) \
    dialer-grpc-protobuf-lite:../../../prebuilts/tools/common/m2/repository/io/grpc/grpc-protobuf-lite/1.0.3/grpc-protobuf-lite-1.0.3$(COMMON_JAVA_PACKAGE_SUFFIX) \
    dialer-grpc-stub:../../../prebuilts/tools/common/m2/repository/io/grpc/grpc-stub/1.0.3/grpc-stub-1.0.3$(COMMON_JAVA_PACKAGE_SUFFIX) \
    dialer-guava:../../../prebuilts/tools/common/m2/repository/com/google/guava/guava/20.0/guava-20.0$(COMMON_JAVA_PACKAGE_SUFFIX) \
    dialer-javax-annotation-api:../../../prebuilts/tools/common/m2/repository/javax/annotation/javax.annotation-api/1.2/javax.annotation-api-1.2$(COMMON_JAVA_PACKAGE_SUFFIX) \
    dialer-javax-inject:../../../prebuilts/tools/common/m2/repository/javax/inject/javax.inject/1/javax.inject-1$(COMMON_JAVA_PACKAGE_SUFFIX)

include $(BUILD_HOST_PREBUILT)

# Enumerate target prebuilts to avoid linker warnings like
# Dialer (java:sdk) should not link to dialer-guava (java:platform)
include $(CLEAR_VARS)

LOCAL_MODULE_CLASS := JAVA_LIBRARIES
LOCAL_MODULE := dialer-guava-target
LOCAL_SDK_VERSION := current
LOCAL_SRC_FILES := ../../../prebuilts/tools/common/m2/repository/com/google/guava/guava/20.0/guava-20.0$(COMMON_JAVA_PACKAGE_SUFFIX)
LOCAL_UNINSTALLABLE_MODULE := true

include $(BUILD_PREBUILT)

include $(CLEAR_VARS)

LOCAL_MODULE_CLASS := JAVA_LIBRARIES
LOCAL_MODULE := dialer-error-prone-target
LOCAL_SDK_VERSION := current
LOCAL_SRC_FILES := ../../../prebuilts/tools/common/m2/repository/com/google/errorprone/error_prone_annotations/2.0.18/error_prone_annotations-2.0.18$(COMMON_JAVA_PACKAGE_SUFFIX)
LOCAL_UNINSTALLABLE_MODULE := true

include $(BUILD_PREBUILT)

include $(CLEAR_VARS)

LOCAL_MODULE_CLASS := JAVA_LIBRARIES
LOCAL_MODULE := dialer-dagger2-target
LOCAL_SDK_VERSION := current
LOCAL_SRC_FILES := ../../../prebuilts/tools/common/m2/repository/com/google/dagger/dagger/2.7/dagger-2.7$(COMMON_JAVA_PACKAGE_SUFFIX)
LOCAL_UNINSTALLABLE_MODULE := true

include $(BUILD_PREBUILT)

include $(CLEAR_VARS)

LOCAL_MODULE_CLASS := JAVA_LIBRARIES
LOCAL_MODULE := dialer-disklrucache-target
LOCAL_SDK_VERSION := current
LOCAL_SRC_FILES := ../../../prebuilts/maven_repo/bumptech/com/github/bumptech/glide/disklrucache/SNAPSHOT/disklrucache-SNAPSHOT$(COMMON_JAVA_PACKAGE_SUFFIX)
LOCAL_UNINSTALLABLE_MODULE := true

include $(BUILD_PREBUILT)

include $(CLEAR_VARS)

LOCAL_MODULE_CLASS := JAVA_LIBRARIES
LOCAL_MODULE := dialer-gifdecoder-target
LOCAL_SDK_VERSION := current
LOCAL_SRC_FILES := ../../../prebuilts/maven_repo/bumptech/com/github/bumptech/glide/gifdecoder/SNAPSHOT/gifdecoder-SNAPSHOT$(COMMON_JAVA_PACKAGE_SUFFIX)
LOCAL_UNINSTALLABLE_MODULE := true

include $(BUILD_PREBUILT)

include $(CLEAR_VARS)

LOCAL_MODULE_CLASS := JAVA_LIBRARIES
LOCAL_MODULE := dialer-glide-target
LOCAL_SDK_VERSION := current
LOCAL_SRC_FILES := ../../../prebuilts/maven_repo/bumptech/com/github/bumptech/glide/glide/SNAPSHOT/glide-SNAPSHOT$(COMMON_JAVA_PACKAGE_SUFFIX)
LOCAL_UNINSTALLABLE_MODULE := true

include $(BUILD_PREBUILT)

include $(CLEAR_VARS)

LOCAL_MODULE_CLASS := JAVA_LIBRARIES
LOCAL_MODULE := dialer-javax-annotation-api-target
LOCAL_SDK_VERSION := current
LOCAL_SRC_FILES := ../../../prebuilts/tools/common/m2/repository/javax/annotation/javax.annotation-api/1.2/javax.annotation-api-1.2$(COMMON_JAVA_PACKAGE_SUFFIX)
LOCAL_UNINSTALLABLE_MODULE := true

include $(BUILD_PREBUILT)

include $(CLEAR_VARS)

LOCAL_MODULE_CLASS := JAVA_LIBRARIES
LOCAL_MODULE := dialer-libshortcutbadger-target
LOCAL_SDK_VERSION := current
LOCAL_SRC_FILES := ../../../prebuilts/tools/common/m2/repository/me/leolin/ShortcutBadger/1.1.13/ShortcutBadger-1.1.13$(COMMON_JAVA_PACKAGE_SUFFIX)
LOCAL_UNINSTALLABLE_MODULE := true

include $(BUILD_PREBUILT)

include $(CLEAR_VARS)

LOCAL_MODULE_CLASS := JAVA_LIBRARIES
LOCAL_MODULE := dialer-javax-inject-target
LOCAL_SDK_VERSION := current
LOCAL_SRC_FILES := ../../../prebuilts/tools/common/m2/repository/javax/inject/javax.inject/1/javax.inject-1$(COMMON_JAVA_PACKAGE_SUFFIX)
LOCAL_UNINSTALLABLE_MODULE := true

include $(BUILD_PREBUILT)

include $(CLEAR_VARS)

LOCAL_MODULE_CLASS := JAVA_LIBRARIES
LOCAL_MODULE := dialer-commons-io-target
LOCAL_SDK_VERSION := current
LOCAL_SRC_FILES := ../../../prebuilts/tools/common/m2/repository/commons-io/commons-io/2.4/commons-io-2.4$(COMMON_JAVA_PACKAGE_SUFFIX)
LOCAL_UNINSTALLABLE_MODULE := true

include $(BUILD_PREBUILT)

include $(CLEAR_VARS)

LOCAL_MODULE_CLASS := JAVA_LIBRARIES
LOCAL_MODULE := dialer-mime4j-core-target
LOCAL_SDK_VERSION := current
LOCAL_SRC_FILES := ../../../prebuilts/tools/common/m2/repository/org/apache/james/apache-mime4j-core/0.7.2/apache-mime4j-core-0.7.2$(COMMON_JAVA_PACKAGE_SUFFIX)
LOCAL_UNINSTALLABLE_MODULE := true

include $(BUILD_PREBUILT)

include $(CLEAR_VARS)

LOCAL_MODULE_CLASS := JAVA_LIBRARIES
LOCAL_MODULE := dialer-mime4j-dom-target
LOCAL_SDK_VERSION := current
LOCAL_SRC_FILES := ../../../prebuilts/tools/common/m2/repository/org/apache/james/apache-mime4j-dom/0.7.2/apache-mime4j-dom-0.7.2$(COMMON_JAVA_PACKAGE_SUFFIX)
LOCAL_UNINSTALLABLE_MODULE := true

include $(BUILD_PREBUILT)

include $(CLEAR_VARS)

LOCAL_MODULE_CLASS := JAVA_LIBRARIES
LOCAL_MODULE := dialer-grpc-core-target
LOCAL_SDK_VERSION := current
LOCAL_SRC_FILES := ../../../prebuilts/tools/common/m2/repository/io/grpc/grpc-core/1.0.3/grpc-core-1.0.3$(COMMON_JAVA_PACKAGE_SUFFIX)
LOCAL_UNINSTALLABLE_MODULE := true

include $(BUILD_PREBUILT)

include $(CLEAR_VARS)

LOCAL_MODULE_CLASS := JAVA_LIBRARIES
LOCAL_MODULE := dialer-grpc-okhttp-target
LOCAL_SDK_VERSION := current
LOCAL_SRC_FILES := ../../../prebuilts/tools/common/m2/repository/io/grpc/grpc-okhttp/1.0.3/grpc-okhttp-1.0.3$(COMMON_JAVA_PACKAGE_SUFFIX)
LOCAL_UNINSTALLABLE_MODULE := true

include $(BUILD_PREBUILT)

include $(CLEAR_VARS)

LOCAL_MODULE_CLASS := JAVA_LIBRARIES
LOCAL_MODULE := dialer-grpc-protobuf-lite-target
LOCAL_SDK_VERSION := current
LOCAL_SRC_FILES := ../../../prebuilts/tools/common/m2/repository/io/grpc/grpc-protobuf-lite/1.0.3/grpc-protobuf-lite-1.0.3$(COMMON_JAVA_PACKAGE_SUFFIX)
LOCAL_UNINSTALLABLE_MODULE := true

include $(BUILD_PREBUILT)

include $(CLEAR_VARS)

LOCAL_MODULE_CLASS := JAVA_LIBRARIES
LOCAL_MODULE := dialer-grpc-stub-target
LOCAL_SDK_VERSION := current
LOCAL_SRC_FILES := ../../../prebuilts/tools/common/m2/repository/io/grpc/grpc-stub/1.0.3/grpc-stub-1.0.3$(COMMON_JAVA_PACKAGE_SUFFIX)
LOCAL_UNINSTALLABLE_MODULE := true

include $(BUILD_PREBUILT)

include $(CLEAR_VARS)

LOCAL_MODULE_CLASS := JAVA_LIBRARIES
LOCAL_MODULE := dialer-grpc-all-target
LOCAL_SDK_VERSION := current
LOCAL_SRC_FILES := ../../../prebuilts/tools/common/m2/repository/io/grpc/grpc-all/1.0.3/grpc-all-1.0.3$(COMMON_JAVA_PACKAGE_SUFFIX)
LOCAL_UNINSTALLABLE_MODULE := true

include $(BUILD_PREBUILT)

include $(CLEAR_VARS)

LOCAL_MODULE_CLASS := JAVA_LIBRARIES
LOCAL_MODULE := dialer-grpc-context-target
LOCAL_SDK_VERSION := current
LOCAL_SRC_FILES := ../../../prebuilts/tools/common/m2/repository/io/grpc/grpc-context/1.0.3/grpc-context-1.0.3$(COMMON_JAVA_PACKAGE_SUFFIX)
LOCAL_UNINSTALLABLE_MODULE := true

include $(BUILD_PREBUILT)

include $(CLEAR_VARS)

LOCAL_MODULE_CLASS := JAVA_LIBRARIES
LOCAL_MODULE := dialer-auto-value-target
LOCAL_SDK_VERSION := current
LOCAL_SRC_FILES := ../../../prebuilts/tools/common/m2/repository/com/google/auto/value/auto-value/1.3/auto-value-1.3$(COMMON_JAVA_PACKAGE_SUFFIX)
LOCAL_UNINSTALLABLE_MODULE := true

include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
