# ExtensoPt

Produz valores monetários por extenso e em portugês de portugal. Os valores monetários podem ser um numerico ou uma string de digitos. O extenso será produzido na escala longa [wiki](https://pt.wikipedia.org/wiki/Escalas_curta_e_longa), utilizada em todos os países lusófonos (à excepção do Brasil), podendo escolher a moeda.
 
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
"1234.10".extenso                               => "MIL DUZENTOS E TRINTA E QUATRO EUROS E DEZ CÊNTIMOS"
12000000.12.extenso                             => "DOZE MILHÕES DE EUROS E DOZE CÊNTIMOS"
1.01.extenso(moeda:"DÓLAR")                     => "UM DÓLAR E UM CÊNTIMO"
10.1.extenso(moedap:"DÓLARES")                  => "DEZ DÓLARES E DEZ CÊNTIMOS"
1.01.extenso(moeda:"REAL",fracao:"CENTAVO")     => "UM REAL E UM CENTAVO"
1.10.extenso(moeda:"REAL",fracao:"CENTAVO")     => "UM REAL E DEZ CENTAVOS"
2.00.extenso(moedap:"REAIS")                    => "DOIS REAIS"
2.10.extenso(moedap:"REAIS",fracaop:"CENTAVOS") => "DOIS REAIS E DEZ CENTAVOS"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [github](https://github.com/hernanilr/extenso_pt).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
