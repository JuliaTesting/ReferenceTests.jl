"""
    @test_reference filename ex [kw...]

Tests that the expression `ex` evaluates to the same result as
stored in the given reference file, which is denoted by the
string `filename`. Executing the code in an interactive julia
session will trigger an interactive dialog if results don't
match. This dialog allows the user to create and/or update the
reference files.

The given string `filename` is assumed to be the relative path to
the file that contains the macro invokation. This likely means
that the path `filename` is relative to the `test/` folder of
your package.

The file-extention of `filename`, as well as the type of the
result of evaluating `ex`, determine how the actual value is
compared to the reference value. The default implementation will
do a simple equality check with the result of `FileIO.load`. This
means that it is the user's responsibility to have the required
IO package installed.

Colorant arrays (i.e.) receive special treatment. If the
extension of `filename` is `txt` then the package
`ImageInTerminal` will be used to create a string based cure
approximation of the image. This will have low storage
requirements and also allows to view the reference file in a
simple terminal using `cat`.

Another special file extension is `sha256` which will cause the
hash of the result of `ex` to be stored and compared as plain
text. This is useful for a convenient low-storage way of making
sure that the return value doesn't change for selected test
cases.

# Examples

```julia
# store as string using ImageInTerminal with encoding size (5,10)
@test_reference "camera.txt" testimage("cameraman") size=(5,10)

# using folders in the relative path is allowed
@test_reference "references/camera.png" testimage("cameraman")

# Images can also be stored as hash. Note however that this
# can only check for equality (no tolerance possible)
@test_reference "references/camera.sha256" testimage("cameraman")
```
"""
macro test_reference(reference, actual, kws...)
    expr = :(test_reference(abspath(joinpath(Base.@__DIR__, $(esc(reference)))), $(esc(actual))))
    for kw in kws
        (kw isa Expr && kw.head == :(=)) || error("invalid signature for @test_reference")
        push!(expr.args, Expr(:kw, kw.args...))
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
        File{format"TXT"}(filename)
    elseif uppercase(ext) == ".SHA256"
        File{format"SHA256"}(filename)
    else
        query(filename)
    end
end

# --------------------------------------------------------------------
# Images

function test_reference(file::File, actual::AbstractArray{<:Colorant}; sigma=ones(length(indices(actual))), eps=0.01)
    path = file.filename
    dir, filename = splitdir(path)
    try
        reference = load(file)
        try
            @assert Images.@test_approx_eq_sigma_eps(reference, actual, sigma, eps) == nothing # to throw error
            @test true # to increase test counter if reached
        catch # test failed
            str_ref = @withcolor ImageInTerminal.encodeimg(ImageInTerminal.SmallBlocks(), ImageInTerminal.TermColor256(), reference, 20, 40)[1]
            str_act = @withcolor ImageInTerminal.encodeimg(ImageInTerminal.SmallBlocks(), ImageInTerminal.TermColor256(), actual, 20, 40)[1]
            println("Test for \"$filename\" failed.")
            println("- REFERENCE -------------------")
            println("eltype: ", eltype(reference))
            println("size: ", map(length, indices(reference)))
            println("thumbnail:")
            println.(str_ref)
            println("-------------------------------")
            println("- ACTUAL ----------------------")
            println("eltype: ", eltype(actual))
            println("size: ", map(length, indices(actual)))
            println("thumbnail:")
            println.(str_act)
            println("-------------------------------")
            if isinteractive()
                print("Replace reference with actual result (path: $path)? [y/n] ")
                answer = first(readline())
                if answer == 'y'
                    save(file, actual)
                end
            else
                error("You need to run the tests interactively with 'include(\"test/runtests.jl\")' to update reference images")
            end
        end
    catch ex
        if ex isa ErrorException && startswith(ex.msg, "unable to open") # File doesn't exist
            str_act = @withcolor ImageInTerminal.encodeimg(ImageInTerminal.SmallBlocks(), ImageInTerminal.TermColor256(), actual, 20, 40)[1]
            println("Reference file for \"$filename\" does not exist.")
            println("- NEW CONTENT ----------- -----")
            println("eltype: ", eltype(actual))
            println("size: ", map(length, indices(actual)))
            println("thumbnail:")
            println.(str_act)
            println("-------------------------------")
            if isinteractive()
                print("Create reference file with above content (path: $path)? [y/n] ")
                answer = first(readline())
                if answer == 'y'
                    mkpath(dir)
                    save(file, actual)
                end
            else
                error("You need to run the tests interactively with 'include(\"test/runtests.jl\")' to create new reference images")
            end
        else
            throw(ex)
        end
    end
end
