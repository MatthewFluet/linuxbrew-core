class Readline < Formula
  desc "Library for command-line editing"
  homepage "https://tiswww.case.edu/php/chet/readline/rltop.html"
  url "https://ftp.gnu.org/gnu/readline/readline-8.0.tar.gz"
  mirror "https://ftpmirror.gnu.org/readline/readline-8.0.tar.gz"
  version "8.0.0"
  sha256 "e339f51971478d369f8a053a330a190781acb9864cf4c541060f12078948e461"

  bottle do
    root_url "https://linuxbrew.bintray.com/bottles"
    cellar :any
    sha256 "4d94eaf31d5cc553107065a1a425226183044ea7b741a5dc49fe5714b94ec8cf" => :x86_64_linux
  end

  keg_only :shadowed_by_macos, <<~EOS
    macOS provides the BSD libedit library, which shadows libreadline.
    In order to prevent conflicts when programs look for libreadline we are
    defaulting this GNU Readline installation to keg-only
  EOS

  depends_on "ncurses" unless OS.mac?

  def install
    system "./configure", "--prefix=#{prefix}",
      ("--with-curses" if build.with? "ncurses")
    args = []
    args << "SHLIB_LIBS=-lcurses" if build.with? "ncurses"
    system "make", "install", *args
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <stdio.h>
      #include <stdlib.h>
      #include <readline/readline.h>

      int main()
      {
        printf("%s\\n", readline("test> "));
        return 0;
      }
    EOS
    system ENV.cc, "-L", lib, "test.c", "-L#{lib}", "-lreadline", "-o", "test"
    assert_equal "test> Hello, World!\nHello, World!",
      pipe_output("./test", "Hello, World!\n").strip
  end
end
