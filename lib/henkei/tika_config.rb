# frozen_string_literal: true

require 'ox'

class Henkei
  class TikaConfig
    INLINE_PDF_CONFIG = {
      allowExtractionForAccessibility: true,
      extractInlineImages: true
    }

    RENDERED_PDF_CONFIG = {
      allowExtractionForAccessibility: true,
      ocrStrategy: 'ocr_only',
      ocrImageType: 'grey',
      ocrDPI: 300
    }

    def initialize(pdf_defaults: :none, pdf_config: {})
      @tika_config = base_config

      @pdf_config =
        case pdf_defaults
        when :inline then INLINE_PDF_CONFIG
        when :rendered then RENDERED_PDF_CONFIG
        else {}
        end

      @pdf_config.merge!(pdf_config)

      if pdf_defaults != :none
        insert_pdf_configuration
      end
    end

    def insert_pdf_configuration
      properties = @tika_config.nodes.find do |node|
        node.value == 'properties'
      end

      parsers = Ox::Element.new('parsers')
      parsers << disable_default
      parsers << pdf_image_parser
      properties << parsers
    end

    def pdf_image_parser
      pdf_parser = Ox::Element.new('parser')
      pdf_parser[:class] = 'org.apache.tika.parser.pdf.PDFParser'
      params = Ox::Element.new('params')

      @pdf_config.each do |key, value|
        param = Ox::Element.new('param')
        param[:name] = key.to_s
        param[:type] = type_for_xml(value)
        param << value.to_s
        params << param
      end

      pdf_parser << params
      pdf_parser
    end

    def disable_default
      disable_default = Ox::Element.new('parser')
      exclusion = Ox::Element.new('parser-exclude')
      disable_default[:class] = 'org.apache.tika.parser.DefaultParser'
      exclusion[:class] = 'org.apache.tika.parser.pdf.PDFParser'
      disable_default << exclusion
      disable_default
    end

    def write!(location: Henkei::CONFIG_PATH)
      File.open(location, 'w') do |file|
        file.write(as_string)
      end
    end

    def as_string
      Ox.dump(@tika_config).chomp.reverse.chomp.reverse
    end

    private

    def type_for_xml(obj)
      case obj
      when String then 'string'
      when TrueClass, FalseClass then 'bool'
      else 'int'
      end
    end

    def base_config
      wrapper = Ox::Document.new(version: '1.0')
      properties = Ox::Element.new('properties')
      service_loader = Ox::Element.new('service-loader')
      service_loader[:initializableProblemHandler] = 'ignore'

      properties << service_loader
      wrapper << properties
      wrapper
    end
  end
end
