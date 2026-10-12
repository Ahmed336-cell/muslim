# whisper_ggml consumer rules — merged into the R8 configuration of every
# app that depends on this plugin.

# Keep native method names for JNI registration.
-keepclasseswithmembernames class * {
    native <methods>;
}

-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
