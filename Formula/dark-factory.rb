class DarkFactory < Formula
  desc "Interactive multi-model AI coding agent with rich TUI"
  homepage "https://github.com/ravjot28/dark-factory"
  url "https://github.com/ravjot28/dark-factory.git",
      tag:      "v0.1.0-dirty",
      revision: "ce7b670ba05cf5a8d978c44d674a45b5d9211f68"
  license "MIT"
  head "https://github.com/ravjot28/dark-factory.git", branch: "master"

  depends_on "go" => :build
  depends_on "rust" => :build
  depends_on "protobuf" => :build
  depends_on "ollama"

  def install
    # Build version info.
    version_str = version.to_s
    build_date = Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
    ldflags = %W[
      -X main.version=#{version_str}
      -X main.buildDate=#{build_date}
    ]

    # Build Go gateway.
    system "go", "build", *std_go_args(ldflags:), "-o", bin/"dark-factory", "./cmd/dark-factory"

    # Build Rust TUI.
    cd "tui" do
      system "cargo", "build", "--release"
      bin.install "target/release/dark-factory-tui"
    end
  end

  def caveats
    <<~EOS
      To get started:
        dark-factory

      Set your LLM provider credentials:
        export ANTHROPIC_API_KEY=your-key    # for Claude
        export OPENAI_API_KEY=your-key       # for GPT
        export GEMINI_API_KEY=your-key       # for Gemini

      Or use GitHub Copilot (requires gh CLI with copilot scope):
        gh auth login --scopes copilot

      Configuration: ~/.dark-factory.yml

      For local models (Ollama):
        ollama serve                              # start the server
        ollama pull qwen2.5-coder:7b              # pull a coding model
        dark-factory model recommend              # see hardware-matched models
    EOS
  end

  test do
    assert_match "dark-factory", shell_output("#{bin}/dark-factory version")
  end
end
