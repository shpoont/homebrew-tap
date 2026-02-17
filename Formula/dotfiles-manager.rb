class DotfilesManager < Formula
  desc "Config-driven dotfiles synchronization tool"
  homepage "https://github.com/shpoont/dotfiles-manager"
  url "https://github.com/shpoont/dotfiles-manager/archive/refs/tags/v0.1.5.tar.gz"
  sha256 "0f1c367230f65254e62e7709c64570c252ede4a7c2cc3c3e3dfbdad3d7d48a92"

  bottle do
    root_url "https://github.com/shpoont/homebrew-tap/releases/download/dotfiles-manager-0.1.5"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "fcbce125743eae5a8acc4b686d04bd3fa1545a41d2f3c92474a211a20acc1f79"
    sha256 cellar: :any_skip_relocation, sequoia:      "e97a0649d64f5f725ae41883decb34416e6cd2228fc89b7122d5633e63a74c79"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "22e93a0b9e91f4d4a0f38298a2a9820efa5c8275ed72017933718b5e275abdb8"
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
