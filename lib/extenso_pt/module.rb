# frozen_string_literal: true

# @author Hernani Rodrigues Vaz
module ExtensoPt
  # Produz o extenso das centenas em portugues de portugal ou brasil
  #
  # @param [Integer] mil o valor dum grupo 3 digitos a converter
  # @return [String] o extenso das centenas
  def self.e900(mil)
    A1000[@lc][(mil > 100 ? 1 : 0) + mil / 100] +
      (mil > 100 && (mil % 100).positive? ? ' E ' : '') # proposicao
  end

  # Produz o extenso das dezenas em portugues de portugal ou brasil
  #
  # @param [Integer] cem o valor dum grupo 3 digitos a converter
  # @return [String] o extenso das dezenas
  def self.e90(cem)
    A0100[@lc][cem / 10] +
      (cem > 20 && (cem % 10).positive? ? ' E ' : '') # proposicao
  end

  # Produz o extenso das unidades em portugues de portugal ou brasil
  #
  # @param [Integer] cem o valor dum grupo 3 digitos a converter
  # @return [String] o extenso das unidades
  def self.e9(cem)
    A0020[@lc][cem < 20 ? cem : cem % 10]
  end

  # Produz extenso parte fracionaria em portugues de portugal ou brasil
  #
  # @return [String] o extenso da parte fracionaria dum valor monetario
  def self.ef99
    # parametrizacao por defeito
    @cs ||= 'CÊNTIMO'
    @cp ||= @ms + 'S'

    if @nf.positive?
      e90(@nf) + e9(@nf) + (@nf > 1 ? ' ' + @cp : ' ' + @cs)
    else
      ''
    end
  end

  # Produz final da moeda em portugues de portugal ou brasil
  #
  # @return [String] o final da moeda
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
  # @param [Integer] pos posicao actual nos grupos 3 digitos do valor monetario
  # @return [String] separador entre grupos 3 digitos
  def self.esep(pos)
    if pos.positive? && @ai[pos - 1].positive?
      @ai[pos - 1] > 100 ? ' ' : ' E '
    else
      ''
    end
  end

  # Produz qualificador grupo de 3 digitos em portugues de portugal ou brasil
  #
  # @param [Integer] pos posicao actual nos grupos 3 digitos do valor monetario
  # @return [String] qualificador grupo de 3 digitos
  def self.e1e24(pos)
    if @ai[pos].positive?
      @ai[pos] > 1 ? P1E24[@lc][pos] : S1E24[@lc][pos]
    else
      ''
    end
  end

  # Produz extenso grupo 3 digitos em portugues de portugal ou brasil
  #
  # @param [Integer] pos posicao actual nos grupos 3 digitos do valor monetario
  # @return [String] extenso grupo 3 digitos
  def self.edg3(pos)
    # parametrizacao por defeito
    # the first mention of an @<variable> creates the
    # instance variable in the current object ie: self = ExtensoPt
    @lc ||= :pt

    dg3 = if pos == 1 && @ai[pos] == 1
            # caso especial MIL EUROS
            ''
          else
            e900(@ai[pos]) + e90(@ai[pos] % 100) + e9(@ai[pos] % 100)
          end
    # qualificador grupo de 3 digitos
    dg3 + e1e24(pos)
  end

  # Parametrizar controle singular/plural & proposicoes
  #
  # @return [void]
  def self.pcontrolo
    # soma grupos 1,2 (primeiros 6 digitos)
    @s6 = @ai[0].to_i + @ai[1].to_i * 2
    # soma grupos 3.. (digitos acima de 6)
    @m6 = @ai[2..-1].to_a.inject(:+).to_i * 2
    @tt = @s6 + @m6                  # proposicao E & singular/plural
    @de = @s6.zero? && @m6.positive? # proposicao DE
  end

  # Produz o extenso dum valor monetario em portugues de portugal ou brasil
  #
  # @param [Integer] pos posicao actual nos grupos 3 digitos do valor monetario
  # @param [String] ext extenso em construcao
  # @return [String] o extenso dum valor monetario
  def self.emonetario(pos, ext)
    # testa fim do valor monetario
    if pos >= @ai.count
      # parametrizar controle singular/plural & proposicoes
      pcontrolo

      # caso especial zero
      (@tt + @nf).zero? ? 'ZERO ' + @mp : ext + efim
    else
      # tratamento do proximo grupo 3 digitos
      emonetario(pos + 1, edg3(pos) + esep(pos) + ext)
    end
  end

  # Parametrizar parte inteira/fracionaria do valor monetario
  #
  # @param [String] digitos do valor monetario
  # @return [void]
  def self.pintfra(dig)
    # parte inteira do valor monetario => array grupos 3 digitos
    #  ex: 123022.12 => [22, 123]
    @ai = dig[/^\d+/].to_s.reverse.scan(/\d{1,3}/).map { |i| i.reverse.to_i }

    # parte fracionaria do valor monetario
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
  def self.o2e(obj)
    if obj.is_a?(Hash)
      # converte os valores do Hash nos seus extensos - devolve um Hash
      obj.map { |k, v| [k, o2e(v)] }.to_h
    elsif obj.respond_to?(:to_a)
      # converte o objecto num Array com os extensos dos valores
      obj.to_a.map { |a| o2e(a) }
    else
      # converte objeto em string digitos utilizando bigdecimal para
      #  evitar problemas com aritmetica virgula flutuante em valores >1e12
      digitos = obj.to_d.to_s('F')

      # parametrizar parte inteira/fracionaria (@ai, @nf) do valor monetario
      pintfra(digitos)

      # processar extenso - valores superiores a 1e24 nao sao tratados
      digitos[/^\d+/].length <= 24 ? emonetario(0, '') : ''
    end
  end

  # Parametrizar moeda inferindo singular a partir do plural
  #
  # @param [Hash] moeda as opcoes para parametrizar a moeda/fracao
  # @option moeda [Symbol] :lc locale do extenso -
  #  portugues de portugal (:pt) ou brasil (:br)
  # @option moeda [String] :msingular moeda no singular -
  #  inferido do plural menos"S"
  # @option moeda [String] :fsingular fracao no singular -
  #  inferido do plural menos "S"
  # @option moeda [String] :mplural moeda no plural
  # @option moeda [String] :fplural fracao no plural
  # @return [void]
  def self.psingular(moeda)
    @ms = moeda[:msingular] ||
          (moeda[:mplural].to_s[-1] == 'S' ? moeda[:mplural][0..-2] : 'EURO')
    @cs = moeda[:fsingular] ||
          (moeda[:fplural].to_s[-1] == 'S' ? moeda[:fplural][0..-2] : 'CÊNTIMO')
  end

  # Parametrizar moeda inferindo plural a partir do singular
  #
  # @param [Hash] moeda as opcoes para parametrizar a moeda/fracao
  # @option moeda [Symbol] :lc locale do extenso -
  #  portugues de portugal (:pt) ou brasil (:br)
  # @option moeda [String] :msingular moeda no singular
  # @option moeda [String] :fsingular fracao no singular
  # @option moeda [String] :mplural moeda no plural -
  #  inferido do singular mais "S"
  # @option moeda [String] :fplural fracao no plural -
  #  inferido do singular mais "S"
  # @return [void]
  def self.pplural(moeda)
    # somente [:pt, :br]
    @lc = LC.include?(moeda[:lc]) ? moeda[:lc] : :pt

    @mp = moeda[:mplural] || @ms + 'S'
    @cp = moeda[:fplural] || @cs + 'S'
  end
end
