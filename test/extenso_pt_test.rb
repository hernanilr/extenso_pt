# frozen_string_literal: true

require 'test_helper'

class ExtensoPtTest < Minitest::Test
  def test_contantes
    refute_nil ::ExtensoPt::VERSION
    refute_nil ::ExtensoPt::EXTLC
    refute_nil ::ExtensoPt::A0020
    refute_nil ::ExtensoPt::A0100
    refute_nil ::ExtensoPt::A1000
    refute_nil ::ExtensoPt::S1E24
    refute_nil ::ExtensoPt::P1E24
    refute_nil ::ExtensoPt::ROMAN
    refute_nil ::ExtensoPt::RO_RE
  end

  def test_basico
    assert_equal 'ZERO EUROS', 0.extenso
    assert_equal 'VINTE REAIS', 20.extenso(lc: :br)
    assert_equal 'CENTO E ONZE EUROS', 111.extenso
    assert_equal 'CENTO E VINTE E UM EUROS', 121.extenso
    assert_equal 'MIL E CEM EUROS', 1100.extenso
    assert_equal 'MIL CENTO E ONZE EUROS', 1111.extenso
    assert_equal 'MIL DUZENTOS E TRINTA E QUATRO EUROS', 1234.extenso
  end

  def test_romana
    assert_equal 'MCCXXXIV', 1234.romana
    assert_equal 'MCMLXVII', 1967.romana
    assert_equal 'MCMXXVII', '1927'.romana
    assert_equal 1234, 'MCCXXXIV'.romana
    assert_equal 1967, 'MCMLXVII'.romana
    assert_equal 1967, 1967.romana.romana
  end

  def test_romana?
    assert_equal true, 'MCCXXXIV'.romana?
    assert_equal false, 'lixo'.romana?
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
    assert_equal 'UM DÓLAR E UM CÊNTIMO', 1.010.extenso(msingular: 'DÓLAR')
    assert_equal 'DEZ DÓLARES E DEZ CÊNTIMOS',
                 10.10.extenso(mplural: 'DÓLARES')
    # por defeito <plural> = <singular> mais 'S'
    assert_equal 'CATORZE REAIS E DEZ CENTAVOS',
                 14.10.extenso(mplural: 'REAIS', fsingular: 'CENTAVO')
    assert_equal 'QUATORZE REAIS E UM CENTAVO', 14.01.extenso(lc: :br)
    # por defeiro :pt usa escala longa
    assert_equal 'DEZ MIL MILHÕES DE REAIS', 1e10.extenso(mplural: 'REAIS')
    # por defeiro :br usa escala curta
    assert_equal 'DEZ BILHÕES DE REAIS', 1e10.extenso(lc: :br)
    # por defeito <singular> = <plural> menos 'S'
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
    # para evitar problemas aritmetica virgula flutuante usar sempre
    #  string digitos para valores monetarios >1e12
    assert_equal 'DEZ BILIÕES DE EUROS E DEZ CÊNTIMOS',
                 10_000_000_000_000.14.extenso
    assert_equal 'DEZ BILIÕES DE EUROS E CATORZE CÊNTIMOS',
                 '10000000000000.14'.extenso
    assert_equal 'CEM MIL TRILIÕES DE REAIS',
                 (10**23).extenso(mplural: 'REAIS') # escala longa
    assert_equal 'CEM SEXTILHÕES DE REAIS',
                 (10**23).extenso(lc: :br) # escala curta

    # limite maximo foi ultrapassado - 24 digitos
    assert_equal '', '1112223334445556667778889'.extenso
  end

  def test_use4
    # Teste de ojectos que renpondem a to_a (Array, Range, Hash)
    assert_equal ({ a: 'UM EURO', b: 'DOIS EUROS' }), { a: 1, b: 2 }.extenso
    assert_equal ['UM EURO', 'DOIS EUROS'], [1, 2].extenso
    assert_equal ['UM EURO E DEZ CÊNTIMOS', 'DOIS EUROS E VINTE CÊNTIMOS'],
                 [1.1, 2.2].extenso
    assert_equal ['UM EURO', 'DOIS EUROS'], (1..2).extenso
    assert_equal ['UM EURO', 'DOIS EUROS'], %w[1 2].extenso
    assert_equal ['DEZ CÊNTIMOS', 'VINTE CÊNTIMOS'], [0.1, 0.2].extenso
    assert_equal ({ a: ['TRÊS EUROS', 'CATORZE EUROS'], b: 'DOIS EUROS' }),
                 { a: [3, 14], b: 2 }.extenso
  end

  def test_unidades
    assert_equal ['TRÊS EUROS', 'QUATRO EUROS', 'CINCO EUROS', 'SEIS EUROS',
                  'SETE EUROS', 'OITO EUROS', 'NOVE EUROS', 'DEZ EUROS',
                  'ONZE EUROS', 'DOZE EUROS', 'TREZE EUROS', 'CATORZE EUROS',
                  'QUINZE EUROS', 'DEZASSEIS EUROS', 'DEZASSETE EUROS',
                  'DEZOITO EUROS', 'DEZANOVE EUROS',
                  'VINTE EUROS', 'VINTE E UM EUROS', 'VINTE E DOIS EUROS',
                  'VINTE E TRÊS EUROS', 'VINTE E QUATRO EUROS',
                  'VINTE E CINCO EUROS', 'VINTE E SEIS EUROS'],
                 (3..26).extenso
  end
end
