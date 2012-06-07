pry-debugger
============

_Fast execution control in Pry_

Adds **step**, **next**, and **continue** commands to [Pry][pry] using
[debugger][debugger].

To use, invoke pry normally:

```ruby
def some_method
  binding.pry          # Execution will stop here.
  puts 'Hello World'   # Run 'step' or 'next' in the console to move here.
end
```

**pry-debugger** is not yet thread-safe, so only use in single-threaded
environments.

Only supports MRI 1.9.2 and 1.9.3. For a pure-ruby approach not reliant on
[debugger][debugger], check out [pry-nav][pry-nav]. Note: *pry-nav* and
*pry-debugger* cannot be loaded together.

Stepping through code often? Add the following shortcuts to `~/.pryrc`:

```ruby
Pry.commands.alias_command 'c', 'continue'
Pry.commands.alias_command 's', 'step'
Pry.commands.alias_command 'n', 'next'
```

## Contributions

Patches and bug reports are welcome. Just send a [pull request][pullrequests] or
file an [issue][issues]. [Project changelog][changelog].


[pry]:            http://pry.github.com
[debugger]:       https://github.com/cldwalker/debugger
[pry-nav]:        https://github.com/nixme/pry-nav
[pullrequests]:   https://github.com/nixme/pry-debugger/pulls
[issues]:         https://github.com/nixme/pry-debugger/issues
[changelog]:      https://github.com/nixme/pry-debugger/blob/master/CHANGELOG.md
