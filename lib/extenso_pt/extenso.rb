# frozen_string_literal: true

# @author Hernani Rodrigues Vaz
module ExtensoPt
  # extensos 1-19; 20-90; 100-900
  e013a = %w[UM DOIS TRÊS QUATRO CINCO SEIS SETE OITO NOVE DEZ ONZE DOZE TREZE].freeze
  e019a = %w[QUINZE DEZASSEIS DEZASSETE DEZOITO DEZANOVE].freeze
  e090a = %w[VINTE TRINTA QUARENTA CINQUENTA SESSENTA SETENTA OITENTA NOVENTA].freeze
  e900a = %w[CEM CENTO DUZENTOS TREZENTOS QUATROCENTOS QUINHENTOS SEISCENTOS SETECENTOS OITOCENTOS NOVECENTOS].freeze
  A0020 = { pt: ['']     + e013a + ['CATORZE'] + e019a, br: ['']     + e013a + ['QUATORZE'] + e019a }.freeze
  A0100 = { pt: ['', ''] + e090a,                       br: ['', ''] + e090a                        }.freeze
  A1000 = { pt: ['']     + e900a,                       br: ['']     + e900a                        }.freeze

  # singular extensos 1e3 ate 1e24
  # @note escala segundo convencao entre varios paises,
  #   na 9a Conferencia Geral de Pesos e Medidas (12-21 de Outubro de 1948),
  #   organizada pelo Bureau International des Poids et Mesures
  # @example
  #   1 000 000 = milhao
  #   1 000 000 000 000 = biliao
  #   1 000 000 000 000 000 000 = triliao
  #   1 000 000 000 000 000 000 000 000 = quadriliao
  #   1 000 000 000 000 000 000 000 000 000 000 = quintiliao
  #   1 000 000 000 000 000 000 000 000 000 000 000 000 = sextiliao
  S1E24 = {
    pt: ['', 'MIL', ' MILHÃO', ' MIL MILHÃO', ' BILIÃO', ' MIL BILIÃO', ' TRILIÃO', ' MIL TRILIÃO'],
    br: ['', 'MIL', ' MILHÃO', ' BILHÃO', ' TRILHÃO', ' QUADRILHÃO', ' QUINTILHÃO', ' SEXTILHÃO']
  }.freeze

  # plural extensos 1e3 ate 1e24
  # @note escala segundo convencao entre varios paises,
  #   na 9a Conferencia Geral de Pesos e Medidas (12-21 de Outubro de 1948),
  #   organizada pelo Bureau International des Poids et Mesures
  P1E24 = {
    pt: ['', ' MIL', ' MILHÕES', ' MIL MILHÕES', ' BILIÕES', ' MIL BILIÕES', ' TRILIÕES', ' MIL TRILIÕES'],
    br: ['', ' MIL', ' MILHÕES', ' BILHÕES', ' TRILHÕES', ' QUADRILHÕES', ' QUINTILHÕES', ' SEXTILHÕES']
  }.freeze

  # Parametrizar variaveis da moeda
  #
  # @param [Hash<String, Symbol>] moeda opcoes parametrizar moeda/fracao
  # @option moeda [Symbol] :lc locale do extenso - portugues de portugal (:pt) portugues do brasil (:br)
  # @option moeda [String] :moeda_singular moeda no singular
  # @option moeda [String] :fracao_singular fracao no singular
  # @option moeda [String] :moeda_plural moeda no plural
  # @option moeda [String] :fracao_plural fracao no plural
  def self.parametrizar_moeda(moeda)
    # parametrizacao por defeito
    # the first mention of a @<variable> creates that instance variable in the current object ie: self = ExtensoPt
    @lc = moeda[:lc] || :pt
    @ms = moeda[:moeda_singular] || 'EURO'
    @fs = moeda[:fracao_singular] || 'CÊNTIMO'
    @mp = moeda[:moeda_plural] || "#{@ms}S"
    @fp = moeda[:fracao_plural] || "#{@fs}S"
  end

  # Parametrizar variaveis parte inteira e fracionaria
  #
  # @param [String] digitos do valor monetario a converter
  def self.parametrizar_grupos(digitos)
    # cria array de grupos 3 digitos da parte inteira ex: 123022.12 => [22, 123]
    @ai = digitos[/^\d+/].reverse.scan(/\d{1,3}/).map { |grp| Integer(grp.reverse) }

    # obtem parte fracionaria da string digitos arredondada a 2 casas decimais ex: 123022.124 => 12, 123022.125 => 13
    @nf = (Float(digitos[/\.\d*/]) * 100).round
  end

  # @return [Array<Integer>] grupos 3 digitos da parte inteira
  def self.grupos
    @ai
  end

  # @return [Integer] soma grupos 1-8 de digitos
  def self.soma_grupos
    Integer(@ai[0]) + Integer(@ai[1] || 0) * 2 + Integer(@ai[2..].to_a.inject(:+) || 0) * 2
  end

  # @return [true, false] sim ou nao proposicao DE
  def self.testa_de?
    Integer(@ai[0..1].inject(:+)).zero? && Integer(@ai[2..].to_a.inject(:+) || 0).positive?
  end

  # @param [Integer] mil o valor dum grupo 3 digitos a converter
  # @return [String] extenso das centenas em portugues de portugal ou brasil
  def self.centenas(mil)
    cem = mil > 100
    A1000[@lc][(cem ? 1 : 0) + mil / 100] + (cem && (mil % 100).positive? ? ' E ' : '')
  end

  # @param [Integer] cem a centena dum grupo 3 digitos a converter
  # @return [String] extenso das dezenas em portugues de portugal ou brasil
  def self.dezenas(cem)
    A0100[@lc][cem / 10] + (cem > 20 && (cem % 10).positive? ? ' E ' : '')
  end

  # @param [Integer] cem a centena dum grupo 3 digitos a converter
  # @return [String] extenso das unidades em portugues de portugal ou brasil
  def self.unidades(cem)
    A0020[@lc][cem < 20 ? cem : cem % 10]
  end

  # @return [String] proposicao E & extenso da parte fracionaria em portugues de portugal ou brasil
  def self.fracionaria
    if @nf.positive?
      "#{soma_grupos.positive? ? ' E ' : ''}#{dezenas(@nf)}#{unidades(@nf)} #{@nf > 1 ? @fp : @fs}"
    else
      ''
    end
  end

  # @return [String] final da moeda em portugues de portugal ou brasil
  def self.final
    som = soma_grupos
    if som.positive?
      # proposicao DE entre parte inteira e moeda & moeda singular/plural
      "#{testa_de? ? ' DE ' : ' '}#{som > 1 ? @mp : @ms}"
    else
      ''
    end + fracionaria
  end

  # @param [Integer] pos posicao actual nos grupos 3 digitos
  # @return [String] proposicao E entre grupos 3 digitos
  def self.proposicao_grupo(pos)
    grp = @ai[pos - 1]
    if pos.positive? && grp.positive?
      grp > 100 ? ' ' : ' E '
    else
      ''
    end
  end

  # @param [Integer] pos posicao actual nos grupos 3 digitos
  # @return [String] qualificador grupo de 3 digitos em portugues de portugal ou brasil
  def self.qualificador_grupo(pos)
    grp = @ai[pos]
    if grp.positive?
      grp > 1 ? P1E24[@lc][pos] : S1E24[@lc][pos]
    else
      ''
    end + proposicao_grupo(pos)
  end

  # @param [Integer] pos posicao actual nos grupos 3 digitos
  # @return [String] extenso do grupo 3 digitos em portugues de portugal ou brasil
  def self.extenso_grupo(pos)
    grp = @ai[pos]
    dez = grp % 100
    # caso especial MIL EUROS
    if pos == 1 && grp == 1
      ''
    else
      # extenso das centenas + extenso das dezenas + extenso das unidades
      "#{centenas(grp)}#{dezenas(dez)}#{unidades(dez)}"
    end + qualificador_grupo(pos)
  end

  # @param [Integer] pos posicao no grupo 3 digitos
  # @param [String] ext extenso em construcao
  # @return [String] extenso do valor monetario completo
  def self.extenso_completo(pos = 0, ext = '')
    # testa fim do valor monetario
    if pos >= @ai.count
      # caso especial de zero
      (soma_grupos + @nf).zero? ? "ZERO #{@mp}" : "#{ext}#{final}"
    else
      # converte grupo 3 digitos na posicao corrente & envoca proxima posicao
      extenso_completo(pos + 1, extenso_grupo(pos) + ext)
    end
  end
end
