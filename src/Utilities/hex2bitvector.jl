"""
    hex_to_bitvector(hex_values::Vector{UInt8}) -> BitVector

Converts a vector of hexadecimal (UInt8) values into a `BitVector` representing the corresponding binary bits.

# Arguments
- `hex_values`: A vector of `UInt8` values to convert to a `BitVector`.

# Returns
- A `BitVector` where each byte in `hex_values` is expanded into its 8-bit binary representation.

# Example
```julia
hex_values = [0xA3, 0x1F]
bits = hex_to_bitvector(hex_values)
println(bits)  # Output: BitVector[1, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1]
"""


function hex_to_bitvector(hex_values::Vector{UInt8})::BitVector 
    bits = BitVector(undef, 8 * length(hex_values))
    for (i, byte) in enumerate(hex_values)
        for j in 0:7
            bits[8 * (i - 1) + (8 - j)] = (byte >> j) & 1 == 1
        end
    end
    return bits
end