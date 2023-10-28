class FastdeployPpocr < Formula
  desc "Stripped-down version of PaddlePaddle/FastDeploy"
  homepage "https://github.com/MaaAssistantArknights/FastDeploy"
  # bug: terminate by SIGTRAP for this version if PRINT_LOG is OFF
  url "https://github.com/MaaAssistantArknights/FastDeploy/archive/2716bc9a3e57df87dd492be3b82a352ef0f12684.tar.gz"
  version "2023.10.11"
  sha256 "83a3748a4612931f39a0e7464760f27f65e01ca5b65467f045d8379b7069c6f5"
  license "Apache-2.0"

  depends_on "cmake" => :build
  depends_on "eigen" => :build

  depends_on "onnxruntime"
  depends_on "opencv"

  def install
    cmake_args = %w[
      -DPRINT_LOG=ON
      -DCMAKE_BUILD_TYPE=None
      -DBUILD_SHARED_LIBS=ON
    ]
    system "cmake", "-S", ".", "-B", "build", *cmake_args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end
end
