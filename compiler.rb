#!/usr/bin/env ruby
#
class Tokenizer
  TOKEN_TYPES = [
      [:def, /\bdef\b/],
      [:end, /\bend\b/],
      [:identifier, /\b[a-zA-Z]+\b/],
      [:integer, /\b[0-9]+\b/],
      [:oparen, /\(/],
      [:cparen, /\)/],
      [:comma, /,/],
  ]

  def initialize(code)
    @code = code
  end

  def tokenize
    tokens = []
    until @code.empty?
      tokens << tokenize_one_token
      @code = @code.strip
    end
    tokens
  end

  def tokenize_one_token
    TOKEN_TYPES.each do |type, re|
      re = /\A(#{re})/
      if @code =~ re
        value = $1
        @code = @code[value.length..-1]
        return Token.new(type, value)
      end
    end

    raise RuntimeError.new(
        "Could not match token on #{@code.inspect}"
    )
  end
end

Token = Struct.new(:type, :value)

tokens = Tokenizer.new(File.read("test.src")).tokenize
puts tokens.map(&:inspect).join("\n")

class Parser
  def initialize(tokens)
    @tokens = tokens
  end

  def parse
    parse_def
  end

  def parse_def
    consume(:def)
    name = consume(:identifier).value
    arg_names = parse_arg_names
    body = parse_expr
    consume(:end)
    DefNode.new(name, arg_names, body)
  end

  def parse_arg_names
    arg_names = []
    consume(:oparen)
    if peek(:identifier)
      arg_names << consume(:identifier).value
      while peek(:comma)
        consume(:comma)
        arg_names << consume(:identifier).value
      end
    end
    consume(:cparen)
    arg_names
  end

  def parse_expr
    if peek(:integer)
      parse_integer
    else
      parse_call
    end
  end

  def parse_integer
    IntegerNode.new(consume(:integer).value.to_i)
  end

  def parse_call
    name = consume(:identifier).value
    arg_exprs = parse_arg_exprs
    CallNode.new(name, arg_exprs)
  end

  def parse_arg_exprs
    arg_exprs = []
    consume(:oparen)
    unless peek(:cparen)
      arg_exprs << parse_expr
      while peek(:comma)
        consume(:comma)
        arg_exprs << parse_expr
      end
    end
    consume(:cparen)
    arg_exprs
  end

  def peek(expected_type)
    @tokens.fetch(0).type == expected_type
  end

  def consume(expected_type)
    token = @tokens.shift
    if token.type == expected_type
      token
    else
      raise RuntimeError.new(
          "Expected token type #{expected_type} but got #{token.type.inspect}"
      )
    end
  end
end

DefNode = Struct.new(:name, :arg_names, :body)
IntegerNode = Struct.new(:integer)
CallNode = Struct.new(:name, :arg_expr)

tree = Parser.new(tokens).parse
p tree
