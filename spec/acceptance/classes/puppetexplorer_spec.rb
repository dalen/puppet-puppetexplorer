require 'spec_helper_acceptance'

describe 'puppetexplorer hostclass' do
  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS
      class { 'puppetexplorer':
        proxy_pass => [
          {
            "path" => "/api",
            "url" => "http://demo.puppetexplorer.io"
          }
        ],
      }
      EOS

    # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

  end
end
