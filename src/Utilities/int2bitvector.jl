function int_to_bitvector(x::Int, length::Int8)::BitVector
    bits = falses(length)  # Create a BitVector of the specified length initialized to false (0)
    for i in 1:length
        bits[length - i + 1] = (x % 2 == 1)  # Check the least significant bit
        x = x >> 1  # Right shift the integer to check the next bit
    end
    return bits
end