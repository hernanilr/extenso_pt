# frozen_string_literal: true

require 'test_helper'

class ExtensoPtTest < Minitest::Test
  def test_version_number
    refute_nil ::ExtensoPt::VERSION
  end

  def test_basico
    assert_equal 'ZERO EUROS', '0'.extenso
    assert_equal 'ZERO REAIS', 0.extenso(lc: :br)
    assert_equal 'DOZE CÊNTIMOS', 0.12.extenso
    assert_equal 'MIL EUROS', 1000.extenso
    assert_equal 'MIL DUZENTOS E TRINTA E QUATRO EUROS', 1234.extenso
    assert_equal 'MIL DUZENTOS E TRINTA E QUATRO EUROS E DEZ CÊNTIMOS',
                 '1234.10'.extenso
  end

  def test_basico2
    assert_equal 'UM MILHÃO DE EUROS', 1_000_000.extenso
    assert_equal 'DEZ MIL TRILIÕES DE EUROS', 1e22.extenso
    assert_equal 'DOIS BILIÕES E UM MILHÃO DE EUROS',
                 2_000_001_000_000.extenso
    assert_equal 'DOZE MILHÕES DE EUROS E DOZE CÊNTIMOS',
                 12_000_000.12.extenso
  end

  def test_use1
    # por defeito o singular da fracao e CENTIMO e plural <singular>+"S"
    assert_equal 'UM DÓLAR E UM CÊNTIMO', 1.010.extenso(msingular: 'DÓLAR')
    assert_equal 'DEZ DÓLARES E DEZ CÊNTIMOS',
                 10.10.extenso(mplural: 'DÓLARES')
    assert_equal 'CATORZE REAIS E DEZ CENTAVOS',
                 14.10.extenso(mplural: 'REAIS', fsingular: 'CENTAVO')
    assert_equal 'QUATORZE REAIS E DEZ CENTAVOS', 14.10.extenso(lc: :br)
    assert_equal 'DEZ MIL MILHÕES DE REAIS', 1e10.extenso(mplural: 'REAIS')
    assert_equal 'DEZ BILHÕES DE REAIS', 1e10.extenso(lc: :br)
    # por defeito o singular e <plural> menos o "S"
    assert_equal 'CATORZE REAIS E UM CENTAVO',
                 14.01.extenso(fplural: 'CENTAVOS', mplural: 'REAIS')
  end

  def test_use2
    # moeda do brazil configurada se nao for indicado moeda singular/plural
    assert_equal 'QUATORZE DÓLARES E UM CÊNTIMO',
                 14.01.extenso(lc: :br, mplural: 'DÓLARES')
    assert_equal 'QUATORZE EUROS E UM CÊNTIMO',
                 14.01.extenso(lc: :br, msingular: 'EURO')
    assert_equal 'QUATORZE REAIS E UM CENTAVO', 14.01.extenso(lc: :br)
    assert_equal 'QUATORZE REAIS E DEZ CENTAVOS',
                 14.10.extenso(lc: :br, fsingular: 'CENT')
    assert_equal 'QUATORZE REAIS E UM CENTAVO',
                 14.01.extenso(lc: :br, fplural: 'CENTS')
  end

  def test_use3
    # bigdecimal para valores maiores 1e12 devido a aritmetica binaria interna
    assert_equal 'CEM MIL TRILIÕES DE EUROS', (10**23).extenso # escala longa
    assert_equal 'CEM MIL TRILIÕES DE REAIS',
                 (10**23).extenso(mplural: 'REAIS') # escala longa
    assert_equal 'CEM SEXTILHÕES DE REAIS',
                 (10**23).extenso(lc: :br) # escala curta

    # limite maximo foi ultrapassado - 24 digitos
    assert_equal '', '111222333444555666777888999'.extenso
  end

  def test_use4
    # Teste de ojectos que renpondem a to_a (Array, Range, Hash)
    assert_equal ['UM EURO', 'DOIS EUROS'], [1, 2].extenso
    assert_equal ['UM EURO E DEZ CÊNTIMOS', 'DOIS EUROS E VINTE CÊNTIMOS'],
                 [1.1, 2.2].extenso
    assert_equal ['UM EURO', 'DOIS EUROS'], (1..2).extenso
    assert_equal ['UM EURO', 'DOIS EUROS'], %w[1 2].extenso
    assert_equal ['DEZ CÊNTIMOS', 'VINTE CÊNTIMOS'], [0.1, 0.2].extenso
    assert_equal ({ a: 'UM EURO', b: 'DOIS EUROS' }), { a: 1, b: 2 }.extenso
    assert_equal ({ a: ['TRÊS EUROS', 'CATORZE EUROS'], b: 'DOIS EUROS' }),
                 { a: [3, 14], b: 2 }.extenso
  end
end
