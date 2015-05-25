
###
  HtmlElement
###

class HtmlElement

  constructor: (@tag, parent = null)->
    @id = null
    @classes = []
    @attr = []
    @innerText = null
    @children = []
    @parent = parent
    parent.children.push @ unless parent is null

@HtmlElement = HtmlElement


class CopolyElement
  constructor: (@tag, @parent)->
    @children = []
    @parent.children.push @ unless @parent is null

@CopolyElement = CopolyElement

class CopolyImportStatement extends CopolyElement
  constructor: (@source, parent)->
    super 'copoly-import', parent

@CopolyImportStatement = CopolyImportStatement

class CopolyDefineStatement extends CopolyElement
  constructor: (@elementName, parent)->
    super 'copoly-define', parent
    @attr = {}

@CopolyDefineStatement = CopolyDefineStatement

class CopolyExcludeStatement extends CopolyElement
  constructor: (parent)->
    super 'copoly-exclude', parent

@CopolyExcludeStatement = CopolyExcludeStatement

class CopolyIfStatement extends CopolyElement
  constructor: (@condition, parent)->
    super 'copoly-if', parent

@CopolyIfStatement = CopolyIfStatement

class CopolyElseIfStatement extends CopolyElement
  constructor: (@condition, parent)->
    super 'copoly-else-if', parent

@CopolyElseIfStatement = CopolyElseIfStatement

class CopolyElseStatement extends CopolyElement
  constructor: (parent)->
    super 'copoly-else', parent

@CopolyElseStatement = CopolyElseStatement

class CopolyUnlessStatement extends CopolyElement
  constructor: (@condition, parent)->
    super 'copoly-unless', parent

@CopolyUnlessStatement = CopolyUnlessStatement

class CopolyBindStatement extends CopolyElement
  constructor: (@bindStatement, parent)->
    super 'copoly-bind', parent

@CopolyBindStatement = CopolyBindStatement

class CopolyForInStatement extends CopolyElement
  constructor: (@value, @index, @collectionExpression, parent)->
    super 'copoly-for-in', parent

@CopolyForInStatement = CopolyForInStatement

class CopolyForOfStatement extends CopolyElement
  constructor: (@key, @value, @collectionExpression, parent)->
    super 'copoly-for-of', parent

@CopolyForOfStatement = CopolyForOfStatement

