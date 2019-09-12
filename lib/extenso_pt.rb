require "extenso_pt/version"
require "bigdecimal/util"

module ExtensoPt
  class Error < StandardError; end

  def self.o(a)[""," "," E "," DE","ZERO "+@@mp," "+@@ms," "+@@mp," "+@@cs," "+@@cp][a]end
  def self.z(a)["","UM","DOIS","TRÊS","QUATRO","CINCO","SEIS","SETE","OITO","NOVE","DEZ","ONZE",
         "DOZE","TREZE","CATORZE","QUINZE","DEZASSEIS","DEZASSETE","DEZOITO","DEZANOVE"][a]end
  def self.c(a)["","","VINTE","TRINTA","QUARENTA","CINQUENTA","SESSENTA","SETENTA","OITENTA","NOVENTA"][a]end
  def self.l(a)["","CEM","CENTO","DUZENTOS","TREZENTOS","QUATROCENTOS","QUINHENTOS",
         "SEISCENTOS","SETECENTOS","OITOCENTOS","NOVECENTOS"][a]end
  def self.h(a)["","MIL"," MILHÃO"," MIL MILHÃO"," BILIÃO"," MIL BILIÃO"," TRILIÃO"," MIL TRILIÃO","",
         " MIL"," MILHÕES"," MIL MILHÕES"," BILIÕES"," MIL BILIÕES"," TRILIÕES"," MIL TRILIÕES"][a]end
  def self.f1(k)o(k>100&&k%100>0?2:0)end
  def self.f2(k)o(k>20&&k%10>0?2:0)end
  def self.f3(k)o(k>100?1:k>0?2:0)end
  def self.f4(k)o(k>0?k>1?6:5:0)end
  def self.f5(k)o(k>0?k>1?8:7:0)end
  def self.f6(k,b)o(k>0&&b>0?2:0)end
  def self.f7(u,b)o(u[2..-1].to_a.find{|v|v>0}.to_i>0&&u[0..1].inject(:+).to_i==0?3:u.count>0&&b==0?4:0)end
  def self.i(n,p)s=n%100;l((n>100?1:0)+n/100)+f1(n)+c(s/10)+f2(s)+z(p==1&&n==1?0:s<20?s:s%10)end
  def self.w(u,d)t=u.find{|v|v>0}.to_i+u[1..-1].to_a.find{|v|v>0}.to_i;f7(u,t+d)+f4(t)+f6(t,d)+i(d,0)+f5(d)end
  def self.r(g,j,p)t=j[p];p>=j.count*1?g:r(i(t,p)+h(t>0?t>1?8+p:p:0)+f3(p>0?j[p-1]:0)+g,j,p+1)end
  def extenso(f={moeda:"EURO",fracao:"CÊNTIMO",moedap:"EUROS",fracaop:"CÊNTIMOS"})
    @@ms=f[:moeda]?f[:moeda]:"EURO";@@cs=f[:fracao]?f[:fracao]:"CÊNTIMO"
    @@mp=f[:moedap]?f[:moedap]:@@ms+"S";@@cp=f[:fracaop]?f[:fracaop]:@@cs+"S"
    n=self.to_d.to_s("F")
    q=n[/^\d+/].to_s.reverse.scan(/\d{1,3}/).map{|i|i.reverse.to_i}
    q.count>8?"":ExtensoPt.r("",q,0)+ExtensoPt.w(q,(n[/\.\d*/].to_f*100).round)
  end
end
class String; include ExtensoPt;end
class Float;  include ExtensoPt;end
class Integer;include ExtensoPt;end
