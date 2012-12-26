pry-debugger
============

_Fast execution control in Pry_

Adds **step**, **next**, **finish**, and **continue** commands and
**breakpoints** to [Pry][pry] using [debugger][debugger].

To use, invoke pry normally. No need to start your script or app differently.

```ruby
def some_method
  binding.pry          # Execution will stop here.
  puts 'Hello World'   # Run 'step' or 'next' in the console to move here.
end
```

For a complete debugging environment, add
[pry-stack_explorer][pry-stack_explorer] for call-stack frame navigation.


## Execution Commands

**step:** Step execution into the next line or method. Takes an optional numeric
argument to step multiple times.

**next:** Step over to the next line within the same frame. Also takes an
optional numeric argument to step multiple lines.

**finish:** Execute until current stack frame returns.

**continue:** Continue program execution and end the Pry session.


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

**pry-debugger** is not yet thread-safe, so only use in single-threaded
environments.

Only supports MRI 1.9.2 and 1.9.3. For a pure ruby approach not reliant on
[debugger][debugger], check out [pry-nav][pry-nav]. Note: *pry-nav* and
*pry-debugger* cannot be loaded together.


## Remote debugging

Support for [pry-remote][pry-remote] (>= 0.1.4) is also included. Requires
explicity requiring *pry-debugger*, not just relying on pry's plugin loader.

Want to debug a Rails app running inside [foreman][foreman]? Add to your
Gemfile:

```ruby
gem 'pry'
gem 'pry-remote'
gem 'pry-stack_explorer'
gem 'pry-debugger'
```

Then add `binding.remote_pry` where you want to pause:

```ruby
class UsersController < ApplicationController
  def index
    binding.remote_pry
    ...
  end
end
```

Load a page that triggers the code. Connect to the session:

```
$ bundle exec pry-remote
```

Using Pry with Rails? Check out [Jazz Hands][jazz_hands].


## Tips

Stepping through code often? Add the following shortcuts to `~/.pryrc`:

```ruby
Pry.commands.alias_command 'c', 'continue'
Pry.commands.alias_command 's', 'step'
Pry.commands.alias_command 'n', 'next'
Pry.commands.alias_command 'f', 'finish'
```


## Contributors

* Gopal Patel (@nixme)
* John Mair (@banister)
* Nicolas Viennot (@nviennot)
* Benjamin R. Haskell (@benizi)
* Joshua Hou (@jshou)
* ...and others who helped with [pry-nav][pry-nav]

Patches and bug reports are welcome. Just send a [pull request][pullrequests] or
file an [issue][issues]. [Project changelog][changelog].



[pry]:                http://pry.github.com
[debugger]:           https://github.com/cldwalker/debugger
[pry-stack_explorer]: https://github.com/pry/pry-stack_explorer
[pry-nav]:            https://github.com/nixme/pry-nav
[pry-remote]:         https://github.com/Mon-Ouie/pry-remote
[foreman]:            https://github.com/ddollar/foreman
[jazz_hands]:         https://github.com/nixme/jazz_hands
[pullrequests]:       https://github.com/nixme/pry-debugger/pulls
[issues]:             https://github.com/nixme/pry-debugger/issues
[changelog]:          https://github.com/nixme/pry-debugger/blob/master/CHANGELOG.md
