# frozen_string_literal: true

require 'bigdecimal/util'
require 'extenso_pt/constantes'
require 'extenso_pt/variaveis'
require 'extenso_pt/extenso'
require 'extenso_pt/romana'
require 'extenso_pt/version'

# @author Hernani Rodrigues Vaz
module ExtensoPt
  class Error < StandardError; end
  # Produz extenso em portugues de portugal ou brasil a partir de valor numerico
  #
  # @note valor numerico pode ser uma string digitos
  # @param [Hash<String, Symbol>] moeda opcoes parametrizar moeda/fracao
  # @option moeda [Symbol] :lc locale do extenso - portugues de portugal (:pt) portugues do brasil (:br)
  # @option moeda [String] :moeda_singular moeda no singular
  # @option moeda [String] :fracao_singular fracao no singular
  # @option moeda [String] :moeda_plural moeda no plural
  # @option moeda [String] :fracao_plural fracao no plural
  # @return [String, Array<String>, Hash<String>]
  #  String<extenso> se objecto for (String, Float, Integer),
  #  Array<extensos> se objecto for (Array, Range),
  #  Hash<extensos>  se objecto for (Hash)
  def extenso(moeda = { lc: :pt })
    # parametrizar moeda
    ExtensoPt.prmo(moeda.parametrizar)

    processa
  end

  # Processa objeto criando extenso(s) em portugues de portugal ou brasil
  #
  # @return (see #extenso)
  def processa
    # converte valores do Hash nos seus extensos
    if is_a?(Hash) then map { |k, v| [k, v.processa] }.to_h
    # converte objecto num Array com os valores convertidos nos seus extensos
    elsif respond_to?(:to_a) then to_a.map(&:processa)
    else
      # converte objeto em string digitos utilizando bigdecimal para
      #  evitar problemas com aritmetica virgula flutuante em valores >1e12
      # parametrizar parte inteira/fracionaria (@ai, @nf) da string digitos
      ExtensoPt.prif(to_d.to_s('F'))

      # processar extenso - valores >1e24 sao ignorados
      ExtensoPt.cvai.count > 8 ? '' : ExtensoPt.ejun
    end
  end

  # @return [Hash<String, Symbol>] parametrizacao moeda por defeito para :br & inferencias & errados
  def parametrizar
    if value?(:br) && %i[moeda_singular moeda_plural].all? { |e| !keys.include?(e) }
      { lc: :br, moeda_singular: 'REAL', moeda_plural: 'REAIS', fracao_singular: 'CENTAVO', fracao_plural: 'CENTAVOS' }
    else
      inferir_singular.eliminar_errados
    end
  end

  # @return [Hash<String, Symbol>] parametrizacao moeda singular inferindo do plural
  def inferir_singular
    self[:moeda_singular]  ||= (fetch(:moeda_plural,  '')[0..-2] if fetch(:moeda_plural,  '')[-1] == 'S')
    self[:fracao_singular] ||= (fetch(:fracao_plural, '')[0..-2] if fetch(:fracao_plural, '')[-1] == 'S')
    self
  end

  # @return [Hash<String, Symbol>] parametrizacao moeda eliminar parametros errados
  def eliminar_errados
    keep_if { |k, v| MOEDA.include?(k) && (k != :lc || EXTLC.include?(v)) }
  end

  # @return [true, false] testa se contem numeracao romana
  def romana?
    is_a?(String) ? RO_RE.match?(upcase) : false
  end

  # @note valor numerico pode ser uma string digitos
  # @return [String, Integer] numeracao romana a partir de numerico ou inteiro a partir da numeracao romana
  def romana
    # converte os valores do Hash
    if is_a?(Hash) then map { |k, v| [k, v.romana] }.to_h
    # converte objecto num Array com os valores convertidos
    elsif respond_to?(:to_a) then to_a.map(&:romana)
    # numeracao romana a partir de inteiro ou string digitos (ignora parte fracionaria)
    elsif (inteiro = to_i) != 0 then ExtensoPt.ri2r(inteiro)
    # inteiro a partir da numeracao romana
    else RO_RE.match?(to_s) ? ExtensoPt.rr2i(upcase, 0) : ''
    end
  end
end

# converter Hash
class Hash; include ExtensoPt; end
# converter Array
class Array; include ExtensoPt; end
# converter Range
class Range; include ExtensoPt; end
# converter Float, Integer
class Numeric; include ExtensoPt; end
# converter String digitos
class String; include ExtensoPt; end
