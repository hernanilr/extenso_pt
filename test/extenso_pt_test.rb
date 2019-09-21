require "test_helper"

class ExtensoPtTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ExtensoPt::VERSION
  end

  def test_it_does_something_useful
    assert_equal "ZERO EUROS", "texto".extenso
    assert_equal "ZERO EUROS", 0.extenso
    assert_equal "ZERO REAIS", 0.extenso(lc: :br)
    assert_equal "MIL EUROS", 1000.extenso
    assert_equal "MIL DUZENTOS E TRINTA E QUATRO EUROS", 1234.extenso
    assert_equal "UM MILHÃO DE EUROS", 1000000.extenso
    assert_equal "DOIS BILIÕES E UM MILHÃO DE EUROS", 2000001000000.extenso
    assert_equal "DEZ MIL TRILIÕES DE EUROS", 1e22.extenso
    assert_equal "DOZE CÊNTIMOS", 0.12.extenso
    assert_equal "MIL DUZENTOS E TRINTA E QUATRO EUROS E DEZ CÊNTIMOS", "1234.10".extenso
    assert_equal "DOZE MILHÕES DE EUROS E DOZE CÊNTIMOS", 12000000.12.extenso
    assert_equal "UM DÓLAR", 1.extenso(msingular:"DÓLAR")
    assert_equal "UM DÓLAR E UM CÊNTIMO", 1.01.extenso(msingular:"DÓLAR")

    # por defeito o singular da fracao é CÊNTIMO e plural <singular>+"S"
    assert_equal "DEZ DÓLARES E DEZ CÊNTIMOS",    10.10.extenso(mplural:"DÓLARES")
    assert_equal "CATORZE REAIS E UM CENTAVO",    14.01.extenso(mplural:"REAIS",fsingular:"CENTAVO")
    assert_equal "CATORZE REAIS E DEZ CENTAVOS",  14.10.extenso(mplural:"REAIS",fsingular:"CENTAVO")
    assert_equal "QUATORZE REAIS E DEZ CENTAVOS", 14.10.extenso(lc: :br)
    assert_equal "DEZ MIL MILHÕES DE REAIS",       1e10.extenso(mplural:"REAIS")
    assert_equal "DEZ BILHÕES DE REAIS",           1e10.extenso(lc: :br)

    # por defeito moeda do brazil é configurada somente se nao for indicado nenhum plural
    assert_equal "QUATORZE DÓLARES E UM CÊNTIMO", 14.01.extenso(lc: :br,mplural:"DÓLARES")
    assert_equal "QUATORZE EUROS E UM CENTAVO",   14.01.extenso(lc: :br,fplural:"CENTAVOS")
    assert_equal "QUATORZE REAIS E UM CENTAVO",   14.01.extenso(lc: :br,msingular:"DOLAR")
    assert_equal "QUATORZE REAIS E UM CENTAVO",   14.01.extenso(lc: :br,fsingular:"CÊNTIMO")
    assert_equal "QUATORZE REAIS E UM CENTAVO",   14.01.extenso(lc: :br)

    # por defeito o singular é <plural> menos o "S"
    assert_equal "CATORZE REAIS E UM CENTAVO", 14.01.extenso(fplural:"CENTAVOS",mplural:"REAIS")

    # bigdecimal necessario para valores maiores 1e12 devido a aritmetica binaria interna
    assert_equal "CEM MIL TRILIÕES DE EUROS", (10**23).extenso                  # escala longa
    assert_equal "CEM MIL TRILIÕES DE REAIS", (10**23).extenso(mplural:"REAIS") # escala longa
    assert_equal "CEM SEXTILHÕES DE REAIS",   (10**23).extenso(lc: :br)         # escala curta

    # limite maximo foi ultrapassado - 24 digitos
    assert_equal "", "111222333444555666777888999".extenso

    # Teste de ojectos que renpondem a to_a (Array, Range, Hash)
    assert_equal ["UM EURO","DOIS EUROS"], [1,2].extenso
    assert_equal ["UM EURO E DEZ CÊNTIMOS","DOIS EUROS E VINTE CÊNTIMOS"], [1.1,2.2].extenso
    assert_equal ["UM EURO","DOIS EUROS"], (1..2).extenso
    assert_equal ["UM EURO","DOIS EUROS"], ["1","2"].extenso
    assert_equal ["DEZ CÊNTIMOS","VINTE CÊNTIMOS"], [0.1,0.2].extenso
    assert_equal ({a:"UM EURO",b:"DOIS EUROS"}), {a:1,b:2}.extenso
    assert_equal ({a:["TRÊS EUROS", "CATORZE EUROS"],b:"DOIS EUROS"}), {a:[3,14],b:2}.extenso
  end
end
