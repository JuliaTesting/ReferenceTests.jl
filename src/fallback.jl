function test_reference(file::File, actual::T) where T
    path = file.filename
    dir, filename = splitdir(path)
    try
        reference = T(load(file))
        try
            @assert reference == actual # to throw error
            @test true # to increase test counter if reached
        catch # test failed
            println("Test for \"$filename\" failed.")
            println("- REFERENCE -------------------")
            show(IOContext(STDOUT, limit=true, displaysize=(20,80)), "text/plain", reference)
            dump(reference)
            println()
            println("-------------------------------")
            println("- ACTUAL ----------------------")
            show(IOContext(STDOUT, limit=true, displaysize=(20,80)), "text/plain", actual)
            dump(actual)
            println()
            println("-------------------------------")
            if isinteractive()
                print("Replace reference with actual result (path: $path)? [y/n] ")
                answer = first(readline())
                if answer == 'y'
                    save(path, actual)
                end
                error("Please run the tests again for any changes to take effect")
            else
                error("You need to run the tests interactively with 'include(\"test/runtests.jl\")' to update reference images")
            end
        end
    catch ex
        if ex isa SystemError # File doesn't exist
            println("Reference file for \"$filename\" does not exist.")
            println("- NEW CONTENT -----------------")
            show(IOContext(STDOUT, limit=true, displaysize=(20,80)), "text/plain", actual)
            println()
            println("-------------------------------")
            if isinteractive()
                print("Create reference file with above content (path: $path)? [y/n] ")
                answer = first(readline())
                if answer == 'y'
                    mkpath(dir)
                    save(path, actual)
                end
                error("Please run the tests again for any changes to take effect")
            else
                error("You need to run the tests interactively with 'include(\"test/runtests.jl\")' to create new reference images")
            end
        else
            throw(ex)
        end
    end

end
