# frozen_string_literal: true

require 'bigdecimal/util'
require 'extenso_pt/version'
require 'extenso_pt/constantes'
require 'extenso_pt/module'

# @author Hernani Rodrigues Vaz
module ExtensoPt
  class Error < StandardError; end

  # Produz extenso(s)) em portugues de portugal ou brasil
  #
  # @param [Hash] moeda as opcoes para parametrizar a moeda/fracao
  # @option moeda [Symbol] :lc locale do extenso -
  #  portugues de portugal (:pt) ou brasil (:br)
  # @option moeda [String] :msingular moeda no singular
  # @option moeda [String] :fsingular fracao no singular
  # @option moeda [String] :mplural moeda no plural
  # @option moeda [String] :fplural fracao no plural
  # @return [String, Array, Hash] string extenso
  #  se objecto for (String, Float, Integer),
  #  array<extensos> se objecto for (Array, Range),
  #  hash<extensos> se objecto for (Hash)
  def extenso(moeda = { lc: :pt, msingular: 'EURO', fsingular: 'CÊNTIMO' })
    # parametrizacao por defeito para :br
    if moeda[:lc] == :br && !moeda[:msingular] && !moeda[:mplural]
      moeda.merge!(msingular: 'REAL', mplural: 'REAIS', fsingular: 'CENTAVO')
    end

    # parametrizar moeda
    ExtensoPt.psingular(moeda)
    ExtensoPt.pplural(moeda)

    # cria extenso(s) em portugues de portugal ou brasil
    ExtensoPt.o2e(self)
  end
end

# permite obter um Hash com valores numericos convertidos nos seus extensos
class Hash
  include ExtensoPt
end

# permite obter um Array com valores numericos convertidos nos seus extensos
class Array
  include ExtensoPt
end

# permite obter um Array com valores numericos convertidos nos seus extensos
class Range
  include ExtensoPt
end

# permite obter o extenso de Float
class Float
  include ExtensoPt
end

# permite obter o extenso ou numeral romano de Integer
class Integer
  include ExtensoPt

  # Produz numeracao romana a partir do inteiro
  #
  # @return [String] numeracao romana
  def romana
    return "-#{i2r(-self)}" if negative?

    i2r(self)
  end

  # Recursivamente produz numeral romano
  #
  # @param [Integer] numero a converter em numeral romano
  # @return [String] numeral romano
  def i2r(numero)
    return '' if numero.zero?

    ROMAN.each { |r, v| return r.to_s + i2r(numero - v) if v <= numero }
  end
end

# permite obter o extenso duma string de digitos ou
#  inteiro duma string numeral romano
class String
  include ExtensoPt

  # Testa se string contem numeracao romana
  #
  # @return [true, false] sim ou nao numeracao romana
  def romana?
    RO_RE.match?(upcase)
  end

  # Produz inteiro a partir da numeracao romana
  #  ou numeracao romana a partir de string digitos
  #
  # @return [Integer, String] inteiro ou numeracao romana
  def romana
    return -self[/[^-]+/].romana if /-+/.match?(self)
    return self[/^\d+/].to_i.romana if /^\d+/.match?(self)
    return 0 unless romana?

    r2i(upcase, 0)
  end

  # Recursivamente produz inteiro
  #
  # @param [String] numeral romano em convercao
  # @param [Integer] ultimo numeral convertido
  # @return [Integer] inteiro do numeral romano
  def r2i(numeral, ultimo)
    return 0 if numeral.empty?

    v = ROMAN[numeral[-1].to_sym]
    v < ultimo ? (r2i(numeral.chop, v) - v) : (r2i(numeral.chop, v) + v)
  end
end
