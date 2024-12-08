include("GrayDecoding.jl")
include("../Utilities/bitvector2bitmatrix.jl")
include("Deinterleaving.jl")
include("RemoveZeroPadding.jl")
include("HammingDecoding.jl")
include("HeaderCRC.jl")


"""
    decoding_header(symbols::Vector{Int64}, DE_header::Bool, SF::Int8, CR_header::Int8) 
        -> (Int, Int8, Bool)

Decodes the header of a LoRa message by performing the following steps:
1. Applies Gray coding to decode the symbols into bits.
2. Deinterleaves the bit matrix to recover the original bit order.
3. Removes zero padding from the bit matrix.
4. Applies Hamming-decoding
5. Checks the header CRC 
6. Extracts payload length, coding rate, and CRC enabled flag from the decoded header.

# Arguments:
- `symbols`: Vector of integers representing the header symbols.
- `DE_header`: Boolean indicating whether data rate optimization is enabled for the header.
- `SF`: Spreading factor used for the header.
- `CR_header`: Coding rate used for the header.

# Returns:
- `payload_length_bytes_decoded` (Int): Payload length in bytes.
- `CR_Payload_decoded` (Int8): Decoded coding rate for the payload.
- `CRC_enabled_decoded` (Bool): Whether CRC is enabled for the payload.
"""
function decoding_header(symbols::Vector{Int64}, DE_header::Bool, SF::Int8, CR_header::Int8)

    # Step 1: Apply Gray coding to decode symbols into bits
    header_bV = gray_coding(symbols[1:8], DE_header, SF)

    # Step 1.1: Convert BitVector to a BitMatrix
    header_M = bitvector_to_bitmatrix(header_bV, SF)

    # Step 2: Deinterleave the bit matrix
    deinterleaved_matrix_header = diag_deinterleaving(header_M, CR_header, DE_header)

    # Step 3: Remove zero padding
    deinterleaved_matrix_header = removeZeroPadding(deinterleaved_matrix_header, true, 0, false)

    # Step 4: Decode Hamming-encoded bits
    hammingdecoded_header = hammingDecoding(deinterleaved_matrix_header, CR_header)

    # Step 5: Check the CRC of the header
    if check_header_with_crc(hammingdecoded_header)
        #println("ERROR in header!")
        error("Header decoding failed due to CRC mismatch.")
    else
        #println("No error in header")
    end

    # Step 6: Decode header information
    payload_length_bytes_decoded = bitvector_to_int(hammingdecoded_header[1:8])  # Payload length in bytes
    CR_Payload_decoded = Int8(bitvector_to_int(hammingdecoded_header[9:11]))    # Coding rate for the payload
    CRC_enabled_decoded = hammingdecoded_header[12]                             # CRC enabled flag

    # Print header information
    #println("Payload length in bytes: ", payload_length_bytes_decoded)
    #println("Coding Rate: 4/", CR_Payload_decoded + 4)
    #println("CRC Enabled: ", CRC_enabled_decoded)

    return payload_length_bytes_decoded, CR_Payload_decoded, CRC_enabled_decoded
end

