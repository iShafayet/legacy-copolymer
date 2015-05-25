

###
  @GenericPreprocessor
###

class GenericPreprocessor

  constructor: (@copolymer)->
    
  process: (content)->
    content = content.replace /\r\n/g, '\n'
    content = content.replace /\r/g, '\n'
    content = content.replace /\t/g, '  '
    unless '\n' is content.charAt (content.length-1)
      content += '\n'
    return content

@GenericPreprocessor = GenericPreprocessor
  
