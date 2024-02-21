class FastdeployPpocr < Formula
  desc "Stripped-down version of PaddlePaddle/FastDeploy"
  homepage "https://github.com/MaaAssistantArknights/FastDeploy"
  url "https://github.com/MaaAssistantArknights/FastDeploy/archive/d0b018ac6c3daa22c7b55b555dc927a5c734d430.tar.gz"
  version "2023.10.29"
  sha256 "4a74b0f90178384124a97324e86edd4aa0fed44ac280e23cf3454513b14e0a6a"
  license "Apache-2.0"

  livecheck do
    skip "This formula is not tagged, so there is no version to check"
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/fastdeploy_ppocr-2023.10.29"
    rebuild 2
    sha256 cellar: :any,                 arm64_sonoma: "587f1b1efd13930019cdc90c2c7a58f4bfff211461b7eb55a2399d4a9eeb9e7b"
    sha256 cellar: :any,                 ventura:      "d039dcaa0770e17e23ebef7239671e9273b051c61479d2ae27020c60543521b7"
    sha256 cellar: :any,                 monterey:     "8c339ab26dd236217624f8be08c5a5eb26194bb4a9232e6fd0f1ae3cf35dd6de"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "5c7ad47f50ff03bd10baacfebbdc6dabbcc7d765247e288fd28da3dd0fbb675b"
  end

  deprecate! date: "2024-02-20", because: "this formula is now shiped by MaaCore"

  depends_on "cmake" => :build
  depends_on "eigen" => :build

  depends_on "onnxruntime"
  depends_on "opencv"

  def install
    cmake_args = %w[
      -DBUILD_SHARED_LIBS=ON
      -DCMAKE_POSITION_INDEPENDENT_CODE=ON
    ]
    system "cmake", "-S", ".", "-B", "build", *cmake_args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end
end
