function test_reference_file(filename::AbstractString, actual; kw...)
    test_reference_file(extended_query(filename), actual; kw...)
end

function test_reference_file(file::File, actual::AbstractArray{<:Colorant}; sigma=ones(length(indices(actual))), eps=0.01)
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

function test_reference_file(file::File{format"TXT"}, actual::AbstractArray{<:Colorant}; size = (20,40))
    str = @withcolor ImageInTerminal.encodeimg(ImageInTerminal.SmallBlocks(), ImageInTerminal.TermColor256(), actual, size...)[1]
    test_reference_file(file, str)
end

function test_reference_file(file::File{format"TXT"}, actual::AbstractString)
    test_reference_file(file, [actual])
end

function test_reference_file(file::File{format"TXT"}, actual::AbstractArray{<:AbstractString})
    path = file.filename
    dir, filename = splitdir(path)
    try
        reference = replace.(readlines(path), ["\n"], [""])
        try
            @assert reference == actual # to throw error
            @test true # to increase test counter if reached
        catch # test failed
            println("Test for \"$filename\" failed.")
            println("- REFERENCE -------------------")
            println.(reference)
            println("-------------------------------")
            println("- ACTUAL ----------------------")
            println.(actual)
            println("-------------------------------")
            if isinteractive()
                print("Replace reference with actual result (path: $path)? [y/n] ")
                answer = first(readline())
                if answer == 'y'
                    write(path, join(actual, "\n"))
                end
            else
                error("You need to run the tests interactively with 'include(\"test/runtests.jl\")' to update reference images")
            end
        end
    catch ex
        if ex isa SystemError # File doesn't exist
            println("Reference file for \"$filename\" does not exist.")
            println("- NEW CONTENT -----------------")
            println.(actual)
            println("-------------------------------")
            if isinteractive()
                print("Create reference file with above content (path: $path)? [y/n] ")
                answer = first(readline())
                if answer == 'y'
                    mkpath(dir)
                    write(path, join(actual, "\n"))
                end
            else
                error("You need to run the tests interactively with 'include(\"test/runtests.jl\")' to create new reference images")
            end
        else
            throw(ex)
        end
    end
end
