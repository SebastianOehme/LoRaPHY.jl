# ------ Mapping of Symbols for LDRO ON ---------

function map_to_nearest_4k_plus_1(value::Int)
    # Caluclate the next Symbol of the pattern 4k + 1
    nearest_symbol = 4 * (value ÷ 4) + 1 # ÷ idendical to floor operation   
    return nearest_symbol
end
