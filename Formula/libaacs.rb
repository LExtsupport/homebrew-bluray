class Libaacs < Formula
  desc "Implements the Advanced Access Content System specification"
  homepage "https://www.videolan.org/developers/libaacs.html"
  url "https://get.videolan.org/libaacs/0.11.1/libaacs-0.11.1.tar.bz2"
  mirror "https://download.videolan.org/pub/videolan/libaacs/0.11.1/libaacs-0.11.1.tar.bz2"
  sha256 "a88aa0ebe4c98a77f7aeffd92ab3ef64ac548c6b822e8248a8b926725bea0a39"
  license "LGPL-2.1-or-later"
  revision 1

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "bison" => :build
  depends_on "libtool" => :build
  depends_on "pkgconf" => :build
  depends_on :macos
  depends_on "libgcrypt"
  depends_on "libgpg-error"

  uses_from_macos "flex" => :build

  # Use Apple CommonCrypto for the hot AES operations, preserving the public API.
  # Rebuild the generated build scripts for current macOS toolchains.
  patch :DATA

  def install
    system "./bootstrap"
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <libaacs/aacs.h>
      #include <stdio.h>
      int main(void) {
        int major = 0, minor = 0, micro = 0;
        aacs_get_version(&major, &minor, &micro);
        AACS *handle = aacs_init();
        if (!handle) return 1;
        aacs_set_key_caching(handle, 0);
        aacs_close(handle);
        printf("%d.%d.%d", major, minor, micro);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-laacs", "-o", "test"
    assert_equal "0.11.1", shell_output("./test").strip
  end
end
__END__
diff --git a/src/devtools/read_file.h b/src/devtools/read_file.h
index 953b2ef..d218417 100644
--- a/src/devtools/read_file.h
+++ b/src/devtools/read_file.h
@@ -20,6 +20,7 @@
 #include <stdio.h>
 #include <stdlib.h>
 #include <errno.h>
+#include <sys/types.h>

 static size_t _read_file(const char *name, off_t min_size, off_t max_size, uint8_t **pdata)
 {

--- a/src/libaacs/crypto.c
+++ b/src/libaacs/crypto.c
@@ -34,6 +34,7 @@
 #endif
 
 #include <gcrypt.h>
+#include <CommonCrypto/CommonCryptor.h>
 
 #ifdef HAVE_PTHREAD_H
 #if GCRYPT_VERSION_NUMBER < 0x010600
@@ -149,21 +150,11 @@
 
 int crypto_aes128e(const uint8_t *key, const uint8_t *data, uint8_t *dst)
 {
-    gcry_cipher_hd_t gcry_h;
-    gcry_error_t err;
-
-    err = gcry_cipher_open(&gcry_h, GCRY_CIPHER_AES, GCRY_CIPHER_MODE_ECB, 0);
-    if (err)
-        return err;
-
-    err = gcry_cipher_setkey(gcry_h, key, 16);
-    if (err)
-        goto error;
-    err = gcry_cipher_encrypt(gcry_h, dst, 16, data, data ? 16 : 0);
-
- error:
-    gcry_cipher_close(gcry_h);
-    return err;
+    size_t written = 0;
+    CCCryptorStatus err = CCCrypt(kCCEncrypt, kCCAlgorithmAES, kCCOptionECBMode,
+                                 key, 16, NULL, data ? data : dst, 16,
+                                 dst, 16, &written);
+    return (err == kCCSuccess && written == 16) ? 0 : GPG_ERR_GENERAL;
 }
 
 int crypto_aes128d(const uint8_t *key, const uint8_t *data, uint8_t *dst)
@@ -273,26 +264,14 @@
 
 int crypto_aacs_decrypt(const uint8_t *key, uint8_t *out, size_t out_size, const uint8_t *in, size_t in_size)
 {
-    static const uint8_t aacs_iv[16]   = { 0x0b, 0xa0, 0xf8, 0xdd, 0xfe, 0xa6, 0x1f, 0xb3,
-                                           0xd8, 0xdf, 0x9f, 0x56, 0x6a, 0x05, 0x0f, 0x78 };
-    gcry_cipher_hd_t gcry_h;
-    gcry_error_t err;
-
-    err = gcry_cipher_open(&gcry_h, GCRY_CIPHER_AES, GCRY_CIPHER_MODE_CBC, 0);
-    if (err)
-        return err;
-
-    err = gcry_cipher_setkey(gcry_h, key, 16);
-    if (err)
-      goto error;
-    err = gcry_cipher_setiv(gcry_h, aacs_iv, 16);
-    if (err)
-      goto error;
-    err = gcry_cipher_decrypt(gcry_h, out, out_size, in, in_size);
-
- error:
-    gcry_cipher_close(gcry_h);
-    return err;
+    static const uint8_t aacs_iv[16] = { 0x0b, 0xa0, 0xf8, 0xdd, 0xfe, 0xa6, 0x1f, 0xb3,
+                                         0xd8, 0xdf, 0x9f, 0x56, 0x6a, 0x05, 0x0f, 0x78 };
+    const uint8_t *src = in ? in : out;
+    size_t count = in ? in_size : out_size;
+    size_t written = 0;
+    CCCryptorStatus err = CCCrypt(kCCDecrypt, kCCAlgorithmAES, 0, key, 16,
+                                 aacs_iv, src, count, out, out_size, &written);
+    return (err == kCCSuccess && written == count) ? 0 : GPG_ERR_GENERAL;
 }
 
 /*
