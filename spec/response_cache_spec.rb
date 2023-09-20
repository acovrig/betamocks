# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Betamocks::ResponseCache do
  let(:env) { double('Faraday::Env') }
  let(:config) { {method: 'get', path: '/fake', file_path: '/fake/file.yml', symbolize_response: true} }

  subject { described_class.new(env: env, config: config) }

  context 'with a non-existent cache_dir' do
    before(:each) do
      Betamocks.configure do |config|
        config.enabled = true
        config.cache_dir = File.join('this', 'does', 'not', 'exist')
        config.services_config = File.join(Dir.pwd, 'spec', 'support', 'betamocks.yml')
      end
    end
    it '#load_response raises IOError' do
      expect{subject.load_response}.to raise_error(IOError)
    end
  end

  context 'with an existant cache_dir' do
    before(:each) do
      Betamocks.configure do |config|
        config.enabled = true
        config.cache_dir = File.join('spec', 'support', 'cache')
        config.services_config = File.join(Dir.pwd, 'spec', 'support', 'betamocks.yml')
      end
    end

    it '#load_response symbolizes_keys' do
      cached_env = YAML.load_file(File.join('spec', 'support', 'responses', 'default.yml'))

      response = subject.send(:cached_body, cached_env)
      expect(response).to eq({:status=>"NOT_FOUND", :code=>404})
    end
  end
end