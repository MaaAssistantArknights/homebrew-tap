class FastdeployPpocr < Formula
  desc "Stripped-down version of PaddlePaddle/FastDeploy"
  homepage "https://github.com/MaaAssistantArknights/FastDeploy"
  url "https://github.com/MaaAssistantArknights/FastDeploy/archive/2896b6d3641c18218209c496ea149a773373fa8b.tar.gz"
  version "2024.5.30"
  sha256 "5ee3dbad183b56ebf42569497c58a646d069a92fef54afce108d1e3422bb03f9"
  license "Apache-2.0"
  revision 1

  livecheck do
    skip "This formula is not tagged, so there is no version to check"
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/fastdeploy_ppocr-2024.5.30"
    sha256 cellar: :any,                 arm64_sequoia: "4e6ac1b029b585a09f443e8dbc32c20a2fbb25594eb3fc27121c692de6a504bf"
    sha256 cellar: :any,                 arm64_sonoma:  "5212728e9a6bf4055cb4936ca71e0253707ab7a614180a6636ca5949b0586fc3"
    sha256 cellar: :any,                 ventura:       "d564b4297039df5bf61a47999a2dbb3123408b175133dfc838ad4e4e005ca183"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "c297428837c68cc79e2b94f6643c50e42838b2ca53e964b3d7ea0eab085319b2"
  end

  depends_on "cmake" => :build
  depends_on "eigen" => :build

  depends_on "onnxruntime"

  # opencv is a very large dependency, and we only need a small part of it
  # so we build our own opencv if user does not want to install opencv by homebrew
  if build.with? "opencv"
    depends_on "opencv"
  else
    depends_on "opencv-maa"
  end

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
