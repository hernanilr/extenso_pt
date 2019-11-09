# frozen_string_literal: true

# @author Hernani Rodrigues Vaz
module ExtensoPt
  # Produz extenso das centenas em portugues de portugal ou brasil
  #
  # @param [Integer] mil o valor dum grupo 3 digitos a converter
  # @return [String] extenso das centenas
  def self.e900(mil)
    A1000[@lc][(mil > 100 ? 1 : 0) + mil / 100] +
      (mil > 100 && (mil % 100).positive? ? ' E ' : '') # proposicao
  end

  # Produz extenso das dezenas em portugues de portugal ou brasil
  #
  # @param [Integer] cem a centena dum grupo 3 digitos a converter
  # @return [String] extenso das dezenas
  def self.e090(cem)
    A0100[@lc][cem / 10] +
      (cem > 20 && (cem % 10).positive? ? ' E ' : '') # proposicao
  end

  # Produz extenso das unidades em portugues de portugal ou brasil
  #
  # @param [Integer] cem a centena dum grupo 3 digitos a converter
  # @return [String] extenso das unidades
  def self.e009(cem)
    A0020[@lc][cem < 20 ? cem : cem % 10]
  end

  # Produz extenso da parte fracionaria em portugues de portugal ou brasil
  #
  # @return [String] extenso da parte fracionaria
  def self.ef99
    # parametrizacao por defeito
    @cs ||= 'CÊNTIMO'
    @cp ||= @ms + 'S'

    if @nf.positive?
      e090(@nf) + e009(@nf) + (@nf > 1 ? ' ' + @cp : ' ' + @cs)
    else
      ''
    end
  end

  # Produz final da moeda em portugues de portugal ou brasil
  #
  # @return [String] final da moeda
  def self.efim
    # parametrizacao por defeito
    @ms ||= 'EURO'
    @mp ||= @ms + 'S'

    # proposicao DE entre parte inteira e moeda
    emo = @de ? ' DE' : ''
    # moeda singular/plural
    emo += @tt > 1 ? ' ' + @mp : ' ' + @ms if @tt.positive?
    # proposicao E entre moeda e parte fracionaria
    # extenso da parte fracionaria
    emo + (@tt.positive? && @nf.positive? ? ' E ' : '') + ef99
  end

  # Produz separador entre grupos 3 digitos
  #
  # @param [Integer] pos posicao actual nos grupos 3 digitos
  # @return [String] separador entre grupos 3 digitos
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
  # @return [String] extenso grupo 3 digitos
  def self.edg3(pos)
    # caso especial MIL EUROS
    if pos == 1 && @ai[pos] == 1
      ''
    else
      e900(@ai[pos]) + e090(@ai[pos] % 100) + e009(@ai[pos] % 100)
    end + e124(pos)
  end

  # Parametrizar controle singular/plural & proposicoes
  #
  # @return [void]
  def self.epsp
    # soma grupos 1,2 (primeiros 6 digitos)
    @s6 = @ai[0].to_i + @ai[1].to_i * 2
    # soma grupos 3.. (digitos acima de 6)
    @m6 = @ai[2..-1].to_a.inject(:+).to_i * 2
    # parametrizar controle de proposicao E & singular/plural
    @tt = @s6 + @m6
    # parametrizar controle de proposicao DE
    @de = @s6.zero? && @m6.positive?
  end

  # Produz extenso em portugues de portugal ou brasil
  #
  # @param [Integer] pos posicao actual nos grupos 3 digitos do valor monetario
  # @param [String] ext extenso em construcao
  # @return [String] o extenso dum valor monetario
  def self.etot(pos, ext)
    # testa fim do valor monetario
    if pos >= @ai.count
      # parametrizar variaveis de controle
      epsp

      # caso especial zero
      (@tt + @nf).zero? ? 'ZERO ' + @mp : ext + efim
    else
      # tratamento de grupo 3 digitos
      etot(pos + 1, edg3(pos) + ext)
    end
  end

  # Parametrizar parte inteira/fracionaria da string digitos
  #
  # @param [String] digitos do valor monetario
  # @return [void]
  def self.epif(dig)
    # parametrizacao por defeito
    # the first mention of an @<variable> creates the
    # instance variable in the current object ie: self = ExtensoPt
    @lc ||= :pt

    # converte parte inteira da string digitos em array com grupos de 3 digitos
    #  ex: 123022.12 => [22, 123]
    @ai = dig[/^\d+/].to_s.reverse.scan(/\d{1,3}/).map { |i| i.reverse.to_i }

    # obtem parte fracionaria da string digitos
    #  ex: 123022.12 => 12
    # arredondada a 2 casas decimais (centimos/centavos)
    @nf = (dig[/\.\d*/].to_f * 100).round
  end

  # Converte objeto criando extenso(s) em portugues de portugal ou brasil
  #
  # @param [Object] obj objeto a converter
  #  (String, Float, Integer, Array, Range, Hash)
  # @return [String, Array, Hash] string extenso
  #  se objecto for (String, Float, Integer),
  #  array<extensos> se objecto for (Array, Range),
  #  hash<extensos> se objecto for (Hash)
  def self.eo2e(obj)
    # converte os valores do Hash nos seus extensos
    if obj.is_a?(Hash) then obj.map { |k, v| [k, eo2e(v)] }.to_h
    # converte objecto num Array com os valores convertidos em extensos
    elsif obj.respond_to?(:to_a) then obj.to_a.map { |a| eo2e(a) }
    else
      # converte objeto em string digitos utilizando bigdecimal para
      #  evitar problemas com aritmetica virgula flutuante em valores >1e12
      # parametrizar parte inteira/fracionaria (@ai, @nf) da string digitos
      epif(obj.to_d.to_s('F'))

      # processar extenso - valores >1e24 sao ignorados
      @ai.count > 8 ? '' : etot(0, '')
    end
  end

  # Parametrizar moeda inferindo singular a partir do plural
  #
  # @param [Hash] moeda as opcoes para parametrizar moeda/fracao
  # @option moeda [Symbol] :lc locale do extenso -
  #  portugues de portugal (:pt) portugues do brasil (:br)
  # @option moeda [String] :msingular moeda no singular -
  #  inferido do plural menos"S"
  # @option moeda [String] :fsingular fracao no singular -
  #  inferido do plural menos "S"
  # @option moeda [String] :mplural moeda no plural
  # @option moeda [String] :fplural fracao no plural
  # @return [void]
  def self.epsi(moeda)
    @ms = moeda[:msingular] ||
          (moeda[:mplural].to_s[-1] == 'S' ? moeda[:mplural][0..-2] : 'EURO')
    @cs = moeda[:fsingular] ||
          (moeda[:fplural].to_s[-1] == 'S' ? moeda[:fplural][0..-2] : 'CÊNTIMO')
  end

  # Parametrizar moeda inferindo plural a partir do singular
  #
  # @param [Hash] moeda as opcoes para parametrizar moeda/fracao
  # @option moeda [Symbol] :lc locale do extenso -
  #  portugues de portugal (:pt) portugues do brasil (:br)
  # @option moeda [String] :msingular moeda no singular
  # @option moeda [String] :fsingular fracao no singular
  # @option moeda [String] :mplural moeda no plural -
  #  inferido do singular mais "S"
  # @option moeda [String] :fplural fracao no plural -
  #  inferido do singular mais "S"
  # @return [void]
  def self.eppl(moeda)
    # somente [:pt, :br]
    @lc = EXTLC.include?(moeda[:lc]) ? moeda[:lc] : :pt

    @mp = moeda[:mplural] || @ms + 'S'
    @cp = moeda[:fplural] || @cs + 'S'
  end
end
