# frozen_string_literal: true

# @author Hernani Rodrigues Vaz
module ExtensoPt
  # Produz numeral romano a partir de inteiro
  #
  # @param [Integer] inteiro a converter
  # @return [String] numeral romano do inteiro
  def self.ri2r(inteiro)
    return '' if inteiro.zero?

    ROMAN.each do |r, v|
      return r.to_s + ri2r(inteiro - v) if v <= inteiro
    end
  end

  # Produz inteiro a partir de numeral romano
  #
  # @param [String] numeral romano a converter
  # @param [Integer] ultimo valor convertido
  # @return [Integer] inteiro do numeral romano
  def self.rr2i(numeral, ultimo)
    return 0 if numeral.empty?

    v = ROMAN[numeral[-1].to_sym]
    rr2i(numeral.chop, v) + (v < ultimo ? -v : v)
  end
end
