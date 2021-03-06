class Atk < Formula
  desc "GNOME accessibility toolkit"
  homepage "https://library.gnome.org/devel/atk/"
  url "https://download.gnome.org/sources/atk/2.32/atk-2.32.0.tar.xz"
  sha256 "cb41feda7fe4ef0daa024471438ea0219592baf7c291347e5a858bb64e4091cc"

  bottle do
    root_url "https://linuxbrew.bintray.com/bottles"
    sha256 "5e3a66f66762eae4e829d5e662ed1bbb1d0b63baed920b0b64caa572de0845e1" => :mojave
    sha256 "d9c89c25ee886688210df699bbe927caed15c889cdae2275226f95aa5650dd60" => :high_sierra
    sha256 "bb1e2e364be687253ed0d2d12f1add25e8f6df14511e4682b4cd707ce214836d" => :sierra
    sha256 "8bf284ae0564cdf2c34dbc311d4005b90787b4d4be5e7ac12c018072f75cff3c" => :x86_64_linux
  end

  depends_on "gobject-introspection" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "glib"

  def install
    mkdir "build" do
      system "meson", "--prefix=#{prefix}", *("--libdir=#{lib}" unless OS.mac?), ".."
      system "ninja"
      system "ninja", "install"
    end
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <atk/atk.h>

      int main(int argc, char *argv[]) {
        const gchar *version = atk_get_version();
        return 0;
      }
    EOS
    gettext = Formula["gettext"]
    glib = Formula["glib"]
    flags = %W[
      -I#{gettext.opt_include}
      -I#{glib.opt_include}/glib-2.0
      -I#{glib.opt_lib}/glib-2.0/include
      -I#{include}/atk-1.0
      -L#{gettext.opt_lib}
      -L#{glib.opt_lib}
      -L#{lib}
      -latk-1.0
      -lglib-2.0
      -lgobject-2.0
    ]
    flags << "-lintl" if OS.mac?
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end
