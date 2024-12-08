function bitvector_to_pieces(bv::BitVector, n::Int)
    pieces = Vector{BitVector}(undef, 0)  # Initialize an empty array to store BitVectors
    for i in 1:n:length(bv)
        piece = BitVector(undef, n)  # Create a BitVector of length 4
        for j in 0:(n-1)
            if i + j <= length(bv)
                piece[j + 1] = bv[i + j]
            else
                piece[j + 1] = false  # Fill remaining bits with false (0) if not enough bits
            end
        end
        pieces = push!(pieces, piece)
    end
    return pieces
end