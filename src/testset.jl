struct MissingFile <: Result
    path::String
    content::String
    inner::Fail
end



record(ts::AbstractTestSet, res::MissingFile) = _record(ts, res)

function _record(ts, res::MissingFile)
    record(ts, res.inner)

    dir,filename = splitdir(res.path)
    println("Reference file for \"$filename\" does not exist.")
    if isinteractive()
        print("Create reference file with above content (path: $(res.path)? [y/n] ")
        answer = first(readline())
        if answer == 'y'
            mkpath(dir)
            write(path, join(actual, "\n"))
            warn("Please run the tests again for any changes to take effect")
        end
    end
end


@require TestSetExtensions begin
    # For compatibility, as otherwise this gives an ambiguity error
    record(ts::TestSetExtensions.ExtendedTestSet, res::MissingFile) = _record(ts, res)
end
