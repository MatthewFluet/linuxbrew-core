class Gmp < Formula
  desc "GNU multiple precision arithmetic library"
  homepage "https://gmplib.org/"
  url "https://gmplib.org/download/gmp/gmp-6.1.2.tar.xz"
  mirror "https://ftp.gnu.org/gnu/gmp/gmp-6.1.2.tar.xz"
  sha256 "87b565e89a9a684fe4ebeeddb8399dce2599f9c9049854ca8c0dfbdea0e21912"
  revision 2

  bottle do
    cellar :any
    sha256 "8372dcd88e36997d7aacaffb555709348cc2c57703608b3471cbd71f5054f9ed" => :high_sierra
    sha256 "087052cc1b49f5e0c42f5bd54f463f7fca7f7c73f00856c576706112bbe2a4c1" => :sierra
    sha256 "d8f9b3e4da4241dc5996f318df44d99a45db1bcce84a4ce814e8a8912d4cdaef" => :el_capitan
    sha256 "bbe7a837bc882cfb9a79c7e0f11130787058f19c5739ffe83e660dd88587d9b9" => :x86_64_linux
  end

  depends_on "m4" => :build unless OS.mac?

  def install
    # Enable --with-pic to avoid linking issues with the static library
    args = %W[--prefix=#{prefix} --enable-cxx --with-pic]

    if OS.mac?
      args << "--build=core2-apple-darwin#{`uname -r`.to_i}" if build.bottle?
    else
      args << "--build=core2-linux-gnu" if build.bottle?
      args << "ABI=32" if Hardware::CPU.intel? && Hardware::CPU.is_32_bit?
    end

    system "./configure", *args
    system "make"
    system "make", "check"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <gmp.h>
      #include <stdlib.h>

      int main() {
        mpz_t i, j, k;
        mpz_init_set_str (i, "1a", 16);
        mpz_init (j);
        mpz_init (k);
        mpz_sqrtrem (j, k, i);
        if (mpz_get_si (j) != 5 || mpz_get_si (k) != 1) abort();
        return 0;
      }
    EOS

    system ENV.cc, "test.c", "-L#{lib}", "-lgmp", "-o", "test"
    system "./test"

    # Test the static library to catch potential linking issues
    system ENV.cc, "test.c", "#{lib}/libgmp.a", "-o", "test"
    system "./test"
  end
end
