# frozen_string_literal: true

# @author Hernani Rodrigues Vaz
module ExtensoPt
  # Recursivamente produz numeral romano
  #
  # @param [Integer] numero a converter em numeral romano
  # @return [String] numeral romano
  def self.ri2r(numero)
    return '' if numero <= 0

    ROMAN.each { |r, v| return r.to_s + ri2r(numero - v) if v <= numero }
  end

  # Recursivamente produz inteiro
  #
  # @param [String] numeral romano em convercao
  # @param [Integer] ultimo numeral convertido
  # @return [Integer] inteiro do numeral romano
  def self.rr2i(numeral, ultimo)
    return 0 if numeral.empty?

    v = ROMAN[numeral[-1].to_sym]
    v < ultimo ? (rr2i(numeral.chop, v) - v) : (rr2i(numeral.chop, v) + v)
  end
end
