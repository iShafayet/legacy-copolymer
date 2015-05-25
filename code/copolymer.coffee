
{CohtmlPreprocessor} = require './cohtml-preprocessor'
{GenericPreprocessor} = require './generic-preprocessor'


{CohtmlElementParser} = require './kept-from-b1/cohtml-parser'
{HtmlCompiler} = require './kept-from-b1/html-writer'
{CopolyParser} = require './kept-from-b1/copoly-parser'
{CopolyToHtmlConverter} = require './kept-from-b1/copoly-to-html'


###
  @Copolymer
###

class Copolymer

  constructor: (@options)->
    @cohtmlPreprocessor = new CohtmlPreprocessor @, @options
    @genericPreprocessor = new GenericPreprocessor @, @options
    @getterFnList = []
    @setterFnList = []

  # Internal Method
  getResource: (uri, cbfn)->
    (next = (index = 0)=>
      return cbfn (new err 'No Matches') if @getterFnList.length is index
      getterFn = @getterFnList[index]
      getterFn uri, (err, continueFlag, content)->
        if err
          if continueFlag
            return next index + 1
          else
            return cbfn err, null
        return cbfn null, content
    )()

  # Internal Method
  setResource: (uri, content, cbfn)->
    (next = (index = 0)=>
      return cbfn (new err 'No Matches') if @setterFnList.length is index
      setterFn = @setterFnList[index]
      setterFn uri, content, (err, continueFlag)->
        if err
          if continueFlag
            return next index + 1
          else
            return cbfn err
        return cbfn null
    )()

  ## Register a resource getter method
  #  the callback should have this signature -
  #   (uri, cbfn)->
  #   where -
  #     uri : an uri pointing to a resource (i.e. a file)
  #     cbfn : callback function (provided by registerResourceGetter)
  #   and the cbfn has this signature -
  #     (err, continueFlag, content)
  #     where - 
  #       err : null | error object
  #       continueFlag : true | false, indicate whethere the next resource getter needs to be called
  #       content : text
  registerResourceGetter: (getterFn)->
    @getterFnList.unshift getterFn

  ## Register a resource setter method
  #  the callback should have this signature -
  #   (uri, content, cbfn)->
  #   where -
  #     uri : an uri pointing to a resource
  #     cbfn : callback function (provided by registerResourceGetter)
  #   and the cbfn has this signature -
  #     (err, continueFlag)
  #     where - 
  #       err : null | error object
  #       continueFlag : true | false, indicate whethere the next resource getter needs to be called
  #       
  registerResourceSetter: (setterFn)->
    @setterFnList.unshift setterFn

  writeHtml: (uri, htmlSyntaxTree, options, cbfn)->
    htmlWriter = new HtmlCompiler htmlSyntaxTree, options
    content = htmlWriter.html htmlSyntaxTree
    @setResource uri, content, (err)->
      return cbfn err if err
      return cbfn null

  readCopoly: (uri, cbfn)->
    # prep = new DocumentPreProcessor @, uri
    @cohtmlPreprocessor.processAsync uri, (err, content)=>
      return cbfn err if err
      # console.log "Preprocessed Content \n|#{content}|"
      parser = new CopolyParser content
      try
        tree = parser.extractHtmlDocument()
      catch ex
        return cbfn ex, null
      return cbfn null, tree

  copolyToHtml: (tree)->
    return (new CopolyToHtmlConverter()).convert tree

@Copolymer = Copolymer

