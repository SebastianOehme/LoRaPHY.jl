include("../Utilities/map2nearest4kplus1.jl")
include("../Utilities/int2bitvector.jl")



function gray_coding(symbol::Vector{Int}, DE::Bool, SF::Int8)::BitVector

    decodedBitVector = BitVector()

    for i in 1:1:length(symbol)

        if (DE == true)
            symbol[i] = map_to_nearest_4k_plus_1(symbol[i])  # Mapping of Symbols for LDRO ON
            symbol[i] += 3        #  add 3 from even elements needed for correct Gray code
            if (mod(symbol[i],8) == 4)      # is symbol not devisable by 8 or not close to it
                symbol[i] -= 3             # substract 3 value
            end
        end

        symbol[i] -= 1

        B_ = BitVector(falses(SF))
        
        B_ = int_to_bitvector(symbol[i], SF) # Chirp Demodulation ich bekomme ein Symbol heraus ein Int Wert
        
        # Gray Coding
        G = BitVector(falses(SF))

        G[1] = B_[1]

        for i in 1:1:length(B_)-1
            G[i+1] = xor(B_[i+1], B_[i])
        end

        decodedBitVector = append!(decodedBitVector, G)
    end

    return decodedBitVector
end


