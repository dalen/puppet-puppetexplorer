require 'spec_helper'
describe 'puppetexplorer' do

  context 'with defaults for all parameters' do
    it { should contain_class('puppetexplorer') }
  end
end
