
function bitvector_to_int(bits::BitVector)::Int
    # Calculate the integer value directly from the BitVector
    return sum(bits[i] * 2^(length(bits) - i) for i in 1:length(bits))
end

