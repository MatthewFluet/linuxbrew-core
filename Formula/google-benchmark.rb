class GoogleBenchmark < Formula
  desc "C++ microbenchmark support library"
  homepage "https://github.com/google/benchmark"
  url "https://github.com/google/benchmark/archive/v1.5.tar.gz"
  sha256 "feba1c44cbace01627435a675aa271f4b012068dbea9922443c58fedd56eb5eb"
  head "https://github.com/google/benchmark.git"

  bottle do
    root_url "https://linuxbrew.bintray.com/bottles"
    cellar :any_skip_relocation
    sha256 "ade6bd73e60dda7d005cf9fe54ab7eb9c3db29a74aff2d1beecb60966dc21160" => :mojave
    sha256 "aea6c63841fb174d5d7cff15e4a5ac6b4f4c9a98dfc9bf52533b46f76366e2e9" => :high_sierra
    sha256 "c1527ac42d9acef051293408c2ba9192ae6cc458e94a5226cd57ff9c714f1b03" => :sierra
    sha256 "8920f0d052a40a002f39217775deac607dc1446838184b9f1d67287583c3d238" => :x86_64_linux
  end

  depends_on "cmake" => :build

  def install
    ENV.cxx11
    system "cmake", "-DBENCHMARK_ENABLE_GTEST_TESTS=OFF", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <string>
      #include <benchmark/benchmark.h>
      static void BM_StringCreation(benchmark::State& state) {
        while (state.KeepRunning())
          std::string empty_string;
      }
      BENCHMARK(BM_StringCreation);
      BENCHMARK_MAIN();
    EOS
    flags = [*("-stdlib=libc++" if OS.mac?), "-I#{include}", "-L#{lib}", "-lbenchmark", *("-pthread" if ENV.compiler == :gcc)] + ENV.cflags.to_s.split
    system ENV.cxx, "-o", "test", "test.cpp", *flags
    system "./test"
  end
end
