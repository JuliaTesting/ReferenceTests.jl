"""
    @test_reference filename expr [by] [kw...]

Tests that the expression `expr` with reference `filename` using
equality test strategy `by`.

The pipeline of `test_reference` is:

1. preprocess `expr`
2. read and preprocess `filename` via FileIO.jl
3. compare the results using `by`
4. if test fails in an interactive session (e.g, `include(test/runtests.jl)`), an interactive dialog will be trigered.

Arguments:

* `filename::String`: _relative_ path to the file that contains the macro invocation.
* `expr`: the actual content used to compare.
* `by`: the equality test function. By default it is `isequal` if not explicitly stated.
* `format`: Force reading the file using a specific format

# Types

The file-extension of `filename`, as well as the type of the
result of evaluating `expr`, determine how contents are processed and
compared. The contents is treated as:

* Images when `expr` is an image type, i.e., `AbstractArray{<:Colorant}`;
* SHA256 when `filename` endswith `*.sha256`;
* Any file-type which FileIO.jl handles and with the proper backend loaded;
* Text as a fallback.

## Any FileIO.jl handled filetype

Any file-types which can be read by [FileIO.jl](https://github.com/JuliaIO/FileIO.jl) can be used.
Note that most Julia values can be stored using packages such as, e.g.,
[BSON.jl](https://github.com/JuliaIO/BSON.jl) or [JLD](https://github.com/JuliaIO/JLD.jl) and can thus be used in reference-tests.

## Images

Images are compared _approximately_ using a different `by` to ignore most encoding
and decoding errors. The default function is generated from [`psnr_equality`](@ref).

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

Simply test the equality of `expr` and the contents of `filename` without any preprocessing.
Note that reading `filename` will return a `String`.

# Examples

```julia
# compare text-file against string representation of a value
@test_reference "stringtest1.txt" collect(1:20)

# test number with absolute tolerance 10
@test_reference "references/string3.txt" 1338 by=(ref, x)->isapprox(ref, x; atol=10)

# store a floating point array ar in BSON-file and compare it back.
# Note that a Dict is needed and the custom comparison function.
using BSON
comp(d1, d2) = keys(d1)==keys(d2) &&
    all([ v1≈v2 for (v1,v2) in zip(values(d1), values(d2))])
@test_reference "reftest-files/X.bson" Dict(:ar=>[1, pi, 4.5]) by=comp

# store as string using ImageInTerminal with encoding size (5,10)
using TestImages
@test_reference "camera.txt" testimage("cameraman") size=(5,10)

# using folders in the relative path is allowed
@test_reference "references/camera.png" testimage("cameraman")

# Images can also be stored as hash. Note however that this
# can only check for equality (no tolerance possible)
@test_reference "references/camera.sha256" testimage("cameraman")

# test images with custom Peak Signal-to-Noise Ratio (psnr) threshold
@test_reference "references/camera.png" testimage("cameraman") by=psnr_equality(20)
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

for f in [:test_reference, :match_reference, :_do_reference_matching]
    @eval function $f(
        filename::AbstractString, raw_actual;
        by = nothing, render = nothing, format = nothing, kw...)
        format isa AbstractString && (format = FileIO.DataFormat{Symbol(format)})
        reference_file = format === nothing ? query_extended(filename) : File{format}(filename)
        $f(reference_file, raw_actual, by, render; kw...)
    end
end

function _do_reference_matching(
    reference_file::File{F},
    raw_actual::T,
    equiv=nothing,
    rendermode=nothing;
    kw...) where {F <: DataFormat, T}

    reference_path = reference_file.filename
    reference_dir, reference_filename = splitdir(reference_path)

    actual = _convert(F, raw_actual; kw...)

    # infer the default rendermode here
    # since `nothing` is always passed to this method from
    # test_reference(filename::AbstractString, raw_actual; kw...)
    if rendermode === nothing
        rendermode = default_rendermode(F, actual)
    end

    if !isfile(reference_path)  # when reference file doesn't exists
        mkpath(reference_dir)
        savefile(reference_file, actual)
        @info(
            "Reference file for \"$reference_filename\" did not exist. It has been created",
            new_reference=reference_path,
        )

        # TODO: move encoding out from render
        render(rendermode, actual)

        @info("Please run the tests again for any changes to take effect")
        return nothing # skip current test case
    end

    # file exists
    reference = loadfile(typeof(actual), reference_file)

    if equiv === nothing
        # generally, `reference` and `actual` are of the same type after preprocessing
        equiv = default_equality(reference, actual)
    end

    match_result = equiv(reference, actual)

    all_info = (;
        reference_path,
        reference_dir,
        reference_filename,
    )
end

function match_reference(
    reference_file::File{F},
    raw_actual::T,
    equiv=nothing,
    rendermode=nothing;
    kw...) where {F <: DataFormat, T}
    all_info = _do_reference_matching(
        reference_file,
        raw_actual::T,
        equiv,
        rendermode;
        kw...,
    )
    match_result = all_info.match_result
    return match_result
end

function test_reference(
    reference_file::File{F},
    raw_actual::T,
    equiv=nothing,
    rendermode=nothing;
    kw...) where {F <: DataFormat, T}

    all_info = match_reference(
        reference_file,
        raw_actual,
        equiv,
        rendermode;
        kw...,
    )

    reference_path     = all_info.reference_path
    reference_dir      = all_info.reference_dir
    reference_filename = all_info.reference_filename
    actual             = all_info.actual
    match_result       = all_info.match_result

    if match_result
        @test true # to increase test counter if reached
    else  # When test fails
        # Saving actual file so user can look at it
        actual_path = joinpath(mismatch_staging_dir(), reference_filename)
        actual_file = typeof(reference_file)(actual_path)
        savefile(actual_file, actual)

        # Report to user.
        @info(
            "Reference Test for \"$reference_filename\" failed.",
            reference=reference_path,
            actual=actual_path,
        )
        render(rendermode, reference, actual)

        if !isinteractive() && !force_update()
            error("""
            To update the reference images either run the tests interactively with 'include(\"test/runtests.jl\")',
            or to force-update all failing reference images set the environment variable `JULIA_REFERENCETESTS_UPDATE`
            to "true" and re-run the tests via Pkg.
            """)
        end

        if force_update() || input_bool("Replace reference with actual result?")
            mv(actual_path, reference_path; force=true)  # overwrite old file it
            @info("Please run the tests again for any changes to take effect")
        else
            @test false
        end
    end
end

force_update() = tryparse(Bool, get(ENV, "JULIA_REFERENCETESTS_UPDATE", "false")) === true

"""
    mismatch_staging_dir()

The directory where we store files that don't match so user can look at them.
If the enviroment variable `REFERENCE_TESTS_STAGING_PATH` is set then we will use that directory.
If not a temporary directory will be created. Note that this temporary directory will not be
deleted when julia exists. Since in that case the files would may be deleted before you can
look at them. You should use your operating systems standard mechanisms to clean up excess
temporary directories.
"""
function mismatch_staging_dir()
    return mkpath(expanduser(get(ENV,
        "REFERENCE_TESTS_STAGING_PATH",
        VERSION >= v"1.3" ? mktempdir(; cleanup=false) : mktempdir()
    )))
end
