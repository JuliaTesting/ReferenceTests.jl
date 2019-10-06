"""
    default_rendermode(::DataFormat, actual)

Infer the most appropriate render mode according to type of reference file and `actual`.
"""
default_rendermode(::Type{<:DataFormat}, ::Any) = BeforeAfterLimited()
default_rendermode(::Type{<:DataFormat}, ::AbstractString) = Diff()
default_rendermode(::Type{<:DataFormat}, ::AbstractArray{<:Colorant}) = BeforeAfterImage()

# plain TXTs
default_rendermode(::Type{DataFormat{:TXT}}, ::Any) = Diff()
default_rendermode(::Type{DataFormat{:TXT}}, ::AbstractString) = Diff()
default_rendermode(::Type{DataFormat{:TXT}}, ::Number) = BeforeAfterFull()
default_rendermode(::Type{DataFormat{:TXT}}, ::AbstractArray{<:Colorant}) = BeforeAfterFull()

# SHA256
default_rendermode(::Type{DataFormat{:SHA256}}, ::Any) = BeforeAfterFull()
default_rendermode(::Type{DataFormat{:SHA256}}, ::AbstractString) = BeforeAfterFull()
default_rendermode(::Type{DataFormat{:SHA256}}, ::AbstractArray{<:Colorant}) = BeforeAfterFull()
