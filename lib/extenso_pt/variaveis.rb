# frozen_string_literal: true

# @author Hernani Rodrigues Vaz
module ExtensoPt
  # Parametrizar moeda
  #
  # @param [Hash] moeda as opcoes para parametrizar moeda/fracao
  # @option moeda [Symbol] :lc locale do extenso -
  #  portugues de portugal (:pt) portugues do brasil (:br)
  # @option moeda [String] :moeda_singular moeda no singular
  # @option moeda [String] :fracao_singular fracao no singular
  # @option moeda [String] :moeda_plural moeda no plural
  # @option moeda [String] :fracao_plural fracao no plural
  # @return [void]
  def self.epmo(moeda)
    # parametrizacao por defeito
    #  the first mention of a @<variable> creates that instance variable
    #  in the current object ie: self = ExtensoPt
    @lc = moeda[:lc] || :pt
    @ms = moeda[:moeda_singular] || 'EURO'
    @fs = moeda[:fracao_singular] || 'CÊNTIMO'
    @mp = moeda[:moeda_plural] || @ms + 'S'
    @fp = moeda[:fracao_plural] || @fs + 'S'
  end

  # Parametrizar parte inteira e fracionaria
  #
  # @param [String] digitos do valor monetario a converter
  # @return [void]
  def self.epif(digitos)
    # cria array de grupos 3 digitos da parte inteira
    #  ex: 123022.12 => [22, 123]
    @ai = digitos[/^\d+/].to_s.reverse.scan(/\d{1,3}/)
                         .map { |i| i.reverse.to_i }

    # obtem parte fracionaria da string digitos
    #  ex: 123022.12 => 12
    # arredondada a 2 casas decimais (centimos/centavos)
    @nf = (digitos[/\.\d*/].to_f * 100).round
  end

  # Array grupos 3 digitos da parte inteira
  #
  # @return array[Integer] attr_reader
  def self.ivai
    @ai
  end

  # Soma grupos 1-8 de digitos
  #
  # @return [Integer] soma digitos
  def self.c124
    @ai[0].to_i + @ai[1].to_i * 2 + @ai[2..-1].to_a.inject(:+).to_i * 2
  end

  # Controla proposicao DE
  #
  # @return [true, false] sim ou nao proposicao DE
  def self.cpde?
    @ai[0..1].to_a.inject(:+).to_i.zero? &&
      @ai[2..-1].to_a.inject(:+).to_i.positive?
  end
  # private_class_method :c124, :cpde?
end
