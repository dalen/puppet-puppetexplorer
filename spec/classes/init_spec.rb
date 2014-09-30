require 'spec_helper'

describe 'puppetexplorer' do
  context 'with defaults for all parameters on Debian' do
    let(:facts) do
      {
        :osfamily => 'Debian',
        :operatingsystem=> 'Debian',
        :operatingsystemrelease => '7.0',
        :lsbdistcodename => 'wheezy',
        :lsbdistid=> 'Debian',
        :kernel => 'Linux',
        :concat_basedir => '/var/lib/puppet/concat',
        :id => 'root',
        :path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      }
    end

    it { should contain_class('puppetexplorer') }
  end

  context 'with defaults for all parameters on RedHat' do
    let(:facts) do
      {
        :osfamily => 'RedHat',
        :operatingsystem=> 'RedHat',
        :operatingsystemrelease => '7.0',
        :kernel => 'Linux',
        :concat_basedir => '/var/lib/puppet/concat',
        :id => 'root',
        :path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      }
    end

    it { should contain_class('puppetexplorer') }
  end
end
