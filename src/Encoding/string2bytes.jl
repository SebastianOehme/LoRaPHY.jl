# string2bytes.jl
"""
    string_to_bytes(msg::String) -> Vector{UInt8}

Converts a given string `msg` into a vector of bytes (UInt8).
"""
function string_to_bytes(msg::String)::Vector{UInt8}
    return [UInt8(c) for c in msg]
end
