
###
  Constant
###

###
  Structures
###

{HtmlElement} = require './tree-def'

###
  GenericParser
###

{GenericParser} = require './common'

###
  CohtmlElementParser
###

class CohtmlElementParser extends GenericParser

  constructor: ()->
    super
    @charset.htmlTag = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-!".split ''
    @charset.htmlAttributeName = "*%abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-".split ''
    @charset.htmlEmbeddedId = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-".split ''
    @charset.htmlEmbeddedClassName = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-".split ''

  # find / locate

  htmlTag: ()-> @any @charset.htmlTag

  htmlEmbeddedId: ()-> @any @charset.htmlEmbeddedId

  htmlEmbeddedClassName: ()-> @any @charset.htmlEmbeddedClassName

  htmlAttributeName: ()-> @any @charset.htmlAttributeName

  htmlAttributeValue: ()-> 
    return 0 unless @once '"'
    len = 1 + (@until ['"'], 1)
    return len

  htmlInnerText: ()-> 
    return 0 unless @once '`'
    len = 1 + ( @until ['`'], 1)
    return len

  htmlInlineInnerText: ()-> 
    return 0 unless @once '|'
    len = 1 + ( @until ['\n'], 1)
    return len

  cohtmlComment: ()-> 
    return 0 unless @once '#'
    if @word '###'
      @ignore 2
      len = 3 + ( @untilWord '###', 5)
      return len
    else
      len = 1 + ( @until ['\n'], 1)
      return len

  # extractional

  extractComment: (parent, indent)->
    len = @cohtmlComment()
    return false unless len
    @ignore 1
    innerText = @extract len-2
    @ignore 1

    element = new HtmlElement 'comment', parent
    element.innerText = innerText
    @ignore @linebreak()
    return true

  extractTextNode: (parent, indent)->
    len = @htmlInnerText()
    return false unless len
    @ignore 1
    innerText = @extract len-2
    @ignore 1
    element = new HtmlElement 'textNode', parent
    element.innerText = innerText
    @ignore @linebreak()
    return true
 
  extractHtmlEmbeddedIdAndClassName: (element)->
    @cap = 99
    while @cap--
      if @once ['$']
        @ignore 1
        len = @htmlEmbeddedId()
        throw new Error 'Expected ID Shorthand' if len is 0
        id = @extract len
        element.id = id
      else if @once ['.']
        @ignore 1
        len = @htmlEmbeddedClassName()
        throw new Error 'Expected ID Shorthand' if len is 0
        className = @extract len
        element.classes.push className
      else
        break
    return true

  extractHtmlAttributes: (element)->
    @cap = 99
    while @cap--
      @ignore @whitespace()
      len = @htmlAttributeName()
      if len
        attr = @extract len
        @ignore @whitespace()
        noval = true
        if @once ['=']
          @ignore 1
          @ignore @whitespace()
          len = @htmlAttributeValue()
          if len
            attrVal = @extract len
            noval = false
          else
            throw new Error 'Expected value of attribute.' + @report()
        attrVal = null if noval
        if attr.charAt(0) is '%'
          attr = attr.replace '%', 'data-'
        if attr.charAt(0) is '*'
          attr = attr.replace '*', 'on-'
          unless attrVal.charAt(1) is '{'
            attrVal = '"{{'+(attrVal.substr 1, (attrVal.length-2))+'}}"'
        if attr of element.attr
          element.attr[attr] += ' ' + attrVal
        else
          element.attr[attr] = attrVal
      else
        break
    return true

  extractInnerText:(element)->
    len = @htmlInnerText()
    return false unless len
    @ignore 1
    innerText = @extract len-2
    @ignore 1
    element.innerText = innerText
    return true

  extractInlineInnerText: (element)->
    len = @htmlInlineInnerText()
    return false unless len
    @ignore 1
    innerText = @extract len-2
    # @ignore 1
    element.innerText = innerText
    return true

  extractElement: (parent, indent)->
    len = @htmlTag()
    return false unless len

    tag = @extract len
    el = new HtmlElement tag, parent

    @ignore @whitespace()
    @extractHtmlEmbeddedIdAndClassName el

    @ignore @whitespace()
    @extractHtmlAttributes el

    @ignore @whitespace()
    unless @extractInlineInnerText el
      @extractInnerText el

    @ignore @whitespace()
    len = @linebreak()
    unless len
      throw new Error 'Expected new line or attributes.' + @report()
    @ignore len
    @extractChildNodes el, indent + 1

    return true

  prepareNextNodeForExtraction: (parent, expectedIndent)->
    @ignore @linebreak()
    @ignore_empty_lines()

    indent = @whitespace() / 2 # CONSIDER: Judge space and tabs differently?
    if indent isnt Math.floor indent
      msg = 'Inconsistent indent '+@report()
      throw new Error msg

    unless indent is expectedIndent
      return false 

    @ignore @whitespace()
    return true

  extractNode: (parent, expectedIndent)->

    if @extractElement parent, expectedIndent
      return true
    else if @extractTextNode parent, expectedIndent
      return true
    else if @extractComment parent, expectedIndent
      return true
    else
      unless @offset is @content.length
        throw new Error 'Expected HtmlElement or TextNode or Comment'+@report()
      return false

  extractChildNodes: (parent, indent)->
    @cap = 99
    while @cap--
      return false unless @prepareNextNodeForExtraction parent, indent
      unless @extractNode parent, indent
        @ignore @linebreak()
        @ignore_empty_lines()
        if @offset + 5 > @content.length
          'do nothing'
        return

  extractHtmlDocument: ()->
    root = new HtmlElement 'document'
    @root = root
    @extractChildNodes root, 0
    return root

@CohtmlElementParser = CohtmlElementParser


