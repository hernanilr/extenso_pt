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
    assert_equal "UM DÓLAR", 1.extenso(msingular:"DÓLAR")
    # por defeito o singular da fracao é CÊNTIMO e plural <singular>+"S"
    assert_equal "UM DÓLAR E UM CÊNTIMO", 1.01.extenso(msingular:"DÓLAR")
    assert_equal "DEZ DÓLARES E DEZ CÊNTIMOS", 10.1.extenso(mplural:"DÓLARES")
    assert_equal "UM REAL", 1.0.extenso(msingular:"REAL")
    assert_equal "UM REAL E UM CENTAVO", 1.01.extenso(msingular:"REAL",fsingular:"CENTAVO")
    assert_equal "DOIS REAIS E DEZ CENTAVOS", 2.1.extenso(fsingular:"CENTAVO",mplural:"REAIS")
    # por defeito o singular é <plural> menos o "S"
    assert_equal "DOIS REAIS E UM CENTAVO", 2.01.extenso(fplural:"CENTAVOS",mplural:"REAIS")

    # bigdecimal necessario para valores maiores 1e12 devido a aritmetica binaria interna
    assert_equal "CEM MIL TRILIÕES DE EUROS", (10**23).extenso
    assert_equal "CEM MIL TRILIÕES DE EUROS", 1e23.extenso

    # limite maximo foi ultrapassado - 24 digitos
    assert_equal "", "111222333444555666777888999".extenso

  end
end
