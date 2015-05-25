
Complete Syntax Reference
===========
This document is assumes that you are somewhat familiar with *Copolymer*. (i.e. You have completed the tutorial) This document is meant to be quite detailed and as indepth as possible.

# Preprocessor and Directives

Copolymer has some preprocessor features and directives that are processed before the Source is parsed. These are entirely compile-time concerns.

### Features

* every tab character (`\t`) is converted to two spaces `  ` in order to maintain consistency.
* every \[CR]\[LF] (`\r\n`) is converted to \[LF] (`\n`)
* every \[CR] (`\r`) is converted to \[LF] (`\n`)
* all block comments (`### Lorem ipsum dolor sit .. ###`) are removed if `Copolymer#options.shouldRemoveComments` or `Copolymer#options.shouldRemoveBlockComments` is `true`
* all one line comments (`# Lorem ipsum dolor sit .. `) are removed if `Copolymer#options.shouldRemoveComments` or `Copolymer#options.shouldRemoveLineComments` is `true`
* one \[LF] `\n` is added to the end of the file it the last character in the file is not `\n`

### @include directive

The @include directive is designed to include a file into the current file.

    @include 'myfile.copoly'
    @include as-is 'myfile.txt'

* This command is recursive (i.e. include files can also include other files). There is no practical depth limit.
* The paths are always relative.
* The indents of the content of the included file are automatically aligned to match the parent (unless the `as-is` command is in use. In that case, not even a newline will be inserted)
* Any @partial from any included file is accessible in parent (but not the other way around)

### @partial directive and @insert directive

The @partial directive can be used to create a compile time template/marco.

    @partial my-login-form
      input type="text"
      input type="password"
      input type="button"

    div.login
      @insert my-login-form

* Indentations are always altered to match the point where the partial is inserted.
* This is not a replacement of the templating features. This is a compile-time feature mostly intended to reduce the horizontal indentation level.
* Any @partial from any included file is accessible in parent (but not the other way around)

### Notes about the directives

* By default, Copolymer uses a simplified checking system to avoid detecting directives inside strings. The check is willingly kept simple (and not full-proof) to save processing time. You can enable full safe preprocessing by setting the option `Copolymer#options.safePreprocessingLevel` to `high` (`normal` by default). 
  * In the default mode, Copolymer just counts the number of quotes/backticks/doublequotes (counting escaped strings) before the current *head* of the parser when a directive is found.
  * In safe preprocessing mode, Copolymer actually parses through the entire code (including inline coffeescript) to ensure safety. This mode can take from 1ms to 10ms for large files.
  * If you personally make sure that include directives are not inside any string, you can turn off this feature altogether by setting the value to `none`. This will increase preprocessing speed a lot.



# Cohtml Syntax

Cohtml is a subset of Copolymer. Basically it is Copolymer without Polymer. When no polymer feature is used, Copolymer switches to using only Cohtml (No runtime library is required in the browser).


