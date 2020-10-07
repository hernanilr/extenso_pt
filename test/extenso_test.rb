# frozen_string_literal: true

require('test_helper')

# classe para testes da gem
class ExtensoPtTest < Minitest::Test
  # testa constantes extenso
  def test_contantes_extenso
    refute_nil(::ExtensoPt::A0020)
    refute_nil(::ExtensoPt::A0100)
    refute_nil(::ExtensoPt::A1000)
    refute_nil(::ExtensoPt::S1E24)
    refute_nil(::ExtensoPt::P1E24)
  end

  # testa constantes romana
  def test_contantes_romana
    refute_nil(::ExtensoPt::ROMAN)
    refute_nil(::ExtensoPt::RO_RE)
  end

  # testes extenso basicos
  def test_basico
    assert_equal('ZERO EUROS', 0.extenso)
    assert_equal('VINTE REAIS', 20.extenso(lc: :br))
    assert_equal('CENTO E ONZE EUROS', 111.extenso)
  end

  # testes extenso - somente cria extenso de valores monetarios positivos
  def test_basico_positivo
    assert_equal('CENTO E VINTE E UM EUROS', -121.extenso)
    assert_equal('MIL E CEM EUROS', 1100.extenso)
    assert_equal('MIL CENTO E ONZE EUROS', 1111.extenso)
    # somente :pt, :br permitidos qualquer outro locale equivale usar :pt
    assert_equal('MIL DUZENTOS E TRINTA E QUATRO EUROS', 1234.extenso(lc: :es))
  end

  # testes extenso basicos adicionais
  def test_basico_adicionais
    assert_equal('UM MILHÃO DE EUROS', 1_000_000.extenso)
    assert_equal('DEZ MIL TRILIÕES DE EUROS', 1e22.extenso)
    assert_equal('DOIS BILIÕES E UM MILHÃO DE EUROS', 2_000_001_000_000.extenso)
    assert_equal('DOZE MILHÕES DE EUROS E DOZE CÊNTIMOS', 12_000_000.12.extenso)
  end

  # testes extenso moedas
  def test_moedas
    assert_equal('UM DÓLAR E UM CÊNTIMO',        1.010.extenso(moeda_singular: 'DÓLAR'))
    assert_equal('DEZ DÓLARES E DEZ CÊNTIMOS',   10.10.extenso(moeda_plural: 'DÓLARES'))
    # por defeito plural = singular mais S
    assert_equal('CATORZE REAIS E DEZ CENTAVOS', 14.10.extenso(moeda_plural: 'REAIS', fracao_singular: 'CENTAVO'))
    assert_equal('QUATORZE REAIS E UM CENTAVO',  14.01.extenso(lc: :br))
  end

  # testes extenso escala
  def test_escala
    # por defeiro pt usa escala longa
    assert_equal('DEZ MIL MILHÕES DE EUROS',  1e10.extenso(lc: :pt))
    # por defeiro br usa escala curta
    assert_equal('DEZ BILHÕES DE REAIS',      1e10.extenso(lc: :br))
    # singular = plural menos S
    assert_equal('DEZ EUROS E UM CENTAVO',   10.01.extenso(fracao_plural: 'CENTAVOS'))
    # sem S nao faz inferencia
    assert_equal('DEZ EUROS E UM CÊNTIMO',   10.01.extenso(fracao_plural: 'CENTAVOZ'))
    # plural = singular mais S
    assert_equal('DEZ EUROS E DEZ CENTAVOS', 10.10.extenso(fracao_singular: 'CENTAVO'))
  end

  # testes extenso locale
  def test_locale
    # moeda do brazil configurada se nao for indicado moeda singular/plural
    assert_equal('QUATORZE DÓLARES E UM CÊNTIMO', 14.01.extenso(lc: :br, moeda_plural: 'DÓLARES'))
    assert_equal('QUATORZE EUROS E UM CÊNTIMO',   14.01.extenso(lc: :br, moeda_singular: 'EURO'))
    assert_equal('QUATORZE REAIS E UM CENTAVO',   14.01.extenso(lc: :br))
    assert_equal('QUATORZE REAIS E DEZ CENTAVOS', 14.10.extenso(lc: :br, fracao_singular: 'CENT'))
    assert_equal('QUATORZE REAIS E UM CENTAVO',   14.01.extenso(lc: :br, fracao_plural: 'CENTS'))
  end

  # testes extenso aritmetica
  def test_aritmetica
    max = 10**23
    # para evitar problemas aritmetica virgula flutuante usar sempre string digitos para valores monetarios >1e12
    assert_equal('DEZ BILIÕES DE EUROS E DEZ CÊNTIMOS',      10_000_000_000_000.14.extenso)
    assert_equal('DEZ BILIÕES DE EUROS E CATORZE CÊNTIMOS', '10000000000000.14'.extenso)
    # lc: pt ==> escala longa
    assert_equal('CEM MIL TRILIÕES DE REAIS', max.extenso(moeda_plural: 'REAIS'))
    # lc: br ==> escala curta
    assert_equal('CEM SEXTILHÕES DE REAIS',   max.extenso(lc: :br))
  end

  # testes extenso limites
  def test_limites
    # limite maximo foi ultrapassado - 24 digitos
    assert_equal('', '1112223334445556667778889'.extenso)
    assert_equal('', 1e24.extenso)
  end

  # testes extenso class Array, Range, Hash
  def test_class
    assert_equal({ a: 'UM EURO', b: 'DOIS EUROS' }, { a: 1, b: 2 }.extenso)
    assert_equal(['UM CÊNTIMO', 'DEZ CÊNTIMOS'], [0.01, 0.1].extenso)
    assert_equal(['UM EURO', 'DOIS EUROS'], (1..2).extenso)
    assert_equal(['UM EURO', 'DOIS EUROS'], %w[1 2].extenso)
    assert_equal({ a: ['TRÊS EUROS', 'DEZ EUROS'], b: 'DOIS EUROS' }, { a: [3, 10], b: 2 }.extenso)
  end

  # testes extenso unidades 1-23
  def test_unidades
    assert_equal(
      ['UM EURO'] +
      %w[DOIS TRÊS QUATRO CINCO SEIS SETE OITO NOVE DEZ].map { |eur| "#{eur} EUROS" } +
      %w[ONZE DOZE TREZE CATORZE QUINZE DEZASSEIS DEZASSETE DEZOITO DEZANOVE VINTE].map { |eur| "#{eur} EUROS" } + [
        'VINTE E UM EUROS',
        'VINTE E DOIS EUROS',
        'VINTE E TRÊS EUROS'
      ],
      (1..23).extenso
    )
  end
end
