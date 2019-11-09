# ExtensoPt [![Build Status](https://travis-ci.org/hernanilr/extenso_pt.svg?branch=master)](https://travis-ci.org/hernanilr/extenso_pt)

Produz extenso em portugês de portugal, brasil ou numeracao romana. Os valores podem ser um numerico, uma string de digitos ou um conjunto destes agrupados em (array, range, hash). O extenso pode ser produzido na escala longa (utilizada em todos os países lusófonos) ou na escala curta (utilizada no Brasil) [wiki](https://pt.wikipedia.org/wiki/Escalas_curta_e_longa). Pode ainda produzir numeracao romana e vice versa.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'extenso_pt'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install extenso_pt

## Usage

```ruby
1234.extenso                                       => "MIL DUZENTOS E TRINTA E QUATRO EUROS"
1234.romana                                        => "MCCXXXIV" 
"MCCXXXIV".romana                                  => 1234
12000000.12.extenso                                => "DOZE MILHÕES DE EUROS E DOZE CÊNTIMOS"
1.01.extenso(msingular:"DÓLAR")                    => "UM DÓLAR E UM CÊNTIMO"         
14.01.extenso(mplural:"REAIS",fsingular:"CENTAVO") => "CATORZE REAIS E UM CENTAVO"
14.1.extenso(lc: :br)                              => "QUATORZE REAIS E DEZ CENTAVOS"
14.01.extenso(mplural:"REAIS",fplural:"CENTAVOS")  => "CATORZE REAIS E UM CENTAVO"      # singular inferido = <plural> menos "S"
10.1.extenso(mplural:"DÓLARES")                    => "DEZ DÓLARES E DEZ CÊNTIMOS"      # plural   inferido = <silgular> mais "S"
1e10.extenso(lc: :pt)                              => "DEZ MIL MILHÕES DE EUROS"        # portugal usa escala longa
1e10.extenso(lc: :br)                              => "DEZ BILHÕES DE REAIS"            # brasil usa escala curta
[0.1, 0.2].extenso                                 => ["DEZ CÊNTIMOS","VINTE CÊNTIMOS"]
[4, 5, 6, 7].romana                                => ["IV", "V", "VI", "VII"]
(1..2).extenso                                     => ["UM EURO","DOIS EUROS"]
(7..9).romana                                      => ["VII", "VIII", "IX"]
{:a=>1, :b=>2}.extenso                             => {:a=>"UM EURO",:b=>"DOIS EUROS"}
{:a=>[3, 4], :b=>2}.extenso                        => {:a=>["TRÊS EUROS", "QUATRO EUROS"],:b=>"DOIS EUROS"} 
{:a=>["MCMLXVIII", "XIV"], :b=>4}.romana           => {:a=>[1968, 14], :b=>"IV"}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [github](https://github.com/hernanilr/extenso_pt).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
