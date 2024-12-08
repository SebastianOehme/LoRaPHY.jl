# Function to swap nibbles in a BitVector
function swap_nibbles(bitvec::BitVector)
        
    # Ensure the BitVector has a length that is a multiple of 8
    @assert length(bitvec) % 8 == 0 "The BitVector's length must be a multiple of 8 bits."
    
    # Loop through each byte (8 bits) and swap the nibbles
    for i in 1:8:length(bitvec)
         # Swap first 4 bits with the second 4 bits in each byte
        bitvec[i:i+3], bitvec[i+4:i+7] = bitvec[i+4:i+7], bitvec[i:i+3]
    end

    return bitvec
end