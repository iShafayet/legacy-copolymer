
###
  Constant
###


pathlib = require 'path'

###
  Structures
###

{
  HtmlElement
  CopolyImportStatement
  CopolyDefineStatement
  CopolyExcludeStatement
  CopolyIfStatement
  CopolyUnlessStatement
  CopolyBindStatement
  CopolyForInStatement
  CopolyForOfStatement
} = require './tree-def'

###
  CopolyToHtmlConverter
###

class CopolyToHtmlConverter

  constructor: (@tree, {@pretty, @comments} = {})->
    @pretty or= true
    @comments or= true

    @current = {
      el: null
      name: null
      defaults: {}
      published: {}
    }

  generateScriptForCurrentElement: ()->
    return false if @current.el is null
    newNode = new HtmlElement 'script'
    newNode.attr['type'] = 'text/coffeescript'
    newNode.innerText = ''
    newNode.innerText += "Copolymer.registerMixin '#{@current.name}', {"
    newNode.innerText += "  publish: "




  replaceNode: (node, newNode)->
    newNode.parent = node.parent
    if node.children.length > 0
      newNode.children = node.children
      for child in node.children
        child.parent = newNode
    index = node.parent.children.indexOf node
    node.parent.children[index] = newNode if index > -1

  convertNode: (node)->
    if node.tag is 'copoly-import'
      ## =================================================== import
      # feature: expand the import source
      if (pathlib.extname node.source) is ''
        lastSlashIndex = node.source.lastIndexOf '/'
        moduleName = node.source.substring lastSlashIndex, node.source.length-1
        node.source = (node.source.substring 0, node.source.length-1) + "#{moduleName}.html\""
      # convert to HtmlElement
      newNode = new HtmlElement 'link'
      newNode.attr['rel'] = '"import"'
      newNode.attr['href'] = node.source
      @replaceNode node, newNode

    else if node.tag is 'copoly-define'
      ## =================================================== define
      # feature: current custom element
      if @current.el isnt null
        ''
        ## TODO save current

      @current.name = node.elementName
      @current.defaults = {}
      @current.published = {}

      # convert to HtmlElement
      @current.el = newNode = new HtmlElement 'polymer-element'
      newNode.attr['name'] = '"' + node.elementName + '"' 
      if 'noscript' of node.attr
        delete node.attr['noscript']
        newNode.attr['noscript'] = null
      newNode.attr['attributes'] = '"' + ((Object.keys node.attr).join ' ') + '"' # TODO: Default Values
      for key, value of node.attr
        @current.published[key] = value
      
      oldChildrenList = node.children
      @replaceNode node, newNode
      newNode.children = []
      template = new HtmlElement 'template'

      for child in oldChildrenList
        # console.log child.tag
        if child.tag is 'copoly-exclude'
          for innerChild in child.children
            innerChild.parent = newNode
            newNode.children.push innerChild
        else
          template.children.push child
          child.parent = template

      template.parent = newNode
      newNode.children.unshift template
      # console.log newNode, '================'

    else if node.tag is 'copoly-exclude'
      ## =================================================== exclude
      # throw new Error 'Unexpected Exclude Statement'
    else if node.tag is 'copoly-if'
      ## =================================================== if
      newNode = new HtmlElement 'template'
      newNode.attr['if'] = "\"{{#{node.condition}}}\""
      @replaceNode node, newNode
    else if node.tag is 'copoly-else-if'
      ## =================================================== else if
      newNode = new HtmlElement 'template'
      newNode.attr['if'] = 'TODO' # "\"{{#{node.condition}}}\""
      @replaceNode node, newNode
    else if node.tag is 'copoly-else'
      ## =================================================== else
      newNode = new HtmlElement 'template'
      newNode.attr['if'] = 'TODO' # "\"{{#{node.condition}}}\""
      @replaceNode node, newNode
    else if node.tag is 'copoly-unless'
      ## =================================================== unless
      newNode = new HtmlElement 'template'
      newNode.attr['if'] = "\"{{!(#{node.condition})}}\""
      @replaceNode node, newNode
    else if node.tag is 'copoly-bind'
      ## =================================================== bind
      newNode = new HtmlElement 'template'
      newNode.attr['bind'] = "\"{{#{node.bindStatement}}}\""
      @replaceNode node, newNode
    else if node.tag is 'copoly-for-in'
      ## =================================================== for..in
      newNode = new HtmlElement 'template'
      if node.index
        newNode.attr['repeat'] = "\"{{#{node.value}, #{node.index} in #{node.collectionExpression}}}\""
      else
        newNode.attr['repeat'] = "\"{{#{node.value} in #{node.collectionExpression}}}\""
      @replaceNode node, newNode
    else
      #return ## NOTE: ... removed for terminal parsing
      ''
    @convertChildren node.children

      
  convertChildren: (nodeList)->
    @convertNode node for node in nodeList

  convert: (tree)->
    @convertChildren tree.children
    #console.log tree
    return tree

@CopolyToHtmlConverter = CopolyToHtmlConverter
