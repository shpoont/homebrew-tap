class DotfilesManager < Formula
  desc "Config-driven dotfiles synchronization tool"
  homepage "https://github.com/shpoont/dotfiles-manager"
  url "https://github.com/shpoont/dotfiles-manager/archive/refs/tags/v0.1.2.tar.gz"
  sha256 "4f4577bf25897b18bdd31b33d0c0272d7d1d41e56665007e08df9db1a3f23a41"

  bottle do
    root_url "https://github.com/shpoont/homebrew-tap/releases/download/dotfiles-manager-0.1.2"
    rebuild 2
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "afaad961b4181cfb6dfba91ff8e1154c5359771b86b5f80b5f5a4fc3859570f9"
    sha256 cellar: :any_skip_relocation, sequoia:      "5a40b9317952ef66ae51e45abe199ec1cd4efbcdafa5145073eefe8c4c1bc0b1"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "6a1b8c9016b3e8f7cf3072302bf8334d0c9b5156bdf1ce51eeb2d44c383df005"
  end

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w"), "./cmd/dotfiles-manager"
  end

  test do
    (testpath/".dotfiles-manager.yaml").write <<~YAML
      syncs:
        - target: .config/nvim
          source: .config/nvim
    YAML

    output = shell_output("#{bin}/dotfiles-manager --config #{testpath}/.dotfiles-manager.yaml status --json")
    assert_match "\"ok\":true", output
  end
end
