# frozen_string_literal: true

# @author Hernani Rodrigues Vaz
module ExtensoPt
  # numeracao romana ordem decrescente (ordem importante)
  ROMAN = { M: 1000, CM: 900, D: 500, CD: 400, C: 100, XC: 90, L: 50, XL: 40, X: 10, IX: 9, V: 5, IV: 4, I: 1 }.freeze

  # @param [Integer] inteiro a converter
  # @return [String] numeral romano do inteiro
  def self.ri2r(inteiro)
    return '' if inteiro.zero?

    ROMAN.each { |srm, val| return "#{srm}#{ri2r(inteiro - val)}" if val <= inteiro }
  end

  # @param [String] numeral romano a converter
  # @param [Integer] ultimo valor convertido
  # @return [Integer] inteiro do numeral romano
  def self.rr2i(numeral, ultimo)
    return 0 if numeral.empty?

    val = ROMAN[numeral[-1].to_sym]
    rr2i(numeral.chop, val) + (val < ultimo ? -val : val)
  end
end
