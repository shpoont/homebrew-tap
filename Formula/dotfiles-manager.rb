class DotfilesManager < Formula
  desc "Config-driven dotfiles synchronization tool"
  homepage "https://github.com/shpoont/dotfiles-manager"
  url "https://github.com/shpoont/dotfiles-manager/archive/refs/tags/v0.1.7.tar.gz"
  sha256 "44ea4fc013c823223549e635b5b9af0771ff02b2fe42ed1543ada55d5fb6b5e3"

  bottle do
    root_url "https://github.com/shpoont/homebrew-tap/releases/download/dotfiles-manager-0.1.7"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "2c048b021593e47d13bfdbde3b4545b3775ef3b1e0c66a2266c40fdb4d57c573"
    sha256 cellar: :any_skip_relocation, sequoia:      "a4caa25a4d402e02bc5b4c1453ec0fe2638d1ff0b00c468c976331e674feaf8b"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "1d00aaae275db4c55b59f0f8e45e7f392c652c7dd5234eaf2f839b5c4e0d88e0"
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
