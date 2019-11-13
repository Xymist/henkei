# frozen_string_literal: true

require 'helper.rb'
require 'henkei/tika_config'

describe Henkei::TikaConfig do
  describe 'default state' do
    let(:config) { described_class.new }
    let(:config_string) { File.read('spec/example_configs/default.xml') }

    it 'produces the default configuration' do
      expect(config.as_string).to eq(config_string)
    end
  end

  describe 'inline parser' do
    let(:config) { described_class.new(pdf_defaults: :inline) }
    let(:config_string) { File.read('spec/example_configs/inline.xml') }

    it 'produces the inline image extraction configuration' do
      expect(config.as_string).to eq(config_string)
    end
  end

  describe 'rendered parser' do
    let(:config) { described_class.new(pdf_defaults: :rendered) }
    let(:config_string) { File.read('spec/example_configs/rendered.xml') }

    it 'produces the rendered page extraction configuration' do
      expect(config.as_string).to eq(config_string)
    end
  end

  context 'when configured with Henkei.configure' do
    describe 'with pdf_config override' do
      before do
        Henkei.configure(
          pdf_defaults: :inline,
          pdf_config: {
            ocrDPI: 100
          }
        )
      end

      it 'writes overwritten config' do
        expect(File.read(Henkei::CONFIG_PATH))
          .to eq(File.read('spec/example_configs/inline_with_override.xml'))
      end

      after do
        Henkei.configure(pdf_defaults: :none)
      end
    end

    describe 'without pdf_config override' do
      before do
        Henkei.configure(pdf_defaults: :inline)
      end

      it 'writes standard config' do
        expect(File.read(Henkei::CONFIG_PATH))
          .to eq(File.read('spec/example_configs/inline.xml'))
      end

      after do
        Henkei.configure(pdf_defaults: :none)
      end
    end

    describe 'with missing config' do
      it 'raises TypeError for argument' do
        expect { Henkei.configure('') }.to raise_error(TypeError)
      end
    end
  end
end
