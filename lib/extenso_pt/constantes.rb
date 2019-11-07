# frozen_string_literal: true

# @author Hernani Rodrigues Vaz
module ExtensoPt
  # constantes para producao de extenso em portugues de portugal ou brasil
  EXTLC = %i[pt br].freeze
  A0020 = {
    pt: ['', 'UM', 'DOIS', 'TRÊS', 'QUATRO', 'CINCO', 'SEIS', 'SETE',
         'OITO', 'NOVE', 'DEZ', 'ONZE', 'DOZE', 'TREZE', 'CATORZE',
         'QUINZE', 'DEZASSEIS', 'DEZASSETE', 'DEZOITO', 'DEZANOVE'],
    br: ['', 'UM', 'DOIS', 'TRES', 'QUATRO', 'CINCO', 'SEIS', 'SETE',
         'OITO', 'NOVE', 'DEZ', 'ONZE', 'DOZE', 'TREZE', 'QUATORZE',
         'QUINZE', 'DEZESSEIS', 'DEZESSETE', 'DEZOITO', 'DEZENOVE']
  }.freeze
  A0100 = {
    pt: ['', '', 'VINTE', 'TRINTA', 'QUARENTA', 'CINQUENTA', 'SESSENTA',
         'SETENTA', 'OITENTA', 'NOVENTA'],
    br: ['', '', 'VINTE', 'TRINTA', 'QUARENTA', 'CINQUENTA', 'SESSENTA',
         'SETENTA', 'OITENTA', 'NOVENTA']
  }.freeze
  A1000 = {
    pt: ['', 'CEM', 'CENTO', 'DUZENTOS', 'TREZENTOS', 'QUATROCENTOS',
         'QUINHENTOS', 'SEISCENTOS', 'SETECENTOS', 'OITOCENTOS', 'NOVECENTOS'],
    br: ['', 'CEM', 'CENTO', 'DUZENTOS', 'TREZENTOS', 'QUATROCENTOS',
         'QUINHENTOS', 'SEISCENTOS', 'SETECENTOS', 'OITOCENTOS', 'NOVECENTOS']
  }.freeze

  # escala longa portugal segundo convencao entre varios paises,
  #  na 9a Conferencia Geral de Pesos e Medidas (12-21 de Outubro de 1948),
  #  organizada pelo Bureau International des Poids et Mesures
  # 1 000 000 = milhao
  # 1 000 000 000 000 = biliao
  # 1 000 000 000 000 000 000 = triliao
  # 1 000 000 000 000 000 000 000 000 = quadriliao
  # 1 000 000 000 000 000 000 000 000 000 000 = quintiliao
  # 1 000 000 000 000 000 000 000 000 000 000 000 000 = sextiliao
  S1E24 = { pt: ['', 'MIL', ' MILHÃO', ' MIL MILHÃO', ' BILIÃO',
                 ' MIL BILIÃO', ' TRILIÃO', ' MIL TRILIÃO'],
            br: ['', 'MIL', ' MILHÃO', ' BILHÃO', ' TRILHÃO',
                 ' QUADRILHÃO', ' QUINTILHÃO', ' SEXTILHÃO'] }.freeze
  P1E24 = { pt: ['', ' MIL', ' MILHÕES', ' MIL MILHÕES', ' BILIÕES',
                 ' MIL BILIÕES', ' TRILIÕES', ' MIL TRILIÕES'],
            br: ['', ' MIL', ' MILHÕES', ' BILHÕES', ' TRILHÕES',
                 ' QUADRILHÕES', ' QUINTILHÕES', ' SEXTILHÕES'] }.freeze

  # contantes para numeracao romana
  ROMAN = { M: 1000, CM: 900,
            D: 500,  CD: 400,
            C: 100,  XC: 90,
            L: 50,   XL: 40,
            X: 10,   IX: 9,
            V: 5,    IV: 4,
            I: 1 }.freeze
  # numeral romano
  RO_RE = /^M*(D?C{0,3}|C[DM])(L?X{0,3}|X[LC])(V?I{0,3}|I[VX])$/i.freeze
end
