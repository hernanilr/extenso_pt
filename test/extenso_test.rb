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
    # somente :pt, :br permitidos qualquer outro locale equivale usar :pt
    assert_equal 'MIL DUZENTOS E TRINTA E QUATRO EUROS', 1234.extenso(lc: :es)
  end

  def test_basico2
    assert_equal 'UM MILHÃO DE EUROS', 1_000_000.extenso
    assert_equal 'DEZ MIL TRILIÕES DE EUROS', 1e22.extenso
    assert_equal 'DOIS BILIÕES E UM MILHÃO DE EUROS', 2_000_001_000_000.extenso
    assert_equal 'DOZE MILHÕES DE EUROS E DOZE CÊNTIMOS', 12_000_000.12.extenso
  end

  def test_use1
    assert_equal 'UM DÓLAR E UM CÊNTIMO',        1.010.extenso(moeda_singular: 'DÓLAR')
    assert_equal 'DEZ DÓLARES E DEZ CÊNTIMOS',   10.10.extenso(moeda_plural: 'DÓLARES')
    # por defeito <plural> = <singular> mais 'S'
    assert_equal 'CATORZE REAIS E DEZ CENTAVOS', 14.10.extenso(moeda_plural: 'REAIS', fracao_singular: 'CENTAVO')
    assert_equal 'QUATORZE REAIS E UM CENTAVO',  14.01.extenso(lc: :br)
  end

  def test_use2
    assert_equal 'DEZ MIL MILHÕES DE EUROS',  1e10.extenso(lc: :pt) # por defeiro :pt usa escala longa
    assert_equal 'DEZ BILHÕES DE REAIS',      1e10.extenso(lc: :br) # por defeiro :br usa escala curta
    assert_equal 'DEZ EUROS E UM CENTAVO',   10.01.extenso(fracao_plural: 'CENTAVOS') # <singular>=<plural> menos 'S'
    assert_equal 'DEZ EUROS E UM CÊNTIMO',   10.01.extenso(fracao_plural: 'CENTAVOZ') # sem 'S' nao faz inferencia
    assert_equal 'DEZ EUROS E DEZ CENTAVOS', 10.10.extenso(fracao_singular: 'CENTAVO') # <plural>=<singular> mais 'S'
  end

  def test_use3
    # moeda do brazil configurada se nao for indicado moeda singular/plural
    assert_equal 'QUATORZE DÓLARES E UM CÊNTIMO', 14.01.extenso(lc: :br, moeda_plural: 'DÓLARES')
    assert_equal 'QUATORZE EUROS E UM CÊNTIMO',   14.01.extenso(lc: :br, moeda_singular: 'EURO')
    assert_equal 'QUATORZE REAIS E UM CENTAVO',   14.01.extenso(lc: :br)
    assert_equal 'QUATORZE REAIS E DEZ CENTAVOS', 14.10.extenso(lc: :br, fracao_singular: 'CENT')
    assert_equal 'QUATORZE REAIS E UM CENTAVO',   14.01.extenso(lc: :br, fracao_plural: 'CENTS')
  end

  def test_use4
    # para evitar problemas aritmetica virgula flutuante usar sempre string digitos para valores monetarios >1e12
    assert_equal 'DEZ BILIÕES DE EUROS E DEZ CÊNTIMOS',      10_000_000_000_000.14.extenso
    assert_equal 'DEZ BILIÕES DE EUROS E CATORZE CÊNTIMOS', '10000000000000.14'.extenso
    assert_equal 'CEM MIL TRILIÕES DE REAIS', (10**23).extenso(moeda_plural: 'REAIS') # lc: pt ==> escala longa
    assert_equal 'CEM SEXTILHÕES DE REAIS',   (10**23).extenso(lc: :br)               # lc: br ==> escala curta
    assert_equal '', '1112223334445556667778889'.extenso # limite maximo foi ultrapassado - 24 digitos
  end

  def test_use5
    # Teste de ojectos que renpondem a to_a (Array, Range, Hash)
    assert_equal ({ a: 'UM EURO', b: 'DOIS EUROS' }), { a: 1, b: 2 }.extenso
    assert_equal ['UM EURO', 'DOIS EUROS'], [1, 2].extenso
    assert_equal ['UM CÊNTIMO', 'DEZ CÊNTIMOS'], [0.01, 0.1].extenso
    assert_equal ['UM EURO', 'DOIS EUROS'], (1..2).extenso
    assert_equal ['UM EURO', 'DOIS EUROS'], %w[1 2].extenso
    assert_equal ({ a: ['TRÊS EUROS', 'DEZ EUROS'], b: 'DOIS EUROS' }), { a: [3, 10], b: 2 }.extenso
  end

  def test_unidades
    assert_equal ['TRÊS EUROS', 'QUATRO EUROS', 'CINCO EUROS', 'SEIS EUROS', 'SETE EUROS', 'OITO EUROS',
                  'NOVE EUROS', 'DEZ EUROS', 'ONZE EUROS', 'DOZE EUROS', 'TREZE EUROS', 'CATORZE EUROS',
                  'QUINZE EUROS', 'DEZASSEIS EUROS', 'DEZASSETE EUROS', 'DEZOITO EUROS', 'DEZANOVE EUROS',
                  'VINTE EUROS', 'VINTE E UM EUROS', 'VINTE E DOIS EUROS', 'VINTE E TRÊS EUROS'], (3..23).extenso
  end
end
