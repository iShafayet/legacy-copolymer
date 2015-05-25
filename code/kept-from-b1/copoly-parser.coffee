
###
  Constant
###

###
  Structures
###

{HtmlElement} = require './tree-def'

{
  CopolyImportStatement
  CopolyDefineStatement
  CopolyExcludeStatement
  CopolyIfStatement
  CopolyElseIfStatement
  CopolyElseStatement
  CopolyUnlessStatement
  CopolyBindStatement
  CopolyForInStatement
  CopolyForOfStatement
} = require './tree-def'

###
  GenericParser
###

{GenericParser} = require './common'

###
  CohtmlElementParser
###

{CohtmlElementParser} = require './cohtml-parser'

class CopolyParser extends CohtmlElementParser

  constructor: ()->
    super
    @charset.identifier = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-".split ''
    #@charset.htmlAttributeName = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-".split ''

  extractCopolyImportStatement: (parent, indent)->
    len = @word 'import'
    return false unless len
    @ignore len
    @ignore @whitespace()
    len = @htmlAttributeValue()
    throw new Error 'Expected Import Source ' + @report() unless len
    source = @extract len
    new CopolyImportStatement source, parent
    return true

  extractCopolyDefineStatement: (parent, indent)->
    len = @word 'define'
    return false unless len
    @ignore len
    @ignore @whitespace()
    len = @htmlAttributeName()
    throw new Error 'Expected Custom Element Name ' + @report() unless len
    name = @extract len
    @ignore @whitespace()
    el = new CopolyDefineStatement name, parent
    @extractHtmlAttributes el
    @extractChildNodes el, indent + 1
    return true

  extractCopolyIfStatement: (parent, indent)->
    len = @word 'if'
    return false unless len
    @ignore len
    @ignore @whitespace()
    len = @until ['\n']
    throw new Error 'Expected polymer expression as condition' + @report() unless len
    exp = @extract len
    el = new CopolyIfStatement exp, parent
    @extractChildNodes el, indent + 1
    return true

  extractCopolyElseIfStatement: (parent, indent)->
    len = @word 'else if'
    return false unless len
    @ignore len
    @ignore @whitespace()
    len = @until ['\n']
    throw new Error 'Expected polymer expression as condition' + @report() unless len
    exp = @extract len
    el = new CopolyElseIfStatement exp, parent
    @extractChildNodes el, indent + 1
    return true

  extractCopolyElseStatement: (parent, indent)->
    len = @word 'else'
    return false unless len
    @ignore len
    @ignore @whitespace()
    len = @until ['\n']
    # throw new Error 'Expected polymer expression as condition' + @report() unless len
    @ignore len
    el = new CopolyElseStatement parent
    @extractChildNodes el, indent + 1
    return true

  extractCopolyUnlessStatement: (parent, indent)->
    len = @word 'unless'
    return false unless len
    @ignore len
    @ignore @whitespace()
    len = @until ['\n']
    throw new Error 'Expected polymer expression as condition' + @report() unless len
    exp = @extract len
    el = new CopolyUnlessStatement exp, parent
    @extractChildNodes el, indent + 1
    return true

  extractCopolyBindStatement  : (parent, indent)->
    len = @word 'bind'
    return false unless len
    @ignore len
    @ignore @whitespace()
    len = @until ['\n']
    throw new Error 'Expected polymer expression as condition' + @report() unless len
    exp = @extract len
    el = new CopolyBindStatement exp, parent
    @extractChildNodes el, indent + 1
    return true

  extractCopolyForStatement: (parent, indent)->
    len = @word 'for'
    return false unless len
    @ignore len
    @ignore @whitespace()
    len = @any @charset.identifier
    throw new Error 'Expected identifier' + @report() unless len
    a = @extract len
    b = null
    @ignore @whitespace()
    len = @word ','
    if len
      @ignore len
      @ignore @whitespace()
      len = @any @charset.identifier
      throw new Error 'Expected identifier' + @report() unless len
      b = @extract len
    @ignore @whitespace()
    el = null
    if @word 'in'
      @ignore 2
      el = new CopolyForInStatement a, b, null, parent
    else if @word 'of'
      @ignore 2
      el = new CopolyForOfStatement a, b, null, parent
    else
      throw new Error 'Expected "in" or "of"' + @report()
    @ignore @whitespace()
    len = @until ['\n']
    throw new Error 'Expected polymer list/object/expression' + @report() unless len
    el.collectionExpression = @extract len
    @extractChildNodes el, indent + 1
    return true

  extractCopolyExcludeStatement: (parent, indent)->
    len = @word 'exclude'
    return false unless len
    @ignore len
    @ignore @whitespace()
    el = new CopolyExcludeStatement parent
    @extractChildNodes el, indent + 1
    return true

  extractCopolyStatement: (parent, indent)->
    if @extractCopolyImportStatement parent, indent
      #@ignore @whitespace()
      return true
    else if @extractCopolyDefineStatement parent, indent
      #@ignore @whitespace()
      return true
    else if @extractCopolyIfStatement parent, indent
      # @ignore @whitespace()
      return true
    else if @extractCopolyElseIfStatement parent, indent
      #@ignore @whitespace()
      return true
    else if @extractCopolyElseStatement parent, indent
      #@ignore @whitespace()
      return true
    else if @extractCopolyUnlessStatement parent, indent
      #@ignore @whitespace()
      return true
    else if @extractCopolyBindStatement parent, indent
      #@ignore @whitespace()
      return true
    else if @extractCopolyForStatement parent, indent
      #@ignore @whitespace()
      return true
    else if @extractCopolyExcludeStatement parent, indent
      #@ignore @whitespace()
      return true
    else 
      return false 

  extractNode: (parent, expectedIndent)->
    if @extractCopolyStatement parent, expectedIndent
      return true
    else
      return super


@CopolyParser = CopolyParser


