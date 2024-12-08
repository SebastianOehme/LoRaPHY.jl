function bitvector_to_hex(bV::BitVector)
    BytesHamming = bitvector_to_pieces(bV, 8)
    int_values = bitvector_to_int.(BytesHamming)
    s = string.(int_values, base = 16)
    hexV = parse.(UInt8, s; base=16)
    return hexV
end