
###
  Constant
###

###
  Structures
###

{HtmlElement} = require './tree-def'

###
  HtmlCompiler
###

class HtmlCompiler

  selfClosingHtmlTags: ['area', 'base', 'br', 'col', 'command', 'embed', 'hr', 'img', 'input', 'keygen', 'link', 'meta', 'param', 'source', 'track', 'wbr']

  nonClosingHtmlTags: ['!doctype']

  constructor: (@tree, {@pretty, @comments} = {})->
    @pretty or= true
    @comments or= true

  elementNode: (node, indent)->
    {tag, id, classes, attr, children, innerText} = node
    attr['id'] = '"'+id+'"' if id

    if classes.length > 0
      if 'class' of attr
        attr['class'] = attr['class'].replace('"', '').replace('"', '') + ' ' 
      else
        attr['class'] = '' 
      attr['class'] = '"' + attr['class'] + (classes.join ' ')+'"'

    html = (if @pretty then indent else '') + "<#{tag}"    
    for key, val of attr
      html += " #{key}" + (if val then "=#{val}" else '')
    html += if (tag in @selfClosingHtmlTags) then ' />' else '>'
    html += (if @pretty and children.length > 0 then '\n' else '')
    if children.length is 0
      html += innerText if innerText
    else
      html += @childNodes children, (indent + '  ')
    unless (tag in @selfClosingHtmlTags) or (tag in @nonClosingHtmlTags)
      html += (if @pretty and children.length > 0 then indent else '') + "</#{tag}>"
    html += (if @pretty then '\n' else '')
    return html

  textNode: (node, indent)->
    return false unless node.tag is 'textNode'
    return (if @pretty then indent else '') + node.innerText + (if @pretty then '\n' else '')

  commentNode: (node, indent)->
    return false unless node.tag is 'comment'
    return (if @pretty then indent else '') + "<!--#{node.innerText}-->" + (if @pretty then '\n' else '')

  node: (node, indent)->
    unless node instanceof HtmlElement
      console.log node
      throw new Error 'Expected HtmlElement'
    if val = @commentNode node, indent
      return val
    else if val = @textNode node, indent
      return val
    else if val = @elementNode node, indent
      return val
    else
      throw new Error 'Unknown Type of Node'

  childNodes: (children, indent)->
    (@node child, indent for child in children).join ''

  html: (tree)->
    @childNodes tree.children, ''


@HtmlCompiler = HtmlCompiler



  
