wget = Facter::Util::Resolution.exec('bash -c \'wget --version 2>&1 | head -n1 | grep -i wget\'').to_s

unless wget.nil? or wget.empty?
  Facter.add('eyp_puppet_wget') do
      setcode do
        wget
      end
  end
end
