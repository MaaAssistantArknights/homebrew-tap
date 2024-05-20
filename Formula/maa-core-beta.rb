class MaaCoreBeta < Formula
  desc "Maa Arknights assistant Library (beta)"
  homepage "https://github.com/MaaAssistantArknights/MaaAssistantArknights/"
  url "https://github.com/MaaAssistantArknights/MaaAssistantArknights/archive/refs/tags/v5.3.0-beta.2.tar.gz"
  sha256 "c0e5c891d5034f29e5c9426b2c444a3d9cb43c0be71d9753e1068201d15917a7"
  license "AGPL-3.0-only"

  livecheck do
    url :url
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-core-beta-5.2.3"
    sha256 arm64_sonoma: "7e283c072881779faad24eea4b39944ee1b86da0fa1e8a3d91ab3ad70309c27a"
    sha256 ventura:      "d32ef014e9c092305c49fb24d67685531b8704663aa98a80feb3099ca20b14c1"
    sha256 x86_64_linux: "9753138b541bd5ae3a4c38c0d879c087d36565f770a037b941cdfe9747eb8fbc"
  end

  option "with-resource", "Install resource files" if OS.linux?
  option "without-resource", "Don't install resource files" if OS.mac?

  depends_on "asio" => :build
  depends_on "cmake" => :build
  depends_on "eigen" => :build
  depends_on "range-v3" => :build if OS.mac?

  depends_on "cpr"
  depends_on macos: :ventura # upstream only compiles on macOS 13
  depends_on "onnxruntime"

  # opencv is a very large dependency, and we only need a small part of it
  # so we build our own opencv if user does not want to install opencv by homebrew
  depends_on "opencv" => :optional

  uses_from_macos "curl"

  conflicts_with "maa-core", { because: "both provide libMaaCore" }

  fails_with gcc: "11"

  resource "fastdeploy_ppocr" do
    url "https://github.com/MaaAssistantArknights/FastDeploy/archive/0db6000aaac250824266ac37451f43ce272d80a3.tar.gz"
    sha256 "ac0bf5059f0339003e3e6e50c87e9455be508761e101e8898135f67b8a7c8115"
  end

  unless build.with? "opencv"
    depends_on "jpeg-turbo"
    depends_on "libpng"
    depends_on "libtiff"

    resource "opencv" do
      url "https://github.com/opencv/opencv/archive/refs/tags/4.9.0.tar.gz"
      sha256 "ddf76f9dffd322c7c3cb1f721d0887f62d747b82059342213138dc190f28bc6c"
    end
  end

  def install
    unless build.with? "opencv"
      resource("opencv").stage "opencv"

      # Remove bundled libraries to make sure formula dependencies are used
      libdirs = %w[ffmpeg libjasper libjpeg libjpeg-turbo libpng libtiff libwebp openexr openjpeg zlib]
      libdirs.each { |l| (buildpath/"opencv/3rdparty"/l).rmtree }

      # basic cmake args for opencv
      opencv_cmake_args = %W[
        -DCMAKE_CXX_STANDARD=17

        -DBUILD_SHARED_LIBS=OFF

        -DBUILD_ZLIB=OFF

        -DWITH_PNG=ON
        -DBUILD_PNG=OFF
        -DWITH_JPEG=ON
        -DBUILD_JPEG=OFF
        -DWITH_TIFF=ON
        -DBUILD_TIFF=OFF

        -DWITH_WEBP=OFF
        -DBUILD_WEBP=OFF
        -DWITH_OPENJPEG=OFF
        -DBUILD_OPENJPEG=OFF
        -DWITH_JASPER=OFF
        -DBUILD_JASPER=OFF
        -DWITH_OPENEXR=OFF
        -DBUILD_OPENEXR=OFF

        -DWITH_FFMPEG=#{OS.linux? ? "ON" : "OFF"}
        -DWITH_V4L=OFF
        -DWITH_GSTREAMER=OFF
        -DWITH_DSHOW=OFF
        -DWITH_1394=OFF
        -DWITH_CUDA=OFF
      ]
    end

    # build fastdeploy_ppocr
    resource("fastdeploy_ppocr").stage "fastdeploy_ppocr"
    fastdeploy_cmake_args = %w[
      -DBUILD_SHARED_LIBS=OFF
      -DCMAKE_POSITION_INDEPENDENT_CODE=ON
    ]
    # build opencv for fastdeploy_ppocr
    unless build.with? "opencv"
      opencv_buildpath = buildpath/"opencv/build-fastdeploy"
      system "cmake", "-S", "opencv", "-B", opencv_buildpath,
        "-DBUILD_LIST=core,imgproc", "-DWITH_EIGEN=ON",
        *opencv_cmake_args, *std_cmake_args
      # Remove reference to shims directory
      inreplace opencv_buildpath/"modules/core/version_string.inc", "#{Superenv.shims_path}/", ""
      system "cmake", "--build", opencv_buildpath
      fastdeploy_cmake_args << "-DOpenCV_DIR=#{opencv_buildpath}"
    end
    cd "fastdeploy_ppocr" do
      system "cmake", "-S", ".", "-B", "build", *fastdeploy_cmake_args, *std_cmake_args
      system "cmake", "--build", "build"
    end
    # patch CMakeLists.txt to use our own fastdeploy_ppocr
    inreplace "CMakeLists.txt" do |s|
      s.gsub!(/find_package\(MaaDerpLearning.*\)/,
              "include_directories(${FASTDEPLOY_INCLUDE_DIRS})")
      s.gsub!(/target_link_libraries\((.*)MaaDerpLearning(.*)\)/,
              "target_link_libraries(\\1${FASTDEPLOY_LIBS}\\2)")
    end

    # build maa-core

    # patch CMakeLists.txt
    inreplace "CMakeLists.txt" do |s|
      s.gsub! "RUNTIME\sDESTINATION\s.", ""
      s.gsub! "LIBRARY\sDESTINATION\s.", ""
      s.gsub! "PUBLIC_HEADER\sDESTINATION\s.", ""
      s.gsub! "find_package(asio ", "# find_package(asio "
      s.gsub! "asio::asio", ""
    end

    # patch onnxruntime, the onnxruntime used by upstream is too old,
    # so we need to patch it to use the new onnxruntime installed by homebrew.
    # Major differences:
    # - the include directory is changed from onnxruntime/core/session to onnxruntime
    # - the package name is changed from ONNXRuntime to onnxruntime
    inreplace "CMakeLists.txt", "ONNXRuntime", "onnxruntime"
    inreplace "cmake/FindONNXRuntime.cmake" do |s|
      s.gsub! "find_path(ONNXRuntime_INCLUDE_DIR NAMES onnxruntime/core/session/onnxruntime_c_api.h)",
        "find_path(onnxruntime_INCLUDE_DIR NAMES onnxruntime_c_api.h PATH_SUFFIXES onnxruntime)"
      s.gsub! "ONNXRuntime", "onnxruntime"
    end
    onnxruntime_related_files = %w[
      src/MaaCore/Config/OnnxSessions.h
      src/MaaCore/Vision/Battle/BattlefieldDetector.cpp
      src/MaaCore/Vision/Battle/BattlefieldClassifier.cpp
    ]
    inreplace onnxruntime_related_files, "onnxruntime/core/session", "onnxruntime"

    maacore_cmake_args = %W[
      -DBUILD_SHARED_LIBS=ON
      -DCMAKE_POSITION_INDEPENDENT_CODE=ON
      -DUSE_MAADEPS=OFF
      -DINSTALL_PYTHON=OFF
      -DINSTALL_RESOURCE=OFF
      -DFASTDEPLOY_INCLUDE_DIRS=#{buildpath/"fastdeploy_ppocr"}
      -DFASTDEPLOY_LIBS=#{buildpath/"fastdeploy_ppocr/build/libfastdeploy_ppocr.a"}
      -DMAA_VERSION=v#{version}
    ]

    # build opencv for maacore
    unless build.with? "opencv"
      opencv_buildpath = buildpath/"opencv/build-maacore"
      system "cmake", "-S", "opencv", "-B", opencv_buildpath,
        "-DBUILD_LIST=core,imgproc,imgcodecs,videoio", "-DWITH_EIGEN=OFF",
        *opencv_cmake_args, *std_cmake_args
      # Remove reference to shims directory
      inreplace opencv_buildpath/"modules/core/version_string.inc", "#{Superenv.shims_path}/", ""
      system "cmake", "--build", opencv_buildpath
      maacore_cmake_args << "-DOpenCV_DIR=#{opencv_buildpath}"
    end

    ENV.append "CXXFLAGS", "-DASST_USE_RANGES_RANGE_V3=1" if OS.mac?
    ENV.append "CXXFLAGS", "-DASST_WITH_EMULATOR_EXTRAS=0"

    system "cmake", "-S", ".", "-B", "build", *maacore_cmake_args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    (share/"maa").install "resource" if build.with? "resource"
  end
end
