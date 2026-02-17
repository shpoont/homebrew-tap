class DotfilesManager < Formula
  desc "Config-driven dotfiles synchronization tool"
  homepage "https://github.com/shpoont/dotfiles-manager"
  url "https://github.com/shpoont/dotfiles-manager/archive/refs/tags/v0.1.2.tar.gz"
  sha256 "4f4577bf25897b18bdd31b33d0c0272d7d1d41e56665007e08df9db1a3f23a41"

  bottle do
    root_url "https://github.com/shpoont/homebrew-tap/releases/download/dotfiles-manager-0.1.2"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "f7900990d897be443601f1bd8883b4b549f010131fd8b6cfbcf08a2090715a8b"
    sha256 cellar: :any_skip_relocation, sequoia:      "6d63ce1dc4eecaa53a95f4f82027bd89ffc64886a1fd2286643ca6db09127b42"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "12083d3a3f5e18165fcc0bf0811121488c10c2eca0a8bd316ce4596344ae2e12"
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
