# ReferenceTests

_ReferenceTests.jl is a Julia package that adds a couple of
additional macros to your testing toolbox. In particular, it
focuses on functionality for testing against reference files,
which in turn the package can help create and update if need be.
ReferenceTests.jl is build on top of
[`FileIO.jl`](https://github.com/JuliaIO/FileIO.jl) and designed
to be used alongside `Base.Test`._

| **Package Status** | **Package Evaluator** | **Build Status**  |
|:------------------:|:---------------------:|:-----------------:|
| [![License](http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat)](LICENSE.md) [![Documentation](https://img.shields.io/badge/docs-latest-blue.svg)](https://evizero.github.io/ReferenceTests.jl/latest) | [![Pkg Eval 0.6](http://pkg.julialang.org/badges/ReferenceTests_0.6.svg)](http://pkg.julialang.org/?pkg=ReferenceTests) [![Pkg Eval 0.7](http://pkg.julialang.org/badges/ReferenceTests_0.7.svg)](http://pkg.julialang.org/?pkg=ReferenceTests) | [![Travis](https://travis-ci.org/Evizero/ReferenceTests.jl.svg?branch=master)](https://travis-ci.org/Evizero/ReferenceTests.jl) [![AppVeyor](https://ci.appveyor.com/api/projects/status/fle0090403pdgnxi?svg=true)](https://ci.appveyor.com/project/Evizero/referencetests-jl) [![Coverage Status](https://coveralls.io/repos/Evizero/ReferenceTests.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/Evizero/ReferenceTests.jl?branch=master) |

## Introduction

It is very common for Julia packages to test the functionality of
their exported functions using known input to output
combinations. We will refer to such kind of tests as *reference
tests*. In most cases these will be quite simple and look
something along the line of `@test f(x) == y`, where `f` is a
function of the package and `x` is some interesting input value
for which the desired output `y` is known.

For testing the output of more complex functions for which the
expected output is more complicated (e.g. anything image
processing related), using `@test` can be a little cumbersome to
use. To that end this package provides the `@test_reference`
macro, which expects a filename (relative to the file that
invokes the macro) and an expression.

```julia
@test_reference "stringtest1.txt" string(collect(1:20))
```

If you put this code into your `test/runtests.jl` and execute the
file in an interactive julia session, then it will trigger an
interactive dialog if the results don't match. This dialog allows
the user to create and/or update the reference files.

The given file `stringtest1.txt` is assumed to be the relative
path to the file that contains the macro invokation. This likely
means that the path is relative to the `test/` folder of your
package.

The file-extention of (here `txt`), as well as the type of the
result of evaluating (here `String`), determine how the actual
value is compared to the reference value. The default
implementation will do a simple equality check with the result of
`FileIO.load`. This means that it is the user's responsibility to
have the required IO package installed.

Colorant arrays (i.e.) receive special treatment. If the
extension of the filename is `txt` then the package
[`ImageInTerminal.jl`](https://github.com/JuliaImages/ImageInTerminal.jl)
will be used to create a string based cure approximation of the
image. This will have low storage requirements and also allows to
view the reference file in a simple terminal using `cat`.

Another special file extension is `sha256` which will cause the
hash of the result of the given expression to be stored and
compared as plain text. This is useful for a convenient
low-storage way of making sure that the return value doesn't
change for selected test cases.

## Documentation

Check out the **[latest documentation](https://evizero.github.io/ReferenceTests.jl/latest)**

Additionally, you can make use of Julia's native docsystem.
The following example shows how to get additional information
on `@test_reference` within Julia's REPL:

```julia
?@test_reference
```

## Installation

This package is registered in `METADATA.jl` and can be installed
as usual.

```julia
Pkg.add("ReferenceTests")
```

If you intend to use it for testing on CI, make sure to add the
package name `ReferenceTests` to your `test/REQUIRE` file.
Further note, that depending on what file-format you use to store
your references, you may need to add additional dependencies to
your `test/REQUIRE` file.

## License

This code is free to use under the terms of the MIT license.
