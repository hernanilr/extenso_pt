# frozen_string_literal: true

require 'bigdecimal/util'
require 'extenso_pt/version'
require 'extenso_pt/constantes'
require 'extenso_pt/extenso'
require 'extenso_pt/romana'

# @author Hernani Rodrigues Vaz
module ExtensoPt
  class Error < StandardError; end

  # Produz extenso em portugues de portugal ou brasil
  # (valor numerico pode ser uma string digitos)
  #
  # @param [Hash] moeda as opcoes para parametrizar moeda/fracao
  # @option moeda [Symbol] :lc locale do extenso -
  #  portugues de portugal (:pt) portugues do brasil (:br)
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
    ExtensoPt.epsi(moeda)
    ExtensoPt.eppl(moeda)

    # cria extenso em portugues de portugal ou brasil
    ExtensoPt.eo2e(self)
  end

  # Testa se contem numeracao romana
  #
  # @return [true, false] sim ou nao numeracao romana
  def romana?
    is_a?(String) ? RO_RE.match?(upcase) : false
  end

  # Produz numeracao romana a partir de valor numerico
  # ou valor numerico a partir da numeracao romana
  # (valor numerico pode ser uma string digitos)
  #
  # @return [String, Integer] numeracao romana ou valor numerico
  def romana
    # converte os valores do Hash
    if is_a?(Hash) then map { |k, v| [k, v.romana] }.to_h
    # converte objecto num Array com os valores convertidos
    elsif respond_to?(:to_a) then to_a.map(&:romana)
    # numeracao romana a partir de inteiro ou string digitos
    # (ignora parte fracionaria)
    elsif (inteiro = to_i) != 0 then ExtensoPt.ri2r(inteiro)
    # inteiro a partir da numeracao romana
    else RO_RE.match?(to_s) ? ExtensoPt.rr2i(upcase, 0) : ''
    end
  end
end

# permite obter um Hash com valores convertidos
class Hash
  include ExtensoPt
end

# permite obter um Array com valores convertidos
class Array
  include ExtensoPt
end

# permite obter um Array com valores do Range convertidos
class Range
  include ExtensoPt
end

# permite obter Float ou Integer convertidos
class Numeric
  include ExtensoPt
end

# permite obter strings convertidas
class String
  include ExtensoPt
end
