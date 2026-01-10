require_relative "sober_bbcode/version"
require_relative "sober_bbcode/configuration"
require_relative "sober_bbcode/nodes"
require_relative "sober_bbcode/tokenizer"
require_relative "sober_bbcode/parser"
require_relative "sober_bbcode/compiler"

module SoberBBCode
  class Error < StandardError; end

  class << self
    def configure
      yield(configuration)
    end

    def configuration
      @configuration ||= Configuration.new
    end
    
    def parse(text)
      tokenizer = Tokenizer.new(text)
      tokens = tokenizer.tokenize
      parser = Parser.new(tokens)
      parser.parse
    end

    def render(text)
      root = parse(text)
      compiler = Compiler.new(root)
      compiler.to_html
    end
  end
end
