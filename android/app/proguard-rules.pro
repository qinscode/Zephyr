# Keep annotations
-keep class com.google.errorprone.annotations.** { *; }
-dontwarn com.google.errorprone.annotations.**

-keep class javax.annotation.** { *; }
-dontwarn javax.annotation.**

-keep class com.google.crypto.tink.** { *; }
-dontwarn com.google.crypto.tink.**

# Keep classes for Google Tink (or other dependencies you are using)
-keep class com.google.crypto.tink.aead.** { *; }
-keep class com.google.crypto.tink.proto.** { *; }

# Keep concurrent annotations
-keep class javax.annotation.concurrent.** { *; }
-dontwarn javax.annotation.concurrent.**