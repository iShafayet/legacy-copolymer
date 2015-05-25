
###
  @GenericParser
###

class GenericParser

  constructor: (@rawContent)->
    @content = @rawContent.split ''
    @head  = 0
    @root = null
    @stack = []
    @Charset: 
      alphanumeric: 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'

  push: ()->
    @stack.push @head

  pop: ()->
    @stack.pop()

  ignore: (what)=>
    if typeof what is 'function'
      what = what()
    if typeof what is 'object'
      @head += what.len
    else if typeof what is 'number'
      @head += what
    else
      throw new Error 'GenericParser:InternalError, unknown thing given'

  extract: (what)=>
    if typeof what is 'function'
      what = what()
    if typeof what is 'object'
      count = what.len
    else if typeof what is 'number'
      count = what
    else
      throw new Error 'GenericParser:InternalError, unknown thing given'
    return '' if count is 0
    @head += count
    @content[@head-count..@head-1].join ''

  match: (what)=>
    if typeof what is 'function'
      what = what()
    if typeof what is 'object'
      return what.len
    else if typeof what is 'number'
      return what
    else if typeof what is 'boolean'
      return (if what then 1 else 0)
    else
      throw new Error 'GenericParser:InternalError, unknown thing given'
    @head += count
    @content[@head-count..@head-1].join ''

  any: (what)=>
    if typeof what is 'function'
      @push()
      totalLen = 0
      while len = @match what
        throw new Error 'Unsupported Type' if typeof len isnt 'number'
        totalLen += len
        @head += len
      @pop()
      return totalLen
    else
      throw new Error 'GenericParser:InternalError, unknown thing given'

  space: ' '

  newline: '\n'



  test: ()=>
    if @match @any, @newline




@GenericParser = GenericParser