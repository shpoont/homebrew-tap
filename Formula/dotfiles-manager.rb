class DotfilesManager < Formula
  desc "Config-driven dotfiles synchronization tool"
  homepage "https://github.com/shpoont/dotfiles-manager"
  url "https://github.com/shpoont/dotfiles-manager/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "0fe09950f2a6c498ece53374b8b09561ea2d4e93e72c524c7e2aa65e5863f79a"

  bottle do
    root_url "https://github.com/shpoont/homebrew-tap/releases/download/dotfiles-manager-0.1.1"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_tahoe: "fb7c02ec63af549324a81048de64e7bcc92f0ed400e0634f74dd3ae59d2b3d89"
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

    output = shell_output("#{bin}/dotfiles-manager --config #{testpath}/.dotfiles-manager.yaml status")
    assert_match "status: syncs=1", output
  end
end
