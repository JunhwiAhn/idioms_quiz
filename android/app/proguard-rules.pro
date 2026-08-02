# Flutter's embedding registers plugins and deferred components by reflection,
# so its entry points must survive shrinking.
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Play Core is referenced by Flutter's deferred-components code paths but is not
# bundled in this app; without this R8 fails on the missing references.
-dontwarn com.google.android.play.core.**

# google_mobile_ads / Play Services Ads resolve mediation adapters by name.
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.**

# The jni package binds native symbols reflectively.
-keep class com.github.dart_lang.jni.** { *; }
