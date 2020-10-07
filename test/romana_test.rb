# frozen_string_literal: true

require('test_helper')

# classe para testes da gem
class ExtensoPtTest < Minitest::Test
  # testa conversao romana e vice versa
  def test_romana
    assert_equal('MCMXXVIII', -1928.romana)
    assert_equal('MCMLXVII', 1967.romana)
    assert_equal(1234, 'MCCXXXIV'.romana)
    assert_equal(1969, 'MCMLXIX'.romana)
    assert_equal((1..3999).to_a, (1..3999).romana.romana)
  end

  # testes romana class Array, Range, Hash
  def test_romana_class
    assert_equal({ a: 1235, b: 'MCMXXVII' }, { a: 'MCCXXXV', b: 1927 }.romana)
    assert_equal(%w[I II III IV], (1..4).romana)
    assert_equal([1, 2], %w[I II].romana)
    assert_equal({ a: %w[MCMLXVIII XIV], b: 'II', c: { d: 1960 } }, { a: [1968, 14], b: 2, c: { d: 'MCMLX' } }.romana)
  end

  # testes se numeracao romana
  def test_romana?
    assert_equal(true, 'MCCXXXIV'.romana?)
    assert_equal(false, 'lixo'.romana?)
  end
end
