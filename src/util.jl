
function parse_intrange(text::String)::UnitRange{Int}
    m = match(r"(\d+):(\d+)", text)
    if isnothing(m)
        throw(ArgumentError("could not parse '$(text)' as an Int range"))
    end

    return parse(Int, m[1]):parse(Int, m[2])
end
