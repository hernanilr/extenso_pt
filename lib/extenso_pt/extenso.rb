# frozen_string_literal: true

# @author Hernani Rodrigues Vaz
module ExtensoPt
  # Produz extenso das centenas em portugues de portugal ou brasil
  #
  # @param [Integer] mil o valor dum grupo 3 digitos a converter
  # @return [String] extenso das centenas
  def self.e900(mil)
    A1000[@lc][(mil > 100 ? 1 : 0) + mil / 100] +
      (mil > 100 && (mil % 100).positive? ? ' E ' : '')
  end

  # Produz extenso das dezenas em portugues de portugal ou brasil
  #
  # @param [Integer] cem a centena dum grupo 3 digitos a converter
  # @return [String] extenso das dezenas
  def self.e090(cem)
    A0100[@lc][cem / 10] +
      (cem > 20 && (cem % 10).positive? ? ' E ' : '')
  end

  # Produz extenso das unidades em portugues de portugal ou brasil
  #
  # @param [Integer] cem a centena dum grupo 3 digitos a converter
  # @return [String] extenso das unidades
  def self.e009(cem)
    A0020[@lc][cem < 20 ? cem : cem % 10]
  end

  # @return [String] extenso da parte fracionaria em portugues de portugal ou brasil
  def self.ef99
    if cnf?
      e090(@nf) + e009(@nf) + ' ' + (@nf > 1 ? @fp : @fs)
    else
      ''
    end
  end

  # @return [String] final da moeda em portugues de portugal ou brasil
  def self.efim
    t = c124
    if t.positive?
      # proposicao DE entre parte inteira e moeda & moeda singular/plural & proposicao E entre moeda e parte fracionaria
      (cde? ? ' DE ' : ' ') + (t > 1 ? @mp : @ms) + (cnf? ? ' E ' : '')
    else
      ''
    end + ef99
  end

  # Produz proposicao E entre grupos 3 digitos
  #
  # @param [Integer] pos posicao actual nos grupos 3 digitos
  # @return [String] proposicao E entre grupos 3 digitos
  def self.edgs(pos)
    if pos.positive? && @ai[pos - 1].positive?
      @ai[pos - 1] > 100 ? ' ' : ' E '
    else
      ''
    end
  end

  # Produz qualificador grupo de 3 digitos em portugues de portugal ou brasil
  #
  # @param [Integer] pos posicao actual nos grupos 3 digitos
  # @return [String] qualificador grupo de 3 digitos
  def self.e124(pos)
    if @ai[pos].positive?
      @ai[pos] > 1 ? P1E24[@lc][pos] : S1E24[@lc][pos]
    else
      ''
    end + edgs(pos)
  end

  # Produz extenso de grupo 3 digitos em portugues de portugal ou brasil
  #
  # @param [Integer] pos posicao actual nos grupos 3 digitos
  # @return [String] extenso do grupo 3 digitos
  def self.edg3(pos)
    # caso especial MIL EUROS
    if pos == 1 && @ai[pos] == 1
      ''
    else
      # extenso das centenas + extenso das dezenas + extenso das unidades
      e900(@ai[pos]) + e090(@ai[pos] % 100) + e009(@ai[pos] % 100)
    end + e124(pos)
  end

  # Produz extenso da parte inteira e fracionaria
  #
  # @param [Integer] pos posicao no grupo 3 digitos
  # @param [String] ext extenso em construcao
  # @return [String] extenso do valor monetario
  def self.ejun(pos = 0, ext = '')
    # testa fim do valor monetario
    if pos >= @ai.count
      # caso especial de zero
      (c124 + @nf).zero? ? 'ZERO ' + @mp : ext + efim
    else
      # converte grupo 3 digitos na posicao corrente & envoca proxima posicao
      ejun(pos + 1, edg3(pos) + ext)
    end
  end
  # private_class_method :e900, :e090, :e009, :ef99, :efim,
  #                      :edgs, :e124, :edg3
end
