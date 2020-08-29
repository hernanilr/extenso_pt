# frozen_string_literal: true

require('test_helper')

class ExtensoPtTest < Minitest::Test
  def test_romana
    # testa conversao romana e vice versa
    assert_equal('MCMXXVIII', -1928.romana)
    assert_equal('MCMXXVII', +1927.romana)
    assert_equal(1234, 'MCCXXXIV'.romana)
    assert_equal('MCMLXVII', 1967.romana)
    assert_equal(1969, 'MCMLXIX'.romana)
    assert_equal((1..3999).to_a, (1..3999).romana.romana)
  end

  def test_romana_obj
    # Teste de ojectos que renpondem a to_a (Array, Range, Hash)
    assert_equal({ a: 1235, b: 'MCMXXVII' }, { a: 'MCCXXXV', b: 1927 }.romana)
    assert_equal(%w[I II III IV], (1..4).romana)
    assert_equal([1, 2], %w[I II].romana)
    assert_equal({ a: %w[MCMLXVIII XIV], b: 'II' }, { a: [1968, 14], b: 2 }.romana)
  end

  def test_romana?
    assert_equal(true, 'MCCXXXIV'.romana?)
    assert_equal(false, 'lixo'.romana?)
  end
end
