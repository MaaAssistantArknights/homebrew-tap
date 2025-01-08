class OpencvMaa < Formula
  desc "Minimal OpenCV build use by MAA"
  homepage "https://opencv.org/"
  url "https://github.com/opencv/opencv/archive/refs/tags/4.11.0.tar.gz"
  sha256 "9a7c11f924eff5f8d8070e297b322ee68b9227e003fd600d4b8122198091665f"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/opencv-maa-4.10.0_2"
    sha256 arm64_sequoia: "7ed9c5aeb5a54440a883296d3498abe47ff03857a03611a71af6eedb01ec2e7d"
    sha256 arm64_sonoma:  "f0d65d510f6c746edf19330dd97b3535959c65696411ac43e19aaa4ac0565529"
    sha256 ventura:       "fd46332f66178c6e31ba10651498a3aade4d716a7b7d56cd708ec4ab4bd92577"
    sha256 x86_64_linux:  "b325a9960fd077871195bac1480f0df01eab547b99ce67317f6b14e8a9667f39"
  end

  depends_on "cmake" => :build
  depends_on "eigen" => :build

  depends_on "jpeg-turbo"
  depends_on "libpng"

  uses_from_macos "zlib"

  on_linux do
    depends_on "ffmpeg@6"
    depends_on "openblas"
  end

  conflicts_with "opencv", { because: "this is a minimal build of OpenCV" }

  def install
    # Remove bundled libraries to make sure formula dependencies are used
    libdirs = %w[ffmpeg libjasper libjpeg libjpeg-turbo libpng libtiff libwebp openexr openjpeg protobuf tbb zlib]
    libdirs.each { |l| rm_r(buildpath/"3rdparty"/l) }

    cmake_args = %W[
      -DCMAKE_CXX_STANDARD=17

      -DBUILD_LIST=core,imgproc,imgcodecs,videoio

      -DBUILD_ZLIB=OFF

      -DWITH_EIGEN=ON

      -DWITH_PNG=ON
      -DBUILD_PNG=OFF
      -DWITH_JPEG=ON
      -DBUILD_JPEG=OFF
      -DWITH_TIFF=OFF
      -DWITH_WEBP=OFF
      -DWITH_OPENJPEG=OFF
      -DWITH_JASPER=OFF
      -DWITH_OPENEXR=OFF

      -DWITH_FFMPEG=#{OS.linux? ? "ON" : "OFF"}
      -DWITH_V4L=OFF
      -DWITH_GSTREAMER=OFF
      -DWITH_DSHOW=OFF
      -DWITH_1394=OFF

      -DWITH_CUDA=OFF

      -DWITH_PROTOBUF=OFF
      -DBUILD_opencv_python3=OFF
    ]

    # HACK: avoid opencv install data
    cmake_args << "-DOPENCV_OTHER_INSTALL_PATH=#{buildpath}/tmp"

    if OS.linux?
      cmake_args += %W[
        -DOpenBLAS_LIB=#{Formula["openblas"].opt_lib}/libopenblas.so
        -DPNG_LIBRARY=#{Formula["libpng"].opt_lib}/libpng.so
        -DJPEG_LIBRARY=#{Formula["jpeg-turbo"].opt_lib}/libjpeg.so
        -DZLIB_LIBRARY=#{Formula["zlib"].opt_lib}/libz.so
      ]
    end

    system "cmake", "-S", ".", "-B", "build", *cmake_args, *std_cmake_args
    inreplace "build/modules/core/version_string.inc", "#{Superenv.shims_path}/", ""
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <opencv2/opencv.hpp>
      #include <iostream>
      int main() {
        std::cout << CV_VERSION << std::endl;
        return 0;
      }
    EOS
    system ENV.cxx, "-std=c++17", "test.cpp", "-I#{include}/opencv4", "-o", "test"
    assert_equal shell_output("./test").strip, version.to_s
  end
end
