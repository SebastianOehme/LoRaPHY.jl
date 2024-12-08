function bitvector_to_bitmatrix(bv::BitVector, columns::Int8)
    # Calculate the number of rows
    rows = Int(ceil(length(bv) / columns))
    
    # Pad the BitVector if necessary to ensure the matrix is full
    padded_bv = vcat(bv, falses(rows * columns - length(bv)))
    
    # Reshape the padded BitVector into a BitMatrix with the specified number of columns
    columns = Int64(columns)
    bit_matrix = reshape(padded_bv, columns, rows)
    transposed_matrix = permutedims(bit_matrix)

    return transposed_matrix
end