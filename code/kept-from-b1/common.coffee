
###
  @GenericParser
###

class GenericParser

  charset: {}

  constructor: (@rawContent)->
    @offset  = 0
    @content = @rawContent.split ''
    @root = null

  # ignore count amount of characters
  ignore: (count)->
    if typeof count isnt 'number'
      throw new Error 'Count must be a number'
    @offset += count
    return true

  # extract certain amount of characters as string
  extract: (count)->
    return '' if count is 0
    @offset += count
    return @content[@offset-count..@offset-1].join ''

  # length selector (matches any until character outside charset)
  any: (charset)->
    i = @offset
    while @content[i] in charset
      i++
    return i - @offset

  # returns true if the current character is within the charset 
  once: (charset)->
    return @content[@offset] in charset

  # length selector (matches any until character is in charset)
  until: (charset, start = 0)->
    i = start
    until (@content[i+@offset] in charset)
      i++
    return i

  untilWord: (word, start = 0)->
    i = start
    until @word word, i
      i++
    return i

  word: (word, start = 0)->
    len = 0
    word = word.split ''
    for a,i in word
      if @content[@offset + i + start] is a
        len+=1
      else
        return 0
    return len

  whitespace: ()-> @any [' ', '\t']

  linebreak: ()-> @any ['\n']

  ignore_empty_lines: ()->
    loop
      len = @whitespace()
      break unless len
      bc = @offset
      @ignore len

      len = @linebreak()
      if len
        @ignore len
      else
        @offset = bc
        break

  report: ->

    # console.log (require 'util').inspect(@root, {depth:null})

    # console.log @content.join ''

    line = 1
    pos = 0
    linepos = 0
    while (pos = @content.indexOf('\n', pos+1)) > -1 and pos < @offset
      linepos = pos
      line += 1

    str = "\n  cursor: #{@offset} out of #{@content.length}\n"
    str += "  line:   #{line}\n"
    str += "  character: #{@offset-linepos}\n"
    charcodesStart = @offset
    charcodesStart = @offset-1 if @offset-1 >= 0
    charcodesStart = @offset-2 if @offset-2 >= 0
    charcodesEnd = @offset
    charcodesEnd = @offset+1 if @offset+1 < @content.length
    charcodesEnd = @offset+2 if @offset+2 < @content.length

    charcodes = ''
    for i in [charcodesStart..charcodesEnd]
      charcodes += '[' if i is @offset
      charcodes +=  (@content[i].charCodeAt 0)
      charcodes += ']' if i is @offset
      charcodes += ' '
    
    str += "  charcode: #{charcodes}\n"

    from = linepos+1 #(if @offset-10 < 0 then 0 else @offset-10)
    to = @offset+20
    atstr = @content.slice(from,@offset).join('') + '' + @content.slice(@offset,to).join('')
    str += "  at: " + atstr.replace(/\n/g, '[NL]') + '...' + '\n'

    from = linepos+1 #(if @offset-10 < 0 then 0 else @offset-10)
    to = @offset+20
    left = @content.slice(from,@offset).join('')
    torep = ''
    while torep.length < left.length
      torep += ' '
    atstr =  torep + '^'
    str += "      "  +atstr+ '\n\n'

    return str

@GenericParser = GenericParser

