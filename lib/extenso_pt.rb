require "extenso_pt/version"
require "bigdecimal/util"

# @author Hernâni Rodrigues Vaz
module ExtensoPt
  class Error < StandardError; end

  LC   =[:pt,:br]
  A0020={pt: ["","UM","DOIS","TRÊS","QUATRO","CINCO","SEIS","SETE","OITO","NOVE","DEZ","ONZE","DOZE","TREZE","CATORZE","QUINZE","DEZASSEIS","DEZASSETE","DEZOITO","DEZANOVE"],
         br: ["","UM","DOIS","TRES","QUATRO","CINCO","SEIS","SETE","OITO","NOVE","DEZ","ONZE","DOZE","TREZE","QUATORZE","QUINZE","DEZESSEIS","DEZESSETE","DEZOITO","DEZENOVE"]}
  A0100={pt: ["","","VINTE","TRINTA","QUARENTA","CINQUENTA","SESSENTA","SETENTA","OITENTA","NOVENTA"],
         br: ["","","VINTE","TRINTA","QUARENTA","CINQUENTA","SESSENTA","SETENTA","OITENTA","NOVENTA"]}
  A1000={pt: ["","CEM","CENTO","DUZENTOS","TREZENTOS","QUATROCENTOS","QUINHENTOS","SEISCENTOS","SETECENTOS","OITOCENTOS","NOVECENTOS"],
         br: ["","CEM","CENTO","DUZENTOS","TREZENTOS","QUATROCENTOS","QUINHENTOS","SEISCENTOS","SETECENTOS","OITOCENTOS","NOVECENTOS"]}
  A1e24={pt: ["","MIL"," MILHÃO"," MIL MILHÃO"," BILIÃO"," MIL BILIÃO"," TRILIÃO"," MIL TRILIÃO",""," MIL"," MILHÕES"," MIL MILHÕES"," BILIÕES"," MIL BILIÕES"," TRILIÕES"," MIL TRILIÕES"],
         br: ["","MIL"," MILHÃO"," BILHÃO"," TRILHÃO"," QUADRILHÃO"," QUINTILHÃO"," SEXTILHÃO",""," MIL"," MILHÕES"," BILHÕES"," TRILHÕES"," QUADRILHÕES"," QUINTILHÕES"," SEXTILHÕES"]}

  # Produz o extenso dum grupo 3 digitos em portugûes de portugal ou brasil.
  #
  # @param [Integer] mil o valor dum grupo 3 digitos a converter
  # @param [Integer] pos posição deste grupo 3 digitos no valor monetário em tratamento
  # @return [String] o extenso dum grupo 3 digitos 
  def self.e999(mil,pos=0)
    cem=mil%100
    A1000[@@lc][(mil>100?1:0)+mil/100]+(mil>100&&cem>0?" E ":"")+ # extenso das centenas
    A0100[@@lc][cem/10]+(mil>20&&mil%10>0?" E ":"")+              # extenso dos dezenas
    A0020[@@lc][pos==1&&mil==1?0:cem<20?cem:cem%10]               # extenso das unidades mais 10-19
  end

  # Produz o extenso dum valor monetário em portugûes de portugal ou brasil.
  #
  # @param [Integer] pos posição actual nos grupos 3 digitos do valor monetário
  # @param [String] ext extenso actual em construção
  # @return [String] o extenso dum valor monetário 
  def self.enumerico(pos=0,ext="")

    # testa fim do valor monetário
    if (pos>=@@ai.count)

      # soma grupos 3 digitos para controle de singular/plural
      s06=@@ai[0].to_i+@@ai[1].to_i*2                       # grupos 1,2 (primeiros 6 digitos)
      sm6=@@ai[2..-1].to_a.inject(:+).to_i*2                # grupos 3.. (digitos acima de 6)

      if (s06+sm6+@@nf==0)
        "ZERO "+@@mp                                        # caso especial de zero
      else
        ext+=" DE"    if (sm6>0&&s06==0)                    # proposição DE para >1e6 e zero nos primeiros 6 digitos
        ext+=" "+@@ms if (s06+sm6==1)                       # singular da moeda
        ext+=" "+@@mp if (s06+sm6>1)                        # plural da moeda
        ext+=" E "    if (s06+sm6>0&&@@nf>0)                # proposição E entre parte inteira e parte fracionária
        ext+=e999(@@nf)                                     # extenso da parte fracionária
        ext+=" "+@@cs if (@@nf==1)                          # singular da parte fracionária
        ext+=" "+@@cp if (@@nf>1)                           # plural da parte fracionária
        ext
      end
    else
      # tratamento do grupo actual 3 digitos
      dg3 =e999(@@ai[pos],pos)                              # extenso
      dg3+=A1e24[@@lc][@@ai[pos]>0?@@ai[pos]>1?8+pos:pos:0] # qualificador

      # convenção de separação com grupo anterior 3 digitos
      if (pos>0)
        dg3+=" E " if (@@ai[pos-1]<101&&@@ai[pos-1]>0)      # grupo < 101 => proposição E
        dg3+=" "   if (@@ai[pos-1]>100)                     # grupo > 100 => espaço
      end

      # tratamento do proximo grupo 3 digitos
      enumerico(pos+1,dg3+ext)
    end
  end

  # Converte um objeto criando extenso(s) em portugûes de portugal ou brasil.
  #
  # @param [Object] objeto o objeto a converter pode ser (String, Float, Integer, Array, Range, Hash) ou uma mistura
  # @return [String, Array<String>, Hash<String>] extenso se o objecto for (String, Float, Integer), Array dos extensos se o objecto for (Array, Range) ou Hash dos extensos se o objecto for (Hash)
  def self.eobjeto(obj)

    if (obj.kind_of?Hash)
      # converte os valores do Hash nos seus extensos mantendo as chaves - devolve um Hash
      obj.map{|k,v|[k,eobjeto(v)]}.to_h
    elsif (obj.respond_to?:to_a)
      # converte o objecto num Array e converte os valores do Array nos seus extensos - devolve um Array
      obj.to_a.map{|a|eobjeto(a)}
    else
      # converte objeto numa string de digitos 
      # usa bigdecimal/util para evitar aritmética binária (tem problemas com valores >1e12)
      # qualquer valor não convertivel (ex: texto) resulta em "0.0"
      svalor=obj.to_d.to_s('F')

      # array da parte inteira do valor monetário dividido em grupos 3 digitos ex: 123022.12 => [22, 123]
      # esta variavel é usada no processo de conversão
      @@ai=svalor[/^\d+/].to_s.reverse.scan(/\d{1,3}/).map{|i|i.reverse.to_i}

      # parte fracionária do valor monetário ex: 123022.12 => 12
      # arredondada a 2 casas decimais (cêntimos/centavos)
      # esta variavel é usada no processo de conversão
      @@nf=(svalor[/\.\d*/].to_f*100).round

      # valores >1e24 não são tratados
      if (@@ai.count>8)
        ""
      else
        # extenso dum numerico
        enumerico 
      end
    end
  end

  # Produz extenso(s) de objeto(s) em portugûes de portugal ou brasil.
  #
  # @param [Hash] moeda as opcoes para parametrizar a moeda/fração
  # @option moeda [Symbol] :lc locale do extenso - portugûes de portugal (:pt) ou brasil (:br)
  # @option moeda [String] :msingular moeda no singular - pode ser inferido do plural menos "S"
  # @option moeda [String] :fsingular fração no singular - pode ser inferido do plural menos "S"
  # @option moeda [String] :mplural moeda no plural - pode ser inferido do singular mais "S"
  # @option moeda [String] :fplural fração no plural - pode ser inferido do singular mais "S"
  # @return [String, Array<String>, Hash<String>] extenso se o objecto for (String, Float, Integer), Array dos extensos se o objecto for (Array, Range) ou Hash dos extensos se o objecto for (Hash)
  def extenso(moeda={lc:(:pt),msingular:"EURO",fsingular:"CÊNTIMO"})

    # parametrização por defeito para locale => :br
    moeda={lc:(:br),msingular:"REAL",mplural:"REAIS",fsingular:"CENTAVO"} if (moeda[:lc]==:br&&!moeda[:mplural]&&!moeda[:fplural])

    # se locale nao for [:pt,:br] entao :pt
    # esta variavel é usada no processo de conversão
    if (LC.include?moeda[:lc])
      @@lc=moeda[:lc]
    else
      @@lc=:pt
    end

    # inferir singular da moeda a partir do plural
    # estas variaveis são usadas no processo de conversão
    if (moeda[:msingular])
      @@ms=moeda[:msingular]
    elsif (moeda[:mplural].to_s[-1]=="S")
      @@ms=moeda[:mplural][0..-2]
    else 
      @@ms="EURO"
    end
    # inferir singular da fração a partir do plural
    if (moeda[:fsingular])
      @@cs=moeda[:fsingular]
    elsif (moeda[:fplural].to_s[-1]=="S")
      @@cs=moeda[:fplural][0..-2]
    else
      @@cs="CÊNTIMO"
    end

    # inferir plural da moeda a partir do singular
    # estas variaveis são usadas no processo de conversão
    if (moeda[:mplural])
      @@mp=moeda[:mplural]
    else
      @@mp=@@ms+"S"
    end 
    # inferir plural da fração a partir do singular
    if (moeda[:fplural])
      @@cp=moeda[:fplural]
    else
      @@cp=@@cs+"S"
    end

    # extenso do objeto
    ExtensoPt.eobjeto(self)
  end
end
class Hash;   include ExtensoPt;end
class Array;  include ExtensoPt;end
class Range;  include ExtensoPt;end
class Float;  include ExtensoPt;end
class Integer;include ExtensoPt;end
class String; include ExtensoPt;end
