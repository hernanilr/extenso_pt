require "test_helper"

class ExtensoPtTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ExtensoPt::VERSION
  end

  def test_it_does_something_useful
    assert_equal "ZERO EUROS", 0.extenso
    assert_equal "MIL EUROS", 1000.extenso
    assert_equal "MIL DUZENTOS E TRINTA E QUATRO EUROS", 1234.extenso
    assert_equal "UM MILHÃO DE EUROS", 1000000.extenso
    assert_equal "DEZ MIL TRILIÕES DE EUROS", 1e22.extenso
    assert_equal "DOZE CÊNTIMOS", 0.12.extenso
    assert_equal "CEM MIL TRILIÕES DE EUROS", (10**23).extenso
    assert_equal "MIL DUZENTOS E TRINTA E QUATRO EUROS E DEZ CÊNTIMOS", "1234.10".extenso
    assert_equal "DOZE MILHÕES DE EUROS E DOZE CÊNTIMOS", 12000000.12.extenso
    assert_equal "UM DÓLAR", 1.extenso(moeda:"DÓLAR")
    assert_equal "UM DÓLAR E UM CÊNTIMO", 1.01.extenso(moeda:"DÓLAR")
    assert_equal "DEZ DÓLARES E DEZ CÊNTIMOS", 10.1.extenso(moedap:"DÓLARES")
    assert_equal "UM REAL", 1.0.extenso(moeda:"REAL")
    assert_equal "UM REAL E UM CENTAVO", 1.01.extenso(moeda:"REAL",fracao:"CENTAVO")
    assert_equal "UM REAL E DEZ CENTAVOS", 2.1.extenso(moeda:"REAL",fracao:"CENTAVO")
    assert_equal "DOIS REAIS E DEZ CENTAVOS", 2.1.extenso(fracao:"CENTAVO",moedap:"REAIS")

    # limite maximo foi ultrapassado - 24 digitos
    assert_equal "", "111222333444555666777888999".extenso

  end
end
