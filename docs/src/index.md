# ReferenceTests.jl Documentation

ReferenceTests.jl is a Julia package that adds a couple of
additional macros to your testing toolbox. In particular, it
focuses on functionality for testing values against reference
files, which in turn the package can help create and update if
need be. ReferenceTests.jl is build on top of
[`FileIO.jl`](https://github.com/JuliaIO/FileIO.jl) and designed
to be used alongside `Base.Test`.

## Contents

```@contents
Pages = ["index.md"]
```

## Index

```@index
Pages = ["index.md"]
```

## Public Interface

```@docs
@withcolor
@io2str
@test_reference
psnr_equality
```
