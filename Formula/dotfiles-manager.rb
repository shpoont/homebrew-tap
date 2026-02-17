class DotfilesManager < Formula
  desc "Config-driven dotfiles synchronization tool"
  homepage "https://github.com/shpoont/dotfiles-manager"
  url "https://github.com/shpoont/dotfiles-manager/archive/refs/tags/v0.1.5.tar.gz"
  sha256 "0f1c367230f65254e62e7709c64570c252ede4a7c2cc3c3e3dfbdad3d7d48a92"

  bottle do
    root_url "https://github.com/shpoont/homebrew-tap/releases/download/dotfiles-manager-0.1.5"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "f1db1d48588b818b3de8b973de60f7dadd770e8292c6ee8045b18ad5d9830973"
    sha256 cellar: :any_skip_relocation, sequoia:      "4c266921f1c813d756e47f3b002d2f82662d989f2ea123d71a770e7739073937"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "a5686c59c10bf2bc4c2bdf9e4c473e7164ae05ef02c7a8680aff15ccdafcca24"
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
