class Gdb < Formula
  desc "GNU debugger"
  homepage "https://www.gnu.org/software/gdb/"
  url "https://ftp.gnu.org/gnu/gdb/gdb-8.3.tar.xz"
  mirror "https://ftpmirror.gnu.org/gdb/gdb-8.3.tar.xz"
  sha256 "802f7ee309dcc547d65a68d61ebd6526762d26c3051f52caebe2189ac1ffd72e"
  head "https://sourceware.org/git/binutils-gdb.git"

  bottle do
    root_url "https://linuxbrew.bintray.com/bottles"
    sha256 "16da5f61ca304740defde7f8a772d5fb5f5c48ac658984ef186d1c77f53b5d6a" => :mojave
    sha256 "2721c3a733fba77d623f84c33cce6a1cca46c6a020649269f4431de402704fa1" => :high_sierra
    sha256 "b2343fca9963d198248c98ee069211c28e04135effcc2e7ed0900fec7c7d95a3" => :sierra
    sha256 "bb9e82bb515afd85fbf797636c1d0568830bcb53df20c22438c1c5881abed5ba" => :x86_64_linux
  end

  depends_on "pkg-config" => :build
  unless OS.mac?
    depends_on "texinfo" => :build
    depends_on "expat"
    depends_on "ncurses"
    depends_on "python"
    depends_on "xz"
  end

  fails_with :clang do
    build 800
    cause <<~EOS
      probe.c:63:28: error: default initialization of an object of const type
      'const any_static_probe_ops' without a user-provided default constructor
    EOS
  end

  fails_with :clang do
    build 600
    cause <<~EOS
      clang: error: unable to execute command: Segmentation fault: 11
      Test done on: Apple LLVM version 6.0 (clang-600.0.56) (based on LLVM 3.5svn)
    EOS
  end

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-debug
      --disable-dependency-tracking
      --enable-targets=all
      --disable-binutils
    ]
    if OS.mac?
      arg << "--with-python=/usr"
    else
      args << "--with-python=#{Formula["python"].opt_bin}/python3"
      ENV.append "CPPFLAGS", "-I#{Formula["python"].opt_libexec}"
    end

    system "./configure", *args
    system "make"

    # Don't install bfd or opcodes, as they are provided by binutils
    system "make", "install-gdb"
  end

  def caveats; <<~EOS
    gdb requires special privileges to access Mach ports.
    You will need to codesign the binary. For instructions, see:

      https://sourceware.org/gdb/wiki/BuildingOnDarwin

    On 10.12 (Sierra) or later with SIP, you need to run this:

      echo "set startup-with-shell off" >> ~/.gdbinit
  EOS
  end

  test do
    system bin/"gdb", bin/"gdb", "-configuration"
  end
end
