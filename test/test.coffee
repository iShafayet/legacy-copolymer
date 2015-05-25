
###
  @testRunner
###

color = require 'cli-color'

count = 0
highlight = (text)->
  text = text.replace(/\n/g,'↲\n').replace(/\r/g,'[CR]').replace(/\t/g,'↦')

match = (input, output, expectedOutput)->
  count += 1
  unless output is expectedOutput
    console.log (color.red "  Failed: Test #{count}") + " (#{test.name})"
    console.log color.black 'INPUT'
    console.log highlight "|#{input}|"
    console.log color.blue 'EXPECTED'
    console.log highlight "|#{expectedOutput}|"
    console.log color.red 'RECEIVED'
    console.log highlight "|#{output}|"
    end()
  else
    console.log (color.green "  OK #{count}") + " #{test.name}"
    # next()

testIndex = 0
testList = []
test = ''

define = (name, fn)->
  testList.push {type: 'test', name, fn}

next = ()->
  if testList.length > testIndex
    test = testList[testIndex++]
    if test.type is 'test'
      test.fn()
    else if test.type is 'suite'
      console.log ' ' + test.name # + '\n'
      next()
  else
    end()

start = ()->
  console.log '\n\n\n\n\n\n'
  console.log color.bgWhite.black '> Test started'
  console.log ''
  next()

end = ()->
  console.log '\n\n\n\n\n\n'
  process.exit()

suite = (name)->
  testList.push {type: 'suite', name: color.bgWhite.black '> '+name}

###
  @imports
###

fs = require 'fs'
{Copolymer} = require './../index'

contentMap = {
  # uri : content  
}

copolymer = new Copolymer {
  shouldRemoveComments:true
  shouldRemoveInlineComments:true
  shouldRemoveBlockComments:true
  shouldInsertAdditionalComments:true
}

copolymer.registerResourceGetter (uri, cbfn)->
  content = fs.readFileSync './cases/'+uri, 'utf8'
  cbfn null, false, content

copolymer.registerResourceSetter (uri, content, cbfn)->
  fs.writeFileSync './cases/'+uri, content
  cbfn null, false

copolymer.registerResourceGetter (uri, cbfn)->
  if uri of contentMap
    cbfn null, false, contentMap[uri]
  else
    cbfn (new Error 'Not In Map'), true, null

###
  @copolymer.genericPreprocessor
###

suite 'GenericPreprocessor'

define 'Adds nl at the end', ->
  input = 'html\n  head'
  expectedOutput = 'html\n  head\n'
  output = copolymer.genericPreprocessor.process input
  match input,output, expectedOutput
  next()

define 'Does not add nl at the end', ->
  input = 'html\n  head\n'
  expectedOutput = 'html\n  head\n'
  output = copolymer.genericPreprocessor.process input
  match input,output, expectedOutput
  next()

define '\\r\\n to \\n', ->
  input = 'html\r\n  head\n'
  expectedOutput = 'html\n  head\n'
  output = copolymer.genericPreprocessor.process input
  match input,output, expectedOutput
  next()

define '\\t to Space', ->
  input = 'html\r\n\thead\n'
  expectedOutput = 'html\n  head\n'
  output = copolymer.genericPreprocessor.process input
  match input,output, expectedOutput
  next()

define '\\r to \\n', ->
  input = 'html\r\thead\n'
  expectedOutput = 'html\n  head\n'
  output = copolymer.genericPreprocessor.process input
  match input,output, expectedOutput
  next()

define '\\r\\r\\n to \\n\\n', ->
  input = 'html\r\r\n  head\n'
  expectedOutput = 'html\n\n  head\n'
  output = copolymer.genericPreprocessor.process input
  match input,output, expectedOutput
  next()

###
  @CohtmlPreprocessor
###

suite 'CohtmlPreprocessor'

define 'Remove Single Inline Comment', ->
  i = '''
      html
        # just a head tag
        head
      '''
  e = '''
      html
        head

      '''
  contentMap['/test/preproc'] = i
  copolymer.cohtmlPreprocessor.processAsync '/test/preproc', (err, o)->
    throw err if err
    match i, o, e
    next()

define 'Do Not Single Inline Comment Inside String', ->
  i = '''
      html
        #
        '# just a head ''tag'
        head
      '''
  e = '''
      html
        '# just a head ''tag'
        head

      '''
  contentMap['/test/preproc'] = i
  copolymer.cohtmlPreprocessor.processAsync '/test/preproc', (err, o)->
    throw err if err
    match i, o, e
    next()

define 'Remove Single Inline Comment (At Line Start)', ->
  i = '''
      html
      # just a head tag
        head
      '''
  e = '''
      html
        head

      '''
  contentMap['/test/preproc'] = i
  copolymer.cohtmlPreprocessor.processAsync '/test/preproc', (err, o)->
    throw err if err
    match i, o, e
    next()

define 'Remove Single Inline Comment (with double hash)', ->
  i = '''
      html
        ## just a head tag
        head
      '''
  e = '''
      html
        head

      '''
  contentMap['/test/preproc'] = i
  copolymer.cohtmlPreprocessor.processAsync '/test/preproc', (err, o)->
    throw err if err
    match i, o, e
    next()

define 'Remove Single Inline Comment (with multiple in the same line)', ->
  i = '''
      html
        ## just a head # fsfs ## tag
        head
      '''
  e = '''
      html
        head

      '''
  contentMap['/test/preproc'] = i
  copolymer.cohtmlPreprocessor.processAsync '/test/preproc', (err, o)->
    throw err if err
    match i, o, e
    next()

define 'Remove Multiple Inline Comment', ->
  i = '''
      html
        # just a head tag
        # Another head tag
        head
        # WHAT?
      '''
  e = '''
      html
        head

      '''
  contentMap['/test/preproc'] = i
  copolymer.cohtmlPreprocessor.processAsync '/test/preproc', (err, o)->
    throw err if err
    match i, o, e
    next()

define 'Remove Multiple Inline Comment (with irregular indentation', ->
  i = '''
      html
        # just a head tag
       # Another head tag
        head
                  # WHAT?
      '''
  e = '''
      html
        head

      '''
  contentMap['/test/preproc'] = i
  copolymer.cohtmlPreprocessor.processAsync '/test/preproc', (err, o)->
    throw err if err
    match i, o, e
    next()

define 'Remove Single Block Comment', ->
  i = '''
      html
        ### just a head tag
        Another head tag ###
        head
                  # WHAT?
      '''
  e = '''
      html
        head

      '''
  contentMap['/test/preproc'] = i
  copolymer.cohtmlPreprocessor.processAsync '/test/preproc', (err, o)->
    throw err if err
    match i, o, e
    next()

define 'Remove Single Block Comment (With Error)', ->
  i = '''
      html
        ### just a head tag
        Another head tag
        head
                  # WHAT?
      '''
  e = '''
      html
        head

      '''
  contentMap['/test/preproc'] = i
  copolymer.cohtmlPreprocessor.processAsync '/test/preproc', (err, o)->
    if err
      if err.code is 'CohtmlPreprocessor:ExpectedBlockCommentEnd'
        match 'OK', 'OK', 'OK'
      else
        throw err if err
    else
      throw 'Expected Error'
    next()

define 'Remove Multiple Block Comment', ->
  i = '''
      html
        ### just a head tag
        Another head tag 
        ###
        ###
        AAAAA
        ###
        head
                  # WHAT?
      '''
  e = '''
      html
        head

      '''
  contentMap['/test/preproc'] = i
  copolymer.cohtmlPreprocessor.processAsync '/test/preproc', (err, o)->
    throw err if err
    match i, o, e
    next()

define 'Partial Block / Use Line', ->
  i = '''
      @partial "head-content"
        link style="text/css" href="myStyl.css"
        script type="text/javascript" src="myFile.js"
      @partial "body-content"
        div | asdf
      html
        head
          @insert "head-content"
        body
          @insert "body-content"
      '''
  e = '''
      html
        head
          link style="text/css" href="myStyl.css"
          script type="text/javascript" src="myFile.js"
        body
          div | asdf

      '''
  contentMap['/test/preproc'] = i
  copolymer.cohtmlPreprocessor.processAsync '/test/preproc', (err, o)->
    throw err if err
    match i, o, e
    next()


define 'Partial Block / Use Line (another)', ->
  i = '''
      html
        @partial "head-content"
          link style="text/css" href="myStyl.css"
          script type="text/javascript" src="myFile.js"
        @partial "body-content"
          div | asdf
        head
          @insert "head-content"
        body
          @insert "body-content"
      '''
  e = '''
      html
        head
          link style="text/css" href="myStyl.css"
          script type="text/javascript" src="myFile.js"
        body
          div | asdf
      
      '''
  contentMap['/test/preproc'] = i
  copolymer.cohtmlPreprocessor.processAsync '/test/preproc', (err, o)->
    throw err if err
    match i, o, e
    next()

###
  @start
###

start()






