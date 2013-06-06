## 1.1.0 (2013-06-06)

* Adds a test suite (thanks @teeparham!)
* Uses byebug ~> 1.4.0
* Uses s, n, f and c aliases by default (thanks @jgakos!)


## 1.0.0, 1.0.1 (2013-05-07)

* Forked from [pry-debugger](https://github.com/nixme/pry-debugger) to support
  byebug
* Dropped pry-remote support


## 0.2.2 (2013-03-07)

* Relaxed [byebug][byebug] dependency.


## 0.2.1 (2012-12-26)

* Support breakpoints on methods defined in the pry console. (@banister)
* Fix support for specifying breakpoints by *file:line_number*. (@nviennot)
* Validate breakpoint conditionals are real Ruby expressions.
* Support for debugger ~> 1.2.0. (@jshou)
* Safer `alias_method_chain`-style patching of `Pry.start` and
  `PryRemote::Server#teardown`. (@benizi)


## 0.2.0 (2012-06-11)

* Breakpoints
* **finish** command
* Internal cleanup and bug fixes


## 0.1.0 (2012-06-07)

* First release. **step**, **next**, and **continue** commands.
  [pry-remote 0.1.4][pry-remote] support.
