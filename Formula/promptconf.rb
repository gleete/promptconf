class Promptconf < Formula
  desc "Configurable two-line powerline prompt for zsh"
  homepage "https://github.com/gleete/promptconf"
  license "MIT"
  head "https://github.com/gleete/promptconf.git", branch: "main"

  # Cut a tagged release, then fill these in so `brew install promptconf`
  # works without --HEAD:
  #   url "https://github.com/gleete/promptconf/archive/refs/tags/v0.1.0.tar.gz"
  #   sha256 "..."

  def install
    pkgshare.install "promptconf.zsh"
  end

  def caveats
    <<~EOS
      Add to your ~/.zshrc:

        source #{opt_pkgshare}/promptconf.zsh

      Then run `promptconf wizard`.

      Using oh-my-zsh? Set ZSH_THEME="" and source promptconf after
      oh-my-zsh.sh, so nothing else competes for PROMPT.
    EOS
  end

  test do
    # Parses cleanly, and defines the prompt once sourced.
    system "zsh", "-n", pkgshare/"promptconf.zsh"
    output = shell_output("zsh -fc 'source #{pkgshare}/promptconf.zsh; print -r -- $PROMPTCONF_SCHEME'")
    assert_equal "agnoster", output.strip
  end
end
