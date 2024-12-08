include("GrayDecoding.jl")
include("../Utilities/bitvector2bitmatrix.jl")
include("Deinterleaving.jl")
include("RemoveZeroPadding.jl")
include("HammingDecoding.jl")
include("HeaderCRC.jl")
include("Dewhitening.jl")


"""
    decoding_payload(symbols::Vector{Int64}, DE_payload::Bool, SF::Int8, CR_payload::Int8, CRC_enable::Bool) -> Union{String, Nothing}

Decodes the payload of a LoRa message by:
1. Applying Gray decoding to convert symbols into a bit vector.
2. Deinterleaving the bit matrix for the payload.
3. Removing zero padding from the deinterleaved payload.
4. Applying Hamming decoding 
5. Dewhitening the payload to recover the original message.
6. Performing a CRC check to validate the payload.

# Arguments:
- `symbols`: Vector of integers representing the payload symbols.
- `DE_payload`: Boolean indicating whether data rate optimization is enabled for the payload.
- `SF`: Spreading factor used for the payload.
- `CR_payload`: Coding rate used for the payload.
- `CRC_enable`: Boolean indicating whether CRC is enabled for the payload.

# Returns:
A decoded message as a `String` if CRC check passes, or `nothing` if it fails.
"""
function decoding_payload(symbols::Vector{Int64}, DE_payload::Bool, SF::Int8, CR_payload::Int8, CRC_enable::Bool)::Union{String, Nothing}

    # Step 1: Apply Gray decoding to payload symbols (excluding header symbols)
    payload_bV = gray_coding(symbols[9:end], DE_payload, SF)
    
    # Step 2: Convert bit vector to a bit matrix
    payload_M = bitvector_to_bitmatrix(payload_bV, SF)

    # Step 3: Deinterleave the bit matrix
    row_n, column_n = size(payload_M)
    number_of_loop_passages = Int(row_n / (CR_payload + 4))
    deinterleaved_matrix_payload_full = BitMatrix(undef, 0, 8)

    for i in 0:(number_of_loop_passages - 1)
        payload_M_block = payload_M[(i * (CR_payload + 4) + 1):(CR_payload + 4) * (i + 1), :]
        deinterleaved_matrix_payload = diag_deinterleaving(payload_M_block, CR_payload, DE_payload)
        deinterleaved_matrix_payload_full = vcat(deinterleaved_matrix_payload_full, deinterleaved_matrix_payload)
    end

    # Step 4: Remove zero padding from the payload
    NumberOfPayloadNibbles = payload_length_bytes_decoded * 2
    deinterleaved_matrix_payload_full = removeZeroPadding(deinterleaved_matrix_payload_full, false, NumberOfPayloadNibbles, CRC_enable)

    # Step 5: Hamming decode the payload
    hammingdecoded_payload = hammingDecoding(deinterleaved_matrix_payload_full, CR_payload)

    # Step 6: Dewhitening the payload bits to recover the message in hex
    msg_hex = dewhitening(hammingdecoded_payload[1:payload_length_bytes_decoded * 8], false)

    # Step 7: Perform CRC Check
    # Extract the received CRC value
    crc_bits_received = hammingdecoded_payload[(payload_length_bytes_decoded * 8 + 1):end]
    crc_hex = bitvector_to_hex(crc_bits_received)

    # Calculate the CRC based on the received message
    crc_bytes_calc_with_received = PacketComputeCrc(msg_hex, CRC_TYPE_CCITT)

    if crc_hex[1] == crc_bytes_calc_with_received[1] && crc_hex[2] == crc_bytes_calc_with_received[2]
        msgDecoded = String(msg_hex)
        return msgDecoded
    else
        println("Error in payload: CRC mismatch")
        return nothing
    end
end