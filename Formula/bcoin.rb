require "language/node"

class Bcoin < Formula
  desc "Javascript bitcoin library for node.js and browsers"
  homepage "https://bcoin.io"
  url "https://github.com/bcoin-org/bcoin/archive/v2.2.0.tar.gz"
  sha256 "fa1a78a73bef5837b7ff10d18ffdb47c0e42ad068512987037a01e8fad980432"
  license "MIT"
  head "https://github.com/bcoin-org/bcoin.git", branch: "master"

  bottle do
    rebuild 1
    sha256                               arm64_monterey: "f0e36780788eacc5d842482fed2a94647ccd10194145870b885d6f3a7479847d"
    sha256                               arm64_big_sur:  "da887bfcbbe76163924ff47f98553672c8a46173e61575aa1d6807785392c196"
    sha256                               monterey:       "677f0859d944f517f93717cbe69be2e7c530c0c16e6d8fc99590ebe166af8bd2"
    sha256                               big_sur:        "e19447eaf8696a4ab72309083ff2373d4f30aa2cb04d35cd16b2cb472c32a23f"
    sha256                               catalina:       "274567c8a4d52276ceecbe9763c6274b33b9b42218933cccc7e59948edd70c89"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "8f12522c4eb98dced35c699c0c5122cb9be3069e0e18f41fd7f1ef088a60377a"
  end

  depends_on "python@3.11" => :build
  depends_on "node@16"

  def node
    deps.reject(&:build?)
        .map(&:to_formula)
        .find { |f| f.name.match?(/^node(@\d+(\.\d+)*)?$/) }
  end

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    (bin/"bcoin").write_env_script libexec/"bin/bcoin", PATH: "#{node.opt_bin}:$PATH"
  end

  test do
    (testpath/"script.js").write <<~EOS
      const assert = require('assert');
      const bcoin = require('#{libexec}/lib/node_modules/bcoin');
      assert(bcoin);

      const node = new bcoin.FullNode({
        prefix: '#{testpath}/.bcoin',
        memory: false
      });
      (async () => {
        await node.ensure();
      })();
    EOS
    system "#{node.opt_bin}/node", testpath/"script.js"
    assert File.directory?("#{testpath}/.bcoin")
  end
end
