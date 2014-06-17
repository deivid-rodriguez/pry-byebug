pry-byebug [![Gem Version][1]][2] [![Build Status][3]][4]
============

_Fast execution control in Pry_

Adds **step**, **next**, **finish** and **continue** commands and
**breakpoints** to [Pry][pry] using [byebug][byebug].

To use, invoke pry normally. No need to start your script or app differently.

```ruby
def some_method
  binding.pry          # Execution will stop here.
  puts 'Hello World'   # Run 'step' or 'next' in the console to move here.
end
```

For a complete debugging environment, add
[pry-stack_explorer][pry-stack_explorer] for call-stack frame navigation.


## Installation

Drop

```ruby
gem 'pry-byebug'
```

in your Gemfile and run

    bundle install

_Make sure you include the gem globally or inside the `:test` group if you plan
to use it to debug your tests!_


## Execution Commands

**step:** Step execution into the next line or method. Takes an optional numeric
argument to step multiple times. Aliased to `s`

**next:** Step over to the next line within the same frame. Also takes an
optional numeric argument to step multiple lines. Aliased to `n`

**finish:** Execute until current stack frame returns. Aliased to `f`

**continue:** Continue program execution and end the Pry session. Aliased to `c`


## Breakpoints

You can set and adjust breakpoints directly from a Pry session using the
following commands:

**break:** Set a new breakpoint from a line number in the current file, a file
and line number, or a method. Pass an optional expression to create a
conditional breakpoint. Edit existing breakpoints via various flags.

Examples:

```
break SomeClass#run            Break at the start of `SomeClass#run`.
break Foo#bar if baz?          Break at `Foo#bar` only if `baz?`.
break app/models/user.rb:15    Break at line 15 in user.rb.
break 14                       Break at line 14 in the current file.

break --condition 4 x > 2      Change condition on breakpoint #4 to 'x > 2'.
break --condition 3            Remove the condition on breakpoint #3.

break --delete 5               Delete breakpoint #5.
break --disable-all            Disable all breakpoints.

break                          List all breakpoints. (Same as `breakpoints`)
break --show 2                 Show details about breakpoint #2.
```

Type `break --help` from a Pry session to see all available options.


**breakpoints**: List all defined breakpoints. Pass `-v` or `--verbose` to see
the source code around each breakpoint.


## Caveats

Only supports MRI 2.0.0 or newer. For MRI 1.9.3 or older, use
[pry-debugger][pry-debugger]


## Contributors

* Tee Parham (@teeparham)
* Gopal Patel (@nixme)
* John Mair (@banister)
* Nicolas Viennot (@nviennot)
* Benjamin R. Haskell (@benizi)
* Joshua Hou (@jshou)
* ...and others who helped with [pry-nav][pry-nav]

Patches and bug reports are welcome. Just send a [pull request][pullrequests] or
file an [issue][issues]. [Project changelog][changelog].

[pry]:                http://pry.github.com
[byebug]:             https://github.com/deivid-rodriguez/byebug
[pry-debugger]:       https://github.com/nixme/pry-debugger
[pry-stack_explorer]: https://github.com/pry/pry-stack_explorer
[pullrequests]:       https://github.com/deivid-rodriguez/pry-byebug/pulls
[issues]:             https://github.com/deivid-rodriguez/pry-byebug/issues
[changelog]:          https://github.com/deivid-rodriguez/pry-byebug/blob/master/CHANGELOG.md
[pry-nav]:            https://github.com/nixme/pry-nav
[1]: https://badge.fury.io/rb/pry-byebug.png
[2]: http://badge.fury.io/rb/pry-byebug
[3]: https://secure.travis-ci.org/deivid-rodriguez/pry-byebug.png
[4]: http://travis-ci.org/deivid-rodriguez/pry-byebug
