

{replaceInRange, rewindTillMatches, countCharacterBeforePosition, countCharacterFromListBeforePosition, highlight} = require './utilities'

###
  @CohtmlPreprocessor
###

class CohtmlPreprocessor

  constructor: (@copolymer, @options = {})->
    {@shouldRemoveComments, @shouldRemoveInlineComments, @shouldRemoveBlockComments, @shouldInsertAdditionalComments} = @options
    if @shouldRemoveComments
      @shouldRemoveInlineComments = true
      @shouldRemoveBlockComments = true
    @shouldRemoveInlineComments = false unless @shouldRemoveInlineComments
    @shouldRemoveBlockComments = false unless @shouldRemoveBlockComments
    @shouldInsertAdditionalComments = false unless @shouldInsertAdditionalComments

  __removeInlineComments: (content)->
    offset = 0
    while (lineStartPos = content.indexOf '#', offset) isnt -1
      lineStartPos = rewindTillMatches content, lineStartPos, [' ']
      lineEndPos = content.indexOf '\n', lineStartPos
      if ((countCharacterFromListBeforePosition content, lineStartPos + 1, ['\'', '\"', '`']) % 2 is 0)
        content = replaceInRange content, lineStartPos, lineEndPos + 1, ''
      else
        offset = lineEndPos
    return content

  __removeBlockComments: (content)->
    offset = 0
    while (blockStartPos = content.indexOf '###', offset) isnt -1
      blockEndPos = content.indexOf '###', blockStartPos + 1
      if blockEndPos is -1
        err = new Error
        err.message = 'CohtmlPreprocessor: Expected ###' + 
                      '  Line: ' + countCharacterBeforePosition content, blockStartPos + 1, '\n'
        err.code = 'CohtmlPreprocessor:ExpectedBlockCommentEnd'
        throw err
      content = replaceInRange content, blockStartPos, blockEndPos + 2, ''
    return content

  __processPartialTags: (content)->
    partialList = []
    offset = 0
    while (partialStartPos = content.indexOf '@partial', offset) isnt -1
      if ((countCharacterFromListBeforePosition content, partialStartPos + 1, ['\'', '\"', '`']) % 2 isnt 0)
        offset = partialStartPos + 2
        continue
      partialEndPos = content.indexOf '\n', partialStartPos
      partialBlockStartPos = rewindTillMatches content, partialStartPos, [' ']
      partialIndentLevel = partialStartPos - partialBlockStartPos
      partialInnerIndentLevel = partialIndentLevel + 2
      partialInnerIndent = ''
      partialInnerIndent += ' ' for i in [1..partialInnerIndentLevel]
      # console.log partialIndentLevel, partialInnerIndent.length
      partialBlockEndPos = partialEndPos
      loop
        newLinePos = content.indexOf ('\n'), partialBlockEndPos + 1
        indentedLinePos = content.indexOf ('\n'+partialInnerIndent), partialBlockEndPos + 1
        break if newLinePos is -1
        break if indentedLinePos is -1
        partialBlockEndPos = newLinePos
        break if indentedLinePos isnt newLinePos
      if partialBlockEndPos is partialEndPos
        err = new Error
        err.message = 'CohtmlPreprocessor: Partial Blocks Can Not Be Empty' + 
                      '  Line: ' + countCharacterBeforePosition content, blockStartPos + 1, '\n'
        err.code = 'CohtmlPreprocessor:EmptyPartialBlock'
        throw err
      partialDeclaration = content.substring partialStartPos, partialEndPos
      partialBody = content.substring partialEndPos + 1, partialBlockEndPos
      content = replaceInRange content, partialBlockStartPos, partialBlockEndPos + 1, ''

      p1 = partialDeclaration.indexOf '"'
      p2 = partialDeclaration.indexOf '"', p1 + 1
      if p1 and p2 and p1 < p2
        partialName = partialDeclaration.substring p1+1, p2
      else
        err = new Error
        err.message = 'CohtmlPreprocessor: Missing Partial Name' + 
                      '  Line: ' + countCharacterBeforePosition content, blockStartPos + 1, '\n'
        err.code = 'CohtmlPreprocessor:MissingPartialName'
        throw err
      partialList.push {
        body:partialBody
        name:partialName
        indent: partialInnerIndent
      }
    return {content, partialList}

  __processInsertTags: (content, partialList)->
    offset = 0
    while (insertStartPos = content.indexOf '@insert', offset) isnt -1
      if ((countCharacterFromListBeforePosition content, insertStartPos + 1, ['\'', '\"', '`']) % 2 isnt 0)
        offset = insertStartPos + 2
        continue
      insertEndPos = content.indexOf '\n', insertStartPos
      insertBlockStartPos = rewindTillMatches content, insertStartPos, [' ']
      insertIndentLevel = insertStartPos - insertBlockStartPos
      insertIndent = ''
      insertIndent += ' ' for i in [1..insertIndentLevel]

      insertDeclaration = content.substring insertStartPos, insertEndPos
      p1 = insertDeclaration.indexOf '"'
      p2 = insertDeclaration.indexOf '"', p1 + 1
      if p1 and p2 and p1 < p2
        insertName = insertDeclaration.substring p1+1, p2
      else
        err = new Error
        err.message = 'CohtmlPreprocessor: Missing Insert Name' + 
                      '  Line: ' + countCharacterBeforePosition content, blockStartPos + 1, '\n'
        err.code = 'CohtmlPreprocessor:MissingInsertName'
        throw err

      matchedPartialList = (partial for partial in partialList when partial.name is insertName)
      if matchedPartialList.length is 0
        err = new Error
        err.message = 'CohtmlPreprocessor: Unknown Partial' + 
                      '  Line: ' + countCharacterBeforePosition content, blockStartPos + 1, '\n'
        err.code = 'CohtmlPreprocessor:UnknownPartial'
        throw err
      if matchedPartialList.length isnt 1
        err = new Error
        err.message = 'CohtmlPreprocessor: Duplicate Partial' + 
                      '  Line: ' + countCharacterBeforePosition content, blockStartPos + 1, '\n'
        err.code = 'CohtmlPreprocessor:DuplicatePartial'
        throw err
      partial = matchedPartialList[0]
      body = partial.body.replace (new RegExp partial.indent, 'g'), insertIndent
      content = replaceInRange content, insertBlockStartPos, insertEndPos, body
    return content

  __processContent: (content, cbfn)->
    try 
      content = @copolymer.genericPreprocessor.process content
      content = @__removeBlockComments content if @shouldRemoveBlockComments
      content = @__removeInlineComments content if @shouldRemoveInlineComments
      {content, partialList} = @__processPartialTags content
      content = @__processInsertTags content, partialList
      return cbfn null, content
    catch err
      return cbfn err, null

  __getContent: (uri, cbfn)->
    @copolymer.getResource uri, (err, content)=>
      return cbfn err if err
      return cbfn null, content

  processAsync: (uri, cbfn)->
    @__getContent uri, (err, content)=>
      @__processContent content, (err, content)=>
        cbfn err, content



    

@CohtmlPreprocessor = CohtmlPreprocessor
  
