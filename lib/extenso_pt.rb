require "extenso_pt/version"
require "bigdecimal/util"

# @author Hernâni Rodrigues Vaz
module ExtensoPt
  class Error < StandardError; end

  A0020=["","UM","DOIS","TRÊS","QUATRO","CINCO","SEIS","SETE","OITO","NOVE","DEZ","ONZE",
         "DOZE","TREZE","CATORZE","QUINZE","DEZASSEIS","DEZASSETE","DEZOITO","DEZANOVE"]
  A0100=["","","VINTE","TRINTA","QUARENTA","CINQUENTA","SESSENTA","SETENTA","OITENTA","NOVENTA"]
  A1000=["","CEM","CENTO","DUZENTOS","TREZENTOS","QUATROCENTOS","QUINHENTOS",
         "SEISCENTOS","SETECENTOS","OITOCENTOS","NOVECENTOS"]
  A1e24=["","MIL"," MILHÃO"," MIL MILHÃO"," BILIÃO"," MIL BILIÃO"," TRILIÃO"," MIL TRILIÃO","",
         " MIL"," MILHÕES"," MIL MILHÕES"," BILIÕES"," MIL BILIÕES"," TRILIÕES"," MIL TRILIÕES"]

  # Controle proposicao E
  #
  # @param [Integer] valor parcela do valor monetario
  # @return [String] produz E entre centenas e dezenas
  def self.f1(valor)valor>100&&valor%100>0?" E ":""end

  # Controle proposicao E
  #
  # @param [Integer] valor parcela do valor monetario
  # @return [String] produz E entre dezenas e unidades
  def self.f2(valor)valor>20&&valor%10>0?" E ":""end

  # Controle proposicao E
  #
  # @param [Integer] valor parcela do valor monetario
  # @return [String] produz E entre pacelas
  def self.f3(valor)valor>100?" ":valor>0?" E ":""end

  # Controle singular/plural da parte inteira
  #
  # @param [Integer] inteira soma da parte inteira
  # @return [String] produz terminacao da parte inteira
  def self.f4(inteira)inteira>0?inteira>1?" "+@@mp:" "+@@ms:""end

  # Controle singular/plural da parte fracionaria
  #
  # @param [Integer] fracao parte fracionaria do valor monetário ex: 100022.12 = 12
  # @return [String] produz terminacao da parte fracionaria
  def self.f5(fracao)fracao>0?fracao>1?" "+@@cp:" "+@@cs:""end

  # Controle separador entre parte inteira e fracionaria
  #
  # @param [Integer] inteira soma da parte inteira
  # @param [Integer] fracao parte fracionaria do valor monetário ex: 100022.12 = 12
  # @return [String] produz E entre parte inteira e fracionaria
  def self.f6(inteira,fracao)inteira>0&&fracao>0?" E ":""end

  # Controle de palavras no final do extenso
  #
  # @param [Integer] total soma da parte inteira e fracionaria para controle de ZERO
  # @return [String] produz DE/ZERO <plural moeda>
  def self.f7(total)
    if (@@ai[2..-1].to_a.find{|v|v>0}.to_i>0&&@@ai[0..1].inject(:+).to_i==0)
      " DE"
    elsif (@@ai.count>0&&total==0)
      "ZERO "+@@mp
    else
      ""
    end
  end

  # Produz o extenso da parte fracionaria do valor monetário em protugûes de portugal.
  #
  # @param [Integer] fracao parte fracionaria do valor monetário ex: 100022.12 = 12
  # @return [String] o extenso da parte fracionaria do valor monetário
  def self.fracao(fracao)
    t=@@ai.find{|v|v>0}.to_i+@@ai[1..-1].to_a.find{|v|v>0}.to_i
    f7(t+fracao)+f4(t)+f6(t,fracao)+e999(fracao)+f5(fracao)
  end

  # Produz o extenso dum valor (entre 0-999) em protugûes de portugal.
  #
  # @param [Integer] mil a converter
  # @param [Integer] pos posição actual em tratamento
  # @return [String] o extenso do [Integer] mil
  def self.e999(mil,pos=0)
    s=mil%100
    A1000[(mil>100?1:0)+mil/100]+f1(mil)+A0100[s/10]+f2(s)+A0020[pos==1&&mil==1?0:s<20?s:s%10]
  end

  # Produz recursivamente o extenso da parte inteira do valor monetário em protugûes de portugal.
  #
  # @param [Integer] pos posição actual em tratamento
  # @param [String] ext extenso actual em tratamento
  # @return [String] o extenso da parte inteira
  def self.erecursivo(pos=0,ext="")
    if (pos>=@@ai.count)
      ext
    else
      erecursivo(pos+1,e999(@@ai[pos],pos)+A1e24[@@ai[pos]>0?@@ai[pos]>1?8+pos:pos:0]+f3(pos>0?@@ai[pos-1]:0)+ext)
    end
  end

  # Converte um objeto [String, Float, Integer] no seu extenso em protugûes de portugal.
  #
  # @param [Hash] moeda as opcoes para parametrizar a moeda/fração
  # @option moeda [String] :msingular Moeda no singular - por defeito pode ser obtida do <b>:mplural menos "S"</b> (se terminar em "S")
  # @option moeda [String] :fsingular Fração no singular - por defeito pode ser obtida do <b>:fplural menos "S"</b> (se terminar em "S")
  # @option moeda [String] :mplural Moeda no plural - por defeito pode ser obtida do <b>:msingular+"S"</b>
  # @option moeda [String] :fplural Fração no plural - por defeito pode ser obtida do <b>:fsingular+"S"</b>
  # @return [String] o extenso do objeto
  def extenso(moeda={msingular:"EURO",fsingular:"CÊNTIMO"})
    @@ms=moeda[:msingular]?moeda[:msingular]:moeda[:mplural].to_s[-1]=="S"?moeda[:mplural][0..-2]:"EURO"
    @@cs=moeda[:fsingular]?moeda[:fsingular]:moeda[:fplural].to_s[-1]=="S"?moeda[:fplural][0..-2]:"CÊNTIMO"
    @@mp=moeda[:mplural]?moeda[:mplural]:@@ms+"S"
    @@cp=moeda[:fplural]?moeda[:fplural]:@@cs+"S"
    n=self.to_d.to_s("F")
    @@ai=n[/^\d+/].to_s.reverse.scan(/\d{1,3}/).map{|i|i.reverse.to_i}
    @@ai.count>8?"":ExtensoPt.erecursivo+ExtensoPt.fracao((n[/\.\d*/].to_f*100).round)
  end

end
class String; include ExtensoPt;end
class Float;  include ExtensoPt;end
class Integer;include ExtensoPt;end
