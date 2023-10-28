class FastdeployPpocr < Formula
  desc "Stripped-down version of PaddlePaddle/FastDeploy"
  homepage "https://github.com/MaaAssistantArknights/FastDeploy"

  ## bug: terminate by SIGTRAP for this version
  # url "https://github.com/MaaAssistantArknights/FastDeploy/archive/2716bc9a3e57df87dd492be3b82a352ef0f12684.tar.gz"
  # sha256 "83a3748a4612931f39a0e7464760f27f65e01ca5b65467f045d8379b7069c6f5"
  # version "2023.10.11"

  url "https://github.com/MaaAssistantArknights/FastDeploy/archive/0ef77d33216a7335efbe2470b1532c96c3bbf71e.tar.gz"
  version "2023.10.7"
  sha256 "539bdfde24811b30e7c6135c48d0bd0aea3b9fb83e8e7fc5798455f4bc78440a"

  license "Apache-2.0"

  depends_on "cmake" => :build
  depends_on "eigen" => :build

  depends_on "onnxruntime"
  depends_on "opencv"

  def install
    cmake_args = %w[
      -DDPRINT_LOG=ON
      -DCMAKE_BUILD_TYPE=None
      -DBUILD_SHARED_LIBS=ON
    ]
    system "cmake", "-S", ".", "-B", "build", *cmake_args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end
end
