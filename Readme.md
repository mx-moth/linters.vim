linters.vim - Check your code for lint as you write
===================================================

Linting tools like JSHint and pylint are excellent, but only if you run them
constantly. You can run them manually when you are finished coding, but then you
have to go back and edit all of your files again. You can run them as part of
git hooks, or as part of a make run, but even that is ages after you have
finished writing that section of code. The best time to run a linter is all of
the time.

`linters.vim` runs linters over your code every time you save your file. Any
errors found are displayed instantly in the quickfix window. Writing clean code
becomes necessary - otherwise your editor will complain at you!

Installing
----------

The easiest way to install is through [pathogen.vim][pathogen]. Install
pathogen, and then:

    git clone https://bitbucket.org/tim_heap/linters.vim ~/.vim/bundle/linters

Otherwise, copy the `plugin/linters.vim` file to your `~/.vim/plugin/`
directory. It only needs the one file.

Using
-----

A number of languages are already supported (see 
Supported languages below). For any of these languages,
simply write your code as normal. As soon as you save your changes, the linter
is run. Any errors or warnings are displayed in the quickfix window.

To jump to the first error, press `:cc` in normal mode.  You can navigate
between errors using `[q` and `]q`. Save your changes to lint the file again.

Supported languages
-------------------

The following languages are currently supported:

* JavaScript, using [JSHint][]
* LESS, using the [LESS CSS compiler][]
* Python, using either [pylint][] or [pyflakes][]
* Haskell, using [hlint][]

### Adding new languages

Adding support for new languages is easy.
There are two ways: adding the definition to your ~/.vimrc file,
or adding it to this plugin itself.
In either method, you will need three things:

* The vim filetype of the language.
  Press `:set filetype` to see what Vim thinks a language is called.

* The command to run to invoke the linter program.
  This should have two placeholders, the first one for the input file to lint,
  and the second one for the output file containing any errors.
  Shell piping and redirection is allowed.
  The [JSHint][] linter command follows, for reference:

      jshint %s > %s

* A list of `errorformat` style strings that your linter will print.
  This takes after the Vim `errorformat` setting,
  but instead of having a list of formats separated with spaces,
  this is a Vimscript list.
  See the Vim help on `errorformat` for the syntax of this line,
  just ignore the section on escaping.
  For example, the error format list for pylint is:

      [
      \    "%t:  %l,%c:%m",
      \    "%t: %l,%c:%m",
      \    "%t:%l,%c:%m",
      \]

You will likely want to wrap any definition in a check to see if the linter
exists - not everyone will have every linter. For example:

    if executable("jshint")
        " Add the linter definition here
    endif

### Adding via ~/.vimrc

To add linters in your ~/.vimrc, add them to the `g:linters_extra` array:

    let g:linters_extra = []

    if executable('jshint')
        let g:linters_extra += [
        \   ['javascript', 'jshint %s > %s', ["%f: line %l, col %c, %m"]],
        \]
    endif

### Adding new definitions to linters.vim

Pull requests for new languages and linters are welcome!
If you would like to contribute a new definition,
Edit `plugin/linters.vim` and add your linter definition there.
The syntax is:

    if executable('jshint')
        call s:DefineLinter('javascript', 'jshint %s > %s',
            ["%f: line %l, col %c, %m"])
    endif

Configuration
-------------

**`g:linters_automatic_on_save`** is a global flag for enabling/disabling the
automatic running of the linters plugin on every write. Set this to 0 if you do
not want to lint on every write. Linting can be done manually by running
`call linters#run()`

**`g:linters_disabled_filetypes`** can contain a list of filetypes that
automatic linting should be disabled for. If you want to stop linting just one
filetype, but continue linting others, add the filetype to this list.

    let g:linters_disabled_filetypes = ['javascript']

**`g:linters_extra`** can contain a list of extra linter definitions, to append
or override to the existing set. It should be a list of triples of the format:

    let g:linters_extra = [
    \    ['filetype', 'command', ['error', 'format', 'strings']]
    \]

See the section above on [Adding new languages](#adding-new-languages) for more
information

Todo
----

* Work out if there is a better to run the linter than hooking in to
  `BufWritePost` on every file open. This seems inefficient.

* Add more language support - pull requests welcome!

License
-------

This plugin is released in to the public domain. Do what you will with it

[pathogen]: http://github.com/tpope/pathogen.vim "tpope/Pathogen.vim"
[JSHint]: https://github.com/jshint/node-jshint "jshint/node-jshint"
[LESS CSS compiler]: https://github.com/cloudhead/less.js "cloudhead/less.js"
[pylint]: http://pypi.python.org/pypi/pylint "pypi/pylint"
[pyflakes]: http://pypi.python.org/pypi/pyflakes/0.5.0 "pypi/pyflakes"
[hlint]: http://community.haskell.org/~ndm/hlint/ "HLint"
