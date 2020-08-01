# frozen_string_literal: true

# @author Hernani Rodrigues Vaz
module ExtensoPt
  # Parametrizar variaveis da moeda
  #
  # @param [Hash<String, Symbol>] moeda opcoes parametrizar moeda/fracao
  # @option moeda [Symbol] :lc locale do extenso - portugues de portugal (:pt) portugues do brasil (:br)
  # @option moeda [String] :moeda_singular moeda no singular
  # @option moeda [String] :fracao_singular fracao no singular
  # @option moeda [String] :moeda_plural moeda no plural
  # @option moeda [String] :fracao_plural fracao no plural
  def self.prmo(moeda)
    # parametrizacao por defeito
    # the first mention of a @<variable> creates that instance variable in the current object ie: self = ExtensoPt
    @lc = moeda[:lc] || :pt
    @ms = moeda[:moeda_singular] || 'EURO'
    @fs = moeda[:fracao_singular] || 'CÊNTIMO'
    @mp = moeda[:moeda_plural] || @ms + 'S'
    @fp = moeda[:fracao_plural] || @fs + 'S'
  end

  # Parametrizar variaveis parte inteira e fracionaria
  #
  # @param [String] digitos do valor monetario a converter
  def self.prif(digitos)
    # cria array de grupos 3 digitos da parte inteira ex: 123022.12 => [22, 123]
    @ai = digitos[/^\d+/].to_s.reverse.scan(/\d{1,3}/).map { |i| i.reverse.to_i }

    # obtem parte fracionaria da string digitos arredondada a 2 casas decimais ex: 123022.12 => 12
    @nf = (digitos[/\.\d*/].to_f * 100).round
  end

  # @return [Array<Integer>] grupos 3 digitos da parte inteira
  def self.cvai
    @ai
  end

  # @return [Integer] soma grupos 1-8 de digitos
  def self.c124
    @ai[0].to_i + @ai[1].to_i * 2 + @ai[2..-1].to_a.inject(:+).to_i * 2
  end

  # @return [true, false] sim ou nao para controle proposicao DE
  def self.cde?
    @ai[0..1].to_a.inject(:+).to_i.zero? && @ai[2..-1].to_a.inject(:+).to_i.positive?
  end

  # @return [true, false] sim ou nao para controle proposicao E
  def self.cnf?
    @nf.positive?
  end
  # private_class_method :c124, :cde?, :cnf?
end
