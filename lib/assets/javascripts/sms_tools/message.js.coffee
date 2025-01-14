window.SmsTools ?= {}

class SmsTools.Message
  maxLengthForEncoding:
    ascii:
      normal: 160
      concatenated: 153
    gsm:
      normal: 160
      concatenated: 153
    unicode:
      normal: 70
      concatenated: 67

  doubleByteCharsInGsmEncoding:
    '^':  true
    '{':  true
    '}':  true
    '[':  true
    '~':  true
    ']':  true
    '|':  true
    '€':  true
    '\\': true
    '↵':  true

  asciiPattern: /^[\x00-\x7F]*$/
  gsmEncodingPattern: /^[0-9a-zA-Z@Δ¡¿£_!Φ"¥Γ#èΛ¤éΩ%ùΠ&ìΨòΣçΘΞ:Ø;ÄäøÆ,<Ööæ=ÑñÅß>ÜüåÉ§à€~ \$\.\-\+\(\)\*\\\/\?\|\^\}\{\[\]\'\r\n]*$/

  constructor: (@text) ->
    @encoding               = @_encoding()
    @length                 = @_length()
    @concatenatedPartsCount = @_concatenatedPartsCount()

  maxLengthFor: (concatenatedPartsCount) ->
    messageType = if concatenatedPartsCount > 1 then 'concatenated' else 'normal'

    concatenatedPartsCount * @maxLengthForEncoding[@encoding][messageType]

  use_gsm_encoding: ->
    if SmsTools['use_gsm_encoding'] == undefined
      true
    else
      SmsTools['use_gsm_encoding']

  _encoding: ->
    if @use_gsm_encoding() and @gsmEncodingPattern.test(@text)
      'gsm'
    else if @asciiPattern.test(@text)
      'ascii'
    else
      'unicode'

  _concatenatedPartsCount: ->
    encoding = @encoding
    length   = @length

    if length <= @maxLengthForEncoding[encoding].normal
      1
    else
      parseInt Math.ceil(length / @maxLengthForEncoding[encoding].concatenated), 10

  # Returns the number of symbols which the given text will eat up in an SMS
  # message, taking into account any double-space symbols in the GSM 03.38
  # encoding.
  _length: ->
    length = @text.length

    if @encoding == 'gsm'
      text = @text.replace /\r|\n/g, '↵'
      for char in text
        length += 1 if @doubleByteCharsInGsmEncoding[char]

    length
