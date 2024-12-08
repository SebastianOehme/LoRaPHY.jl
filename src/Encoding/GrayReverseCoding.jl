include("../Utilities/bitvector2int.jl")

"""
    gray_reverse_coding(bitM::BitMatrix, DE::Bool) -> Vector{Int}

Performs Gray reverse coding on a given `BitMatrix` and optionally applies a Long Distance Radio Optimization (LDRO) adjustment.

# Arguments:
- `bitM`: A `BitMatrix` where each row represents a Gray-encoded symbol as a sequence of bits.
- `DE`: A Boolean indicating whether Data Rate Optimization (LDRO) is enabled.

# Returns:
A `Vector{Int}` where each element corresponds to an integer value decoded from the Gray-coded input, with optional LDRO adjustments applied.
"""

function gray_reverse_coding(bitM::BitMatrix, DE::Bool)::Vector{Int}
      
    row, column = size(bitM)
    symbol = Vector{Int}(zeros(row))

    # loop that maps the transmission data to the corresponding integer value for the chirp
    for i in 1:1:length(symbol)
    
        B = BitVector(falses(column)) #  stores the gray decoded bitvector 

        # Gray Decoding MSB is the same for the G Gray Code as for the Binary value
        B[1] = bitM[i,1]
 
        # loop that performs gray decoding
        for k in 1:1:column-1
            B[k+1] = xor(bitM[i, k+1], B[k])
        end

        # Symbol was ich in die Chirp Modulation gebe
        symbol[i] = bitvector_to_int(B)

        # add one to mitigate the bin drift
        symbol[i] += 1
    end

    # LDRO ON
    if (DE == true)
        for i in 1:length(symbol)
            if (symbol[i] % 2 == 0 && symbol[i] > 2)  # Check if the element is even
               symbol[i] -= 3        # Subtract 3 from even elements
            end
        end  
    end

    return symbol
end

