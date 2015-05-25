

# end exclusive
@replaceInRange = (s, start, end, substitute)->
    return s.substring(0, start) + substitute + s.substring(end)

@rewindTillMatches = (content, pos, array)->
  while content.charAt(pos-1) in array
    pos -= 1
  return pos

@countCharacterBeforePosition = countCharacterBeforePosition = (content, pos, character)->
  localPos = 0
  count = 0
  while (localPos = content.indexOf character, localPos) > -1
    break unless localPos < pos
    count += 1
    localPos += 1
  return count

@countCharacterFromListBeforePosition = (content, pos, array)->
  count = 0
  for character in array
    count += countCharacterBeforePosition content, pos, character
  return count

@highlight = (text)->
  text = text.replace(/\n/g,'↲\n').replace(/\r/g,'[CR]').replace(/\t/g,'↦')
  "|#{text}|"