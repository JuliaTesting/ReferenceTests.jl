
struct MissingFile <: Result
    path::String
    content::String
    inner::Fail
end

struct ReferenceTestSet{T<:AbstractTestSet} <: AbstractTestSet
    desc::AbstractString
    parent::T
end

ReferenceTestSet(desc) = ReferenceTestSet(desc, get_testset())


record(rts::ReferenceTestSet, res::Result) = record(rts.parent, res)


function record(rts::ReferenceTestSet, res::MissingFile)
    record(rts.parent, res.inner)

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


finish(::ReferenceTestSet) = nothing # Not doing anything at end of set.
