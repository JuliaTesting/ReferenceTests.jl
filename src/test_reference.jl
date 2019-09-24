"""
    @test_reference filename expr [by] [kw...]

Tests that the expression `expr` with reference `filename` using
equality test strategy `by`.

The pipeline of `test_reference` is:

1. preprocess `expr`
2. read and preprocess `filename`
3. compare the results using `by`
4. if test fails in an interactive session (e.g, `include(test/runtests.jl)`), an interactive dialog will be trigered.

Arguments:

* `filename::String`: _relative_ path to the file that contains the macro invocation.
* `expr`: the actual content used to compare.
* `by`: the equality test function. By default it is `isequal` if not explicitly stated.

# Types

The file-extension of `filename`, as well as the type of the
result of evaluating `expr`, determine how contents are processed and
compared. The contents is treated as:

* Images when `expr` is an image type, i.e., `AbstractArray{<:Colorant}`;
* SHA256 when `filename` endswith `*.sha256`;
* Text as a fallback.

## Images

Images are compared _approximately_ using a different `by` to ignore most encoding
and decoding errors. The default value is `Images.@test_approx_eq_sigma_eps`.

The file can be either common image files (e.g., `*.png`), which are handled by
`FileIO`, or text-coded `*.txt` files, which is handled by `ImageInTerminal`.
Text-coded image has less storage requirements and also allows to view the
reference file in a simple terminal using `cat`.

## SHA256

The hash of the `expr` and content of `filename` are compared.

!!! tip

    This is useful for a convenient low-storage way of making
    sure that the return value doesn't change for selected test
    cases.

## Fallback

Simply test the equality of `expr` and the contents of `filename` without any
preprocessing.

# Examples

```julia
# store as string using ImageInTerminal with encoding size (5,10)
@test_reference "camera.txt" testimage("cameraman") size=(5,10)

# using folders in the relative path is allowed
@test_reference "references/camera.png" testimage("cameraman")

# Images can also be stored as hash. Note however that this
# can only check for equality (no tolerance possible)
@test_reference "references/camera.sha256" testimage("cameraman")

# test images using ImageQualityIndexes.PSNR
@test_reference "references/camera.png" testimage("cameraman") by=(x,y)->psnr(x,y)>25

# test number with absolute tolerance 10
@test_reference "references/string3.txt" 1338 by=(ref, x)->isapprox(ref, x; atol=10)
```
"""
macro test_reference(reference, actual, kws...)
    dir = Base.source_dir()
    expr = :(test_reference(abspath(joinpath($dir, $(esc(reference)))), $(esc(actual))))
    for kw in kws
        (kw isa Expr && kw.head == :(=)) || error("invalid signature for @test_reference")
        k, v = kw.args
        push!(expr.args, Expr(:kw, k, esc(v)))
    end
    expr
end

function test_reference(filename::AbstractString, actual; kw...)
    test_reference(query_extended(filename), actual; kw...)
end

function query_extended(filename)
    file, ext = splitext(filename)
    # TODO: make this less hacky
    if uppercase(ext) == ".TXT"
        res = File{format"TXT"}(filename)
    elseif uppercase(ext) == ".SHA256"
        res = File{format"SHA256"}(filename)
    else
        res = query(filename)
    end
    res
end
