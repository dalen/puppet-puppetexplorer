require 'spec_helper_acceptance'

describe 'puppetexplorer hostclass' do
  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS
      class { 'puppetexplorer':
        servername      => 'puppetexplorer.test',
        port            => 80,
        ssl             => false,
        ssl_proxyengine => false,
        proxy_pass      => [
          {
            "path" => "/api",
            "url"  => "http://demo.puppetexplorer.io"
          }
        ],
      }
      EOS

    # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe port(80) do
      it { should be_listening }
    end

    describe command("curl -f -s -H 'Host: puppetexplorer.test' http://localhost/") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /Puppet Explorer/ }
    end
  end
end
