class Libnice < Formula
  desc "GLib ICE implementation"
  homepage "https://wiki.freedesktop.org/nice/"
  url "https://nice.freedesktop.org/releases/libnice-0.1.16.tar.gz"
  sha256 "06b678066f94dde595a4291588ed27acd085ee73775b8c4e8399e28c01eeefdf"

  bottle do
    root_url "https://linuxbrew.bintray.com/bottles"
    cellar :any
    sha256 "a6f40364eb17b24ca46d91403c6dddd7c9035a82fef8dcb4dd4d2699751a6507" => :mojave
    sha256 "aa5e65f90714052f77886dd5bcdf6996fc1fd469a8457225a9a236268bd1651e" => :high_sierra
    sha256 "05cd1daa6254aeefef36744fb141bbb41253046d1ccdba7ee81fcff48a4e029c" => :sierra
    sha256 "5a5f47c3a8d6a7a3dcea9e4baf485c3e5fa02a347bd887e69d0f28621c8ab900" => :x86_64_linux
  end

  depends_on "pkg-config" => :build
  depends_on "glib"
  depends_on "gnutls"
  depends_on "gstreamer"
  depends_on "intltool" => :build unless OS.mac?

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    # Based on https://github.com/libnice/libnice/blob/master/examples/simple-example.c
    (testpath/"test.c").write <<~EOS
      #include <agent.h>
      int main(int argc, char *argv[]) {
        NiceAgent *agent;
        GMainLoop *gloop;
        gloop = g_main_loop_new(NULL, FALSE);
        // Create the nice agent
        agent = nice_agent_new(g_main_loop_get_context (gloop),
          NICE_COMPATIBILITY_RFC5245);
        if (agent == NULL)
          g_error("Failed to create agent");

        g_main_loop_unref(gloop);
        g_object_unref(agent);
        return 0;
      }
    EOS

    gettext = Formula["gettext"]
    glib = Formula["glib"]
    flags = %W[
      -I#{gettext.opt_include}
      -I#{glib.opt_include}/glib-2.0
      -I#{glib.opt_lib}/glib-2.0/include
      -I#{include}/nice
      -D_REENTRANT
      test.c
      -L#{gettext.opt_lib}
      -L#{glib.opt_lib}
      -L#{lib}
      -lnice
      -lgio-2.0
      -lglib-2.0
      -lgobject-2.0
    ]
    flags << "-lintl" if OS.mac?
    system ENV.cc, *flags, "-o", "test"
    system "./test"
  end
end
