class FastdeployPpocr < Formula
  desc "Stripped-down version of PaddlePaddle/FastDeploy"
  homepage "https://github.com/MaaAssistantArknights/FastDeploy"
  url "https://github.com/MaaAssistantArknights/FastDeploy/archive/0db6000aaac250824266ac37451f43ce272d80a3.tar.gz"
  version "2024.3.13"
  sha256 "ac0bf5059f0339003e3e6e50c87e9455be508761e101e8898135f67b8a7c8115"
  license "Apache-2.0"

  livecheck do
    skip "This formula is not tagged, so there is no version to check"
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/fastdeploy_ppocr-2024.3.13"
    sha256 cellar: :any,                 arm64_sonoma: "bac8eae8a274248b0b30c7fdeb4db7ef0c1658fac36d915c2f1620bc41ceeff3"
    sha256 cellar: :any,                 ventura:      "605022520cf4f45c2d7a28f330cd3f2cb23411ea981d0ae6888bb1df4ffa1ade"
    sha256 cellar: :any,                 monterey:     "e30658dad92c79e6b738d279770054a7f19863ef5adbabfc62f95143eb4afe12"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "ef23b52422b08e03e04bf1df794e3cb7dfb669ee013bf18016fbac4a1c9eb7b0"
  end

  deprecate! date: "2024-02-20", because: "this formula is now shipped by MaaCore"

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
