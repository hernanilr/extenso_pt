# frozen_string_literal: true

require('bigdecimal/util')
require('extenso_pt/extenso')
require('extenso_pt/romana')
require('extenso_pt/version')

# @author Hernani Rodrigues Vaz
module ExtensoPt
  # expressao regular da numeracao romana
  RO_RE = /^M*(D?C{0,3}|C[DM])(L?X{0,3}|X[LC])(V?I{0,3}|I[VX])$/i.freeze
  # chaves parametrizacao moeda permitidas
  MOEDA = %i[moeda_singular fracao_singular moeda_plural fracao_plural lc].freeze
  # somente portugues de portugal ou brasil permitidos, qualquer outro locale equivale usar :pt
  EXTLC = %i[pt br].freeze

  # Processa objeto criando extenso(s) em portugues de portugal ou brasil
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
    ExtensoPt.parametrizar_moeda(moeda.parametrizar)

    processa
  end

  # @return [Hash<String, Symbol>] parametrizacao moeda por defeito para :br & inferencias & errados
  def parametrizar
    if value?(:br) && %i[moeda_singular moeda_plural].all? { |syb| !keys.include?(syb) }
      { lc: :br, moeda_singular: 'REAL', moeda_plural: 'REAIS', fracao_singular: 'CENTAVO', fracao_plural: 'CENTAVOS' }
    else
      inferir_singular.eliminar_errados
    end
  end

  # @return [Hash<String, Symbol>] parametrizacao moeda singular inferindo do plural
  def inferir_singular
    mdp = fetch(:moeda_plural, '')
    frp = fetch(:fracao_plural, '')
    self[:moeda_singular] ||= (mdp[0..-2] if mdp[-1] == 'S')
    self[:fracao_singular] ||= (frp[0..-2] if frp[-1] == 'S')
    self
  end

  # @return [Hash<String, Symbol>] parametrizacao moeda eliminar parametros errados
  def eliminar_errados
    keep_if { |key, val| MOEDA.include?(key) && (key != :lc || EXTLC.include?(val)) }
  end

  # @return (see #extenso)
  def processa
    # converte num Array com os valores convertidos nos seus extensos
    return to_a.map(&:processa) if is_a?(Range) || is_a?(Array)
    # converte valores do Hash nos seus extensos
    return transform_values(&:processa) if is_a?(Hash)

    # converte objeto em string digitos utilizando bigdecimal para
    #  evitar problemas com aritmetica virgula flutuante em valores >1e12
    #  valores negativos sao convertidos em positivos
    # parametrizar parte inteira/fracionaria (@ai, @nf) da string digitos
    ExtensoPt.parametrizar_grupos(to_d.abs.to_s('F'))

    # processar extenso - valores >= 1e24 sao ignorados
    ExtensoPt.grupos.count > 8 ? '' : ExtensoPt.extenso_completo
  end

  # @note valor numerico pode ser uma string digitos
  # @return [String, Integer] numeracao romana a partir de numerico ou inteiro a partir da numeracao romana
  def romana
    # converte num Array com os valores convertidos
    return to_a.map(&:romana) if is_a?(Range) || is_a?(Array)
    # converte os valores do Hash
    return transform_values(&:romana) if is_a?(Hash)

    romana_base(to_i.abs)
  end

  # @return (see #romana)
  def romana_base(inteiro)
    # numeracao romana a partir de inteiro ou string digitos (ignora parte fracionaria & negativos)
    return ExtensoPt.ri2r(inteiro) unless inteiro.zero?

    # inteiro a partir da numeracao romana
    RO_RE.match?(to_s) ? ExtensoPt.rr2i(upcase, 0) : ''
  end

  # @return [true, false] testa se contem numeracao romana
  def romana?
    is_a?(String) ? RO_RE.match?(upcase) : false
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
