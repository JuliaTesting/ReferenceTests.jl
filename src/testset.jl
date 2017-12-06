struct MissingFile <: Result
    path::String
    content::String
    inner::Fail
end

function MissingFile(path, actual_content)
    inner =  Fail(:test, # It is actually more of an Error than a Fail
                  :(@test_reference $path [missing]  == actual), # ideally true code would be where ctual is
                  Expr(:comparison, "", :(==), actual_content), # This is triggers the normal nonequal output (or diffs if using extended testset)
                  @__LINE__) #Should be the line of the test that failed
    MissingFile(path, actual_content, inner)
end

struct MismatchedFile <: Result
    path::String
    content::String
    inner::Fail
end

function MismatchedFile(path, reference_content, actual_content)
    inner =  Fail(:test,
                  :(@test_reference $path == actual), # ideally true code would be where actual is
                  Expr(:comparison, reference_content, :(==), actual_content), # This is triggers the normal nonequal output (or diffs if using extended testset)
                  @__LINE__) #Should be the line of the test that failed
    MissingFile(path, actual_content, inner)
end

record(ts::AbstractTestSet, res::MismatchedFile) = _record(ts, res)
function _record(ts, res::MismatchedFile)
    record(ts, res.inner)
    createfile(res.path, res.content, "Replace reference, with actual result (path: $(res.path)? [y/n] ")
end


record(ts::AbstractTestSet, res::MissingFile) = _record(ts, res)
function _record(ts, res::MissingFile)
    record(ts, res.inner)
    createfile(res.path, res.content, "Create reference file with above content (path: $(res.path)? [y/n] ")
end

function createfile(path, content, message)
    dir = dirname(path)
    if isinteractive()
        print(message)
        answer = first(readline())
        if answer == 'y'
            mkpath(dir)
            write(path, content)
            warn("Please run the tests again for any changes to take effect")
        end
    end
end


@require TestSetExtensions begin
    # For compatibility, as otherwise this gives an ambiguity error
    record(ts::TestSetExtensions.ExtendedTestSet, res::MissingFile) = _record(ts, res)
    record(ts::TestSetExtensions.ExtendedTestSet, res::MismatchedFile) = _record(ts, res)
end
