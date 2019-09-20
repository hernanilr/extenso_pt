require "extenso_pt/version"
require "bigdecimal/util"

# @author Hernâni Rodrigues Vaz
module ExtensoPt
  class Error < StandardError; end

  LC=[:pt,:br]
  A0020={pt: ["","UM","DOIS","TRÊS","QUATRO","CINCO","SEIS","SETE","OITO","NOVE","DEZ","ONZE","DOZE","TREZE","CATORZE","QUINZE","DEZASSEIS","DEZASSETE","DEZOITO","DEZANOVE"],
         br: ["","UM","DOIS","TRES","QUATRO","CINCO","SEIS","SETE","OITO","NOVE","DEZ","ONZE","DOZE","TREZE","QUATORZE","QUINZE","DEZESSEIS","DEZESSETE","DEZOITO","DEZENOVE"]}
  A0100={pt: ["","","VINTE","TRINTA","QUARENTA","CINQUENTA","SESSENTA","SETENTA","OITENTA","NOVENTA"],
         br: ["","","VINTE","TRINTA","QUARENTA","CINQUENTA","SESSENTA","SETENTA","OITENTA","NOVENTA"]}
  A1000={pt: ["","CEM","CENTO","DUZENTOS","TREZENTOS","QUATROCENTOS","QUINHENTOS","SEISCENTOS","SETECENTOS","OITOCENTOS","NOVECENTOS"],
         br: ["","CEM","CENTO","DUZENTOS","TREZENTOS","QUATROCENTOS","QUINHENTOS","SEISCENTOS","SETECENTOS","OITOCENTOS","NOVECENTOS"]}
  A1e24={pt: ["","MIL"," MILHÃO"," MIL MILHÃO"," BILIÃO"," MIL BILIÃO"," TRILIÃO"," MIL TRILIÃO",""," MIL"," MILHÕES"," MIL MILHÕES"," BILIÕES"," MIL BILIÕES"," TRILIÕES"," MIL TRILIÕES"],
         br: ["","MIL"," MILHÃO"," BILHÃO"," TRILHÃO"," QUADRILHÃO"," QUINTILHÃO"," SEXTILHÃO",""," MIL"," MILHÕES"," BILHÕES"," TRILHÕES"," QUADRILHÕES"," QUINTILHÕES"," SEXTILHÕES"]}

  # Produz a moeda e o extenso da parte fracionária do valor monetário em portugûes de portugal ou brasil.
  #
  # @param [Integer] fracao parte fracionária do valor monetário ex: 100022.12 = 12
  # @return [String] a moeda e o extenso da parte fracionária do valor monetário
  def self.efracao(fracao)
    inteira=@@ai.find{|v|v>0}.to_i+@@ai[1..-1].to_a.find{|v|v>0}.to_i
    total=inteira+fracao
    (@@ai[2..-1].to_a.find{|v|v>0}.to_i>0&&@@ai[0..1].inject(:+).to_i==0?" DE":@@ai.count>0&&total==0?"ZERO "+@@mp:"")+
    (inteira>0?inteira>1?" "+@@mp:" "+@@ms:"")+
    (inteira>0&&fracao>0?" E ":"")+e999(fracao)+
    (fracao>0?fracao>1?" "+@@cp:" "+@@cs:"")
  end

  # Produz o extenso dum grupo de 3 digitos em portugûes de portugal ou brasil.
  #
  # @param [Integer] mil o valor dum grupo de 3 digitos a converter
  # @param [Integer] pos posição deste grupo de 3 digitos no valor monetário em tratamento
  # @return [String] o extenso de <mil>
  def self.e999(mil,pos=0)
    cem=mil%100
    A1000[@@lc][(mil>100?1:0)+mil/100]+(mil>100&&mil%100>0?" E ":"")+
    A0100[@@lc][cem/10]+(mil>20&&mil%10>0?" E ":"")+
    A0020[@@lc][pos==1&&mil==1?0:cem<20?cem:cem%10]
  end

  # Produz o extenso da parte inteira do valor monetário em portugûes de portugal ou brasil.
  #
  # @param [Integer] pos posição actual nos grupos de 3 digitos do valor monetário em tratamento
  # @param [String] ext extenso actual em tratamento
  # @return [String] o extenso da parte inteira do valor monetário 
  def self.einteira(pos=0,ext="")
    if (pos>=@@ai.count)
      ext
    else
      ctl=pos>0?@@ai[pos-1]:0
      ext=e999(@@ai[pos],pos)+A1e24[@@lc][@@ai[pos]>0?@@ai[pos]>1?8+pos:pos:0]+(ctl>100?" ":ctl>0?" E ":"")+ext
      einteira(pos+1,ext)
    end
  end

  # Converte um objeto no seu extenso em portugûes de portugal ou brasil.
  #
  # @param [Hash] moeda as opcoes para parametrizar a moeda/fração
  # @option moeda [Symbol] :lc locale do extenso - portugûes de portugal (:pt) ou brasil (:br)
  # @option moeda [String] :msingular Moeda no singular - pode ser inferido do <b>:mplural menos "S"</b>
  # @option moeda [String] :fsingular Fração no singular - pode ser inferido do <b>:fplural menos "S"</b>
  # @option moeda [String] :mplural Moeda no plural - pode ser inferido do <b>:msingular+"S"</b>
  # @option moeda [String] :fplural Fração no plural - pode ser inferido do <b>:fsingular+"S"</b>
  # @return [String, Array<String>, Hash<String>] extenso se o objecto for (String, Float, Integer), Array dos extensos se o objecto for (Array, Range) ou Hash dos extensos se o objecto for (Hash)
  def extenso(moeda={lc:(:pt),msingular:"EURO",fsingular:"CÊNTIMO"})
    # parametrização da moeda
    moeda={lc:(:br),msingular:"REAL",mplural:"REAIS",fsingular:"CENTAVO"} if (moeda[:lc]==:br&&!moeda[:mplural]&&!moeda[:fplural])
    @@lc=LC.include?(moeda[:lc])?moeda[:lc]:(:pt)
    @@ms=moeda[:msingular]?moeda[:msingular]:moeda[:mplural].to_s[-1]=="S"?moeda[:mplural][0..-2]:"EURO"
    @@cs=moeda[:fsingular]?moeda[:fsingular]:moeda[:fplural].to_s[-1]=="S"?moeda[:fplural][0..-2]:"CÊNTIMO"
    @@mp=moeda[:mplural]?moeda[:mplural]:@@ms+"S"
    @@cp=moeda[:fplural]?moeda[:fplural]:@@cs+"S"
    if (self.kind_of?Hash)
      # converte os valores do Hash nos seus extensos mantendo as chaves - devolve um Hash
      self.map{|k,v|[k,v.extenso(lc:(@@lc),msingular:@@ms,fsingular:@@cs,mplural:@@mp,fplural:@@cp)]}.to_h
    elsif (self.respond_to?:to_a)
      # converte o objecto num Array e converte os valores nos seus extensos - devolve um Array
      self.to_a.map{|a|a.extenso(lc:(@@lc),msingular:@@ms,fsingular:@@cs,mplural:@@mp,fplural:@@cp)}
    else
      # converter com bigdecimal/util para evitar bugs com valores superiores a 1e12
      n=self.to_d.to_s('F')
      # dividir parte inteira em grupos de 3 digitos ex: 123022.12 => [22, 123]
      @@ai=n[/^\d+/].to_s.reverse.scan(/\d{1,3}/).map{|i|i.reverse.to_i}
      if (@@ai.count>8)
        "" # MAX 1e24
      else
        ExtensoPt.einteira+
        # parte fracionária é arredondada a 2 casas decimais (cêntimos)
        ExtensoPt.efracao((n[/\.\d*/].to_f*100).round)
      end
    end
  end

end
class Hash;   include ExtensoPt;end
class Array;  include ExtensoPt;end
class Range;  include ExtensoPt;end
class Float;  include ExtensoPt;end
class Integer;include ExtensoPt;end
class String; include ExtensoPt;end
