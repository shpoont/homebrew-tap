class KrakenCli < Formula
  desc "AI-native CLI for the Kraken exchange"
  homepage "https://github.com/krakenfx/kraken-cli"
  license "MIT"

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/krakenfx/kraken-cli/releases/download/v0.4.1/kraken-cli-aarch64-apple-darwin.tar.gz"
    sha256 "674f72b6a375776cac048a42d631b19ff37ec0db0ce97ccf6e9c256ab6fc387a"
  end

  if OS.mac? && Hardware::CPU.intel?
    url "https://github.com/krakenfx/kraken-cli/releases/download/v0.4.1/kraken-cli-x86_64-apple-darwin.tar.gz"
    sha256 "9fe224291c301338d64daf6a1e25e2f8b7a8027a95a54cd06a635d22bcb2c570"
  end

  if OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/krakenfx/kraken-cli/releases/download/v0.4.1/kraken-cli-aarch64-unknown-linux-gnu.tar.gz"
    sha256 "4962f74fe65625397044b105f467fbbd67dc63954c6b0b7268b405e53f49c55f"
  end

  if OS.linux? && Hardware::CPU.intel?
    url "https://github.com/krakenfx/kraken-cli/releases/download/v0.4.1/kraken-cli-x86_64-unknown-linux-gnu.tar.gz"
    sha256 "a9a91782d00065a12800b5d3d585ff59fb30e87b321070e181d044e1909e1482"
  end

  def install
    bin.install "kraken"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/kraken --version")
  end
end
