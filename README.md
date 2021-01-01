# Copolymer
A declarative language that transpiles to HTML5 and CoffeeScript. Purpose made to work with [Google's Polymer 0.x](https://www.polymer-project.org/). However, the Polymer project has shifted direction a lot from the original and so, this project is no longer active.


## Quick example
```coffee
import "../polymer/polymer.html"
import "../polymer/paper-checkbox"
import "../polymer/paper-button"
import "../polymer/paper-input"

define todo-app todoList="[]"

  h1 | Todo App
  
  div$todoList vertical layout
    for todo, index in todoList
      div.todoEntry horizontal layout
        paper-checkbox checked="{{todo.isDone}}"
        div | {{todo.text}}
        paper-button %index="{{index}}" *click="deleteClicked" label="Delete"
        
  div horizontal layout
    paper-input label="Type new entry here" value="{{newEntryText}}"
    paper-button *click="addClicked" label="Add"
    
script type="text/coffeescript" `
  Copolymer todo-app, {
    deleteClicked: (e)->
      @todoList.splice (parseInt (e.target.getAttribute 'data-index'), 10), 1
      
    addClicked: (e)->
      @todoList.push {isDone: false, text: @newEntryText}
  }
`
```

## Notes

It was written on the now almost-retired language [CoffeeScript](https://coffeescript.org/). You will need the CoffeeScript compiler to run the code.