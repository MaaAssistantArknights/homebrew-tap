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
    sha256 cellar: :any,                 ventura:      "0af37c7f61296935597dc35611887817d828ab0afb8f36b4ca4a1e691c289bb2"
    sha256 cellar: :any,                 monterey:     "8f34109b45d4fd587647c50a845059af5dd8a3c6114c17a9a8b9c19ba3ae9d1c"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "80b5b2bd90fea583483b52f4bd5e7c37f0c6fec85861568925afdf63ec53de19"
  end

  deprecate! date: "2024-02-20", because: "this formula is now shiped as a resource by MaaCore"

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
