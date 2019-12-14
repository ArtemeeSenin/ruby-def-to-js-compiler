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
  ]

  def initialize(code)
    @code = code
  end

  def tokenize
    until @code.empty?
      TOKEN_TYPES.each do |type, re|
        re = /\A(#{re})/
        if @code =~ re
          value = $1
          @code = @code[value.length..-1]
          return Token.new(type, value)
        end
      end
    end
  end
end

Token = Struct.new(:type, :value)