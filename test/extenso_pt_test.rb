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
    # limite maximo foi ultrapassado - 24 digitos
    assert_equal "", "111222333444555666777888999".extenso
    assert_equal "", (10**24).extenso
  end
end
