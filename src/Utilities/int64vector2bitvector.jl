function int64vector_to_bitvector(vec::Vector{Int64})::BitVector
    bitvec = BitVector()
    for num in vec
        push!(bitvec, num == 1)
    end
    return bitvec
end