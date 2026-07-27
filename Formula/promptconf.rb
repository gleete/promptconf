class Promptconf < Formula
  desc "Configurable powerline prompt for zsh"
  homepage "https://github.com/gleete/promptconf"
  url "https://github.com/gleete/promptconf/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "86834ba0b9a94fd62efb7a443daa1790f31ac6fbe8106eed7208d9f03865eecb"
  license "MIT"
  head "https://github.com/gleete/promptconf.git", branch: "main"

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
    system "zsh", "-n", pkgshare/"promptconf.zsh"
    output = shell_output("zsh -fc 'source #{pkgshare}/promptconf.zsh; print -r -- $PROMPTCONF_SCHEME'")
    assert_equal "agnoster", output.strip
  end
end
