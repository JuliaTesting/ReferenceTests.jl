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

TODO

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

Note, however, that depending on what file-format you use to
store your references, you may need to add additional
dependencies to your `test/REQUIRE` file.

## License

This code is free to use under the terms of the MIT license.
