# Keep only necessary classes from BouncyCastle while allowing optimization
-keep class org.bouncycastle.** { *; }
-dontwarn org.bouncycastle.jsse.BCSSLParameters
-dontwarn org.bouncycastle.jsse.BCSSLSocket
-dontwarn org.bouncycastle.jsse.provider.BouncyCastleJsseProvider

# Keep only necessary classes from Conscrypt while allowing optimization
-keep class org.conscrypt.** { *; }
-dontwarn org.conscrypt.Conscrypt$Version
-dontwarn org.conscrypt.Conscrypt
-dontwarn org.conscrypt.ConscryptHostnameVerifier

# Keep only necessary classes from OpenJSSE while allowing optimization
-keep class org.openjsse.** { *; }
-dontwarn org.openjsse.javax.net.ssl.SSLParameters
-dontwarn org.openjsse.javax.net.ssl.SSLSocket
-dontwarn org.openjsse.net.ssl.OpenJSSE