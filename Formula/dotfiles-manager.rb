class DotfilesManager < Formula
  desc "Config-driven dotfiles synchronization tool"
  homepage "https://github.com/shpoont/dotfiles-manager"
  url "https://github.com/shpoont/dotfiles-manager/archive/refs/tags/v0.1.8.tar.gz"
  sha256 "9ac5c4693ba30574645b8413812530c9f8574af9b74652fe81a479cf2b83b44f"

  bottle do
    root_url "https://github.com/shpoont/homebrew-tap/releases/download/dotfiles-manager-0.1.8"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "03e5df2aac551415d3c6dd510b500280e079039d8edc89d4e965eb294bc697c3"
    sha256 cellar: :any_skip_relocation, sequoia:      "7f8187c83dd660a6b063605990f1690ff442914180189b9fd7b1e3b19058eb52"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "200ca44fa30ee9f9a0746853872629064364b2667c369f1c1b70a649115a6de3"
  end

  depends_on "go" => :build

  def install
    ldflags = "-s -w -X github.com/shpoont/dotfiles-manager/internal/app.buildVersion=#{version}"
    system "go", "build", *std_go_args(ldflags: ldflags), "./cmd/dotfiles-manager"
  end

  test do
    (testpath/".dotfiles-manager.yaml").write <<~YAML
      syncs:
        - target: .config/nvim
          source: .config/nvim
    YAML

    output = shell_output("#{bin}/dotfiles-manager --config #{testpath}/.dotfiles-manager.yaml status --json")
    assert_match "\"ok\":true", output
    assert_equal "dotfiles-manager version #{version}", shell_output("#{bin}/dotfiles-manager --version").strip
  end
end
