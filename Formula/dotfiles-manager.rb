class DotfilesManager < Formula
  desc "Config-driven dotfiles synchronization tool"
  homepage "https://github.com/shpoont/dotfiles-manager"
  url "https://github.com/shpoont/dotfiles-manager/archive/refs/tags/v0.1.4.tar.gz"
  sha256 "8241ad9f9511e22b16cbf5e1b8fca8119e3833c04a5b8d2631b0540334284b5c"

  bottle do
    root_url "https://github.com/shpoont/homebrew-tap/releases/download/dotfiles-manager-0.1.4"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "4ab6677e2de5e47d608124481957bf113dd26b282423f9190ce4f2a62d752fd5"
    sha256 cellar: :any_skip_relocation, sequoia:      "46500b1df86bc2aa8d9f432cfddc0c7966ecef8ca910942e06a6ed28395093bf"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "a98233263ffec4e5134aaecb26b13b2991e102b9cfbf2a728a2dbfd4d8200be4"
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
