# frozen_string_literal: true

require 'extenso_pt/version'
require 'bigdecimal/util'

# @author Hernâni Rodrigues Vaz
module ExtensoPt
  class Error < StandardError; end

  LC = %i[pt br].freeze
  A0020 = { pt: ['', 'UM', 'DOIS', 'TRÊS', 'QUATRO', 'CINCO', 'SEIS', 'SETE', 'OITO', 'NOVE', 'DEZ', 'ONZE', 'DOZE', 'TREZE', 'CATORZE', 'QUINZE', 'DEZASSEIS', 'DEZASSETE', 'DEZOITO', 'DEZANOVE'],
            br: ['', 'UM', 'DOIS', 'TRES', 'QUATRO', 'CINCO', 'SEIS', 'SETE', 'OITO', 'NOVE', 'DEZ', 'ONZE', 'DOZE', 'TREZE', 'QUATORZE', 'QUINZE', 'DEZESSEIS', 'DEZESSETE', 'DEZOITO', 'DEZENOVE'] }.freeze
  A0100 = { pt: ['', '', 'VINTE', 'TRINTA', 'QUARENTA', 'CINQUENTA', 'SESSENTA', 'SETENTA', 'OITENTA', 'NOVENTA'],
            br: ['', '', 'VINTE', 'TRINTA', 'QUARENTA', 'CINQUENTA', 'SESSENTA', 'SETENTA', 'OITENTA', 'NOVENTA'] }.freeze
  A1000 = { pt: ['', 'CEM', 'CENTO', 'DUZENTOS', 'TREZENTOS', 'QUATROCENTOS', 'QUINHENTOS', 'SEISCENTOS', 'SETECENTOS', 'OITOCENTOS', 'NOVECENTOS'],
            br: ['', 'CEM', 'CENTO', 'DUZENTOS', 'TREZENTOS', 'QUATROCENTOS', 'QUINHENTOS', 'SEISCENTOS', 'SETECENTOS', 'OITOCENTOS', 'NOVECENTOS'] }.freeze
  A1e24 = { pt: ['', 'MIL', ' MILHÃO', ' MIL MILHÃO', ' BILIÃO', ' MIL BILIÃO', ' TRILIÃO', ' MIL TRILIÃO', '', ' MIL', ' MILHÕES', ' MIL MILHÕES', ' BILIÕES', ' MIL BILIÕES', ' TRILIÕES', ' MIL TRILIÕES'],
            br: ['', 'MIL', ' MILHÃO', ' BILHÃO', ' TRILHÃO', ' QUADRILHÃO', ' QUINTILHÃO', ' SEXTILHÃO', '', ' MIL', ' MILHÕES', ' BILHÕES', ' TRILHÕES', ' QUADRILHÕES', ' QUINTILHÕES', ' SEXTILHÕES'] }.freeze

  # Produz o extenso das centenas em portugûes de portugal ou brasil.
  #
  # @param [Integer] mil o valor dum grupo 3 digitos a converter
  # @return [String] o extenso das centenas
  def self.e900(mil)
    A1000[@@lc][(mil > 100 ? 1 : 0) + mil / 100] + (mil > 100 && mil % 100 > 0 ? ' E ' : '')
  end

  # Produz o extenso das dezenas em portugûes de portugal ou brasil.
  #
  # @param [Integer] mil o valor dum grupo 3 digitos a converter
  # @return [String] o extenso das dezenas
  def self.e90(mil)
    A0100[@@lc][mil % 100 / 10] + (mil > 20 && mil % 10 > 0 ? ' E ' : '')
  end

  # Produz o extenso das unidades em portugûes de portugal ou brasil.
  #
  # @param [Integer] mil o valor dum grupo 3 digitos a converter
  # @return [String] o extenso das unidades
  def self.e9(cem)
    A0020[@@lc][(cem < 20 ? cem : cem % 10)]
  end

  # Produz o qualificador grupo de 3 digitos em portugûes de portugal ou brasil.
  #
  # @param [Integer] pos posição actual nos grupos 3 digitos do valor monetário
  # @return [String] o qualificador grupo de 3 digitos
  def self.e1e24(pos)
    A1e24[@@lc][@@ai[pos] > 0 ? @@ai[pos] > 1 ? 8 + pos : 0 + pos : 0]
  end

  # Produz o extenso da parte fracionária dum valor monetário em portugûes de portugal ou brasil.
  #
  # @return [String] o extenso da parte fracionária dum valor monetário
  def self.ef99
    e90(@@nf) + e9(@@nf) + (@@nf == 1 ? ' ' + @@cs : @@nf > 1 ? ' ' + @@cp : '')
  end

  # Produz final da moeda em portugûes de portugal ou brasil.
  #
  # @return [String] o final da moeda
  def self.efim
    # soma todos os grupos do valor monetário
    sto = @@s6 + @@m6

    (@@s6 == 0 && @@m6 > 0 ? ' DE' : '') +                  # proposição DE se zero nos primeiros 6 digitos e maiores que 1e6
      (sto == 1 ? ' ' + @@ms : sto > 1 ? ' ' + @@mp : '') + # singular/plural da moeda
      (sto > 0 && @@nf > 0 ? ' E ' : '') +                  # proposição E entre parte inteira e parte fracionária
      ef99                                                  # extenso da parte fracionária dum valor monetário
  end

  # Produz o extenso grupo 3 digitos em portugûes de portugal ou brasil.
  #
  # @param [Integer] pos posição actual nos grupos 3 digitos do valor monetário
  # @return [String] o extenso grupo 3 digitos
  def self.edg3(pos)
    # extenso do grupo actual 3 digitos
    pos == 1 && @@ai[pos] == 1 ? e1e24(pos) : e900(@@ai[pos]) + e90(@@ai[pos]) + e9(@@ai[pos] % 100) + e1e24(pos)
  end

  # Produz separação entre grupos 3 digitos
  #
  # @param [Integer] pos posição actual nos grupos 3 digitos do valor monetário
  # @return [String] separação entre grupos 3 digitos
  def self.esep(pos)
    pos > 0 ? @@ai[pos - 1] > 100 ? ' ' : @@ai[pos - 1] > 0 ? ' E ' : '' : ''
  end

  # Parametrizar grupos 3 digitos para controle de singular/plural
  #
  def self.pdg3
    @@s6 = @@ai[0].to_i + @@ai[1].to_i * 2      # soma grupos 1,2 (primeiros 6 digitos)
    @@m6 = @@ai[2..-1].to_a.inject(:+).to_i * 2 # soma grupos 3.. (digitos acima de 6)
  end

  # Parametrizar parte inteira/fracionária do valor monetário
  #
  # @param [String] dig string de digitos do valor monetário
  def self.pintfra(dig)
    # parte inteira do valor monetário => array grupos 3 digitos ex: 123022.12 => [22, 123]
    @@ai = dig[/^\d+/].to_s.reverse.scan(/\d{1,3}/).map { |i| i.reverse.to_i }

    # parte fracionária do valor monetário                       ex: 123022.12 => 12
    # arredondada a 2 casas decimais (cêntimos/centavos)
    @@nf = (dig[/\.\d*/].to_f * 100).round
  end

  private_class_method :pintfra, :pdg3, :esep, :edg3, :e1e24, :e900, :e90, :e9, :ef99, :efim

  # Parametrizar moeda inferindo singular a partir do plural
  #
  # @param [Hash] moeda as opcoes para parametrizar a moeda/fração
  # @option moeda [Symbol] :lc locale do extenso - portugûes de portugal (:pt) ou brasil (:br)
  # @option moeda [String] :msingular moeda no singular - pode ser inferido do plural menos "S"
  # @option moeda [String] :fsingular fração no singular - pode ser inferido do plural menos "S"
  # @option moeda [String] :mplural moeda no plural
  # @option moeda [String] :fplural fração no plural
  def self.isingular(moeda)
    @@ms = moeda[:msingular] || (moeda[:mplural].to_s[-1] == 'S' ? moeda[:mplural][0..-2] : 'EURO')
    @@cs = moeda[:fsingular] || (moeda[:fplural].to_s[-1] == 'S' ? moeda[:fplural][0..-2] : 'CÊNTIMO')
  end

  # Parametrizar moeda inferindo plural a partir do singular
  #
  # @param [Hash] moeda as opcoes para parametrizar a moeda/fração
  # @option moeda [Symbol] :lc locale do extenso - portugûes de portugal (:pt) ou brasil (:br)
  # @option moeda [String] :msingular moeda no singular
  # @option moeda [String] :fsingular fração no singular
  # @option moeda [String] :mplural moeda no plural - pode ser inferido do singular mais "S"
  # @option moeda [String] :fplural fração no plural - pode ser inferido do singular mais "S"
  def self.iplural(moeda)
    @@mp = moeda[:mplural] || @@ms + 'S'
    @@cp = moeda[:fplural] || @@cs + 'S'
  end

  # Produz o extenso dum valor monetário em portugûes de portugal ou brasil.
  #
  # @param [Integer] pos posição actual nos grupos 3 digitos do valor monetário
  # @param [String] ext extenso actual em construção
  # @return [String] o extenso dum valor monetário
  def self.enumerico(pos = 0, ext = '')
    # testa fim do valor monetário
    if pos >= @@ai.count
      # parametrizar grupos 3 digitos (@@s6, @@m6) para controle de singular/plural
      pdg3

      # caso especial zero
      @@s6 == 0 && @@m6 == 0 && @@nf == 0 ? 'ZERO ' + @@mp : ext + efim
    else
      # tratamento do proximo grupo 3 digitos
      enumerico(pos + 1, edg3(pos) + esep(pos) + ext)
    end
  end

  # Converte um objeto criando extenso(s) em portugûes de portugal ou brasil.
  #
  # @param [Object] objeto o objeto a converter pode ser (String, Float, Integer, Array, Range, Hash) ou uma mistura
  # @return [String, Array<String>, Hash<String>] extenso se o objecto for (String, Float, Integer), Array dos extensos se o objecto for (Array, Range) ou Hash dos extensos se o objecto for (Hash)
  def self.pobjeto(obj)
    if obj.is_a?(Hash)
      # converte os valores do Hash nos seus extensos mantendo as chaves - devolve um Hash
      obj.map { |k, v| [k, pobjeto(v)] }.to_h
    elsif obj.respond_to? :to_a
      # converte o objecto num Array e converte os valores do Array nos seus extensos - devolve um Array
      obj.to_a.map { |v| pobjeto(v) }
    else
      # converte objeto numa string de digitos
      # usa bigdecimal/util para evitar aritmética binária (tem problemas com valores >1e12)
      # qualquer valor não convertivel (ex: texto) resulta em "0.0"
      sdigitos = obj.to_d.to_s('F')

      # parametrizar parte inteira/fracionária (@@ai, @@nf) do valor monetário
      pintfra(sdigitos)

      # processar extenso  - valores superiores a 1e24 não são tratados
      sdigitos[/^\d+/].length <= 24 ? enumerico : ''
    end
  end

  # Produz extenso(s) de objeto(s) em portugûes de portugal ou brasil.
  #
  # @param [Hash] moeda as opcoes para parametrizar a moeda/fração
  # @option moeda [Symbol] :lc locale do extenso - portugûes de portugal (:pt) ou brasil (:br)
  # @option moeda [String] :msingular moeda no singular
  # @option moeda [String] :fsingular fração no singular
  # @option moeda [String] :mplural moeda no plural
  # @option moeda [String] :fplural fração no plural
  # @return [String, Array<String>, Hash<String>] extenso se o objecto for (String, Float, Integer), Array dos extensos se o objecto for (Array, Range) ou Hash dos extensos se o objecto for (Hash)
  def extenso(moeda = { lc: :pt, msingular: 'EURO', fsingular: 'CÊNTIMO' })
    # parametrização por defeito para :br
    moeda = { lc: :br, msingular: 'REAL', mplural: 'REAIS', fsingular: 'CENTAVO' } if moeda[:lc] == :br && !moeda[:msingular] && !moeda[:mplural]

    # somente [:pt, :br]
    @@lc = LC.include?(moeda[:lc]) ? moeda[:lc] : :pt

    # parametrizar moeda
    ExtensoPt.isingular(moeda)
    ExtensoPt.iplural(moeda)

    # processar objeto
    ExtensoPt.pobjeto(self)
  end
end
class Hash;   include ExtensoPt; end
class Array;  include ExtensoPt; end
class Range;  include ExtensoPt; end
class Float;  include ExtensoPt; end
class Integer; include ExtensoPt; end
class String; include ExtensoPt; end
