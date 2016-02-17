make = Facter::Util::Resolution.exec('bash -c \'wget -v 2>&1 | head -n1 | grep -i wget\'').to_s

unless make.nil? or make.empty?
  Facter.add('eyp_puppet_wget') do
      setcode do
        make
      end
  end
end
