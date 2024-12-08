include("string2bytes.jl")
include("HeaderCreation.jl")
include("HammingEncoding.jl")
include("ZeroPadding.jl")
include("Interleaving.jl")
include("GrayReverseCoding.jl")
include("../Utilities/hex2bitvector.jl")


"""
    encoding_header(msg::String, CRC_enable::Bool, CR_payload::Int, CR_header::Int, DE_header::Bool, SF::Int) -> Vector{Int}

Encodes the header of a LoRa message. Performs the following steps:
1. Converts the message string to bytes.
2. Creates the header bits based on the message bytes and configuration.
3. Applies Hamming encoding to the header bits.
4. Adds zero padding 
5. Interleaves the bits to improve robustness against errors.
6. Applies Gray reverse coding to produce the final header symbols.

# Arguments:
- `msg`: The message to encode as a string.
- `CRC_enable`: Whether CRC (Cyclic Redundancy Check) is enabled.
- `CR_payload`: Coding rate for the payload.
- `CR_header`: Coding rate for the header.
- `DE_header`: Whether data rate optimization is enabled.
- `SF`: Spreading factor.

# Returns:
A vector of integers representing the encoded header symbols.
"""
function encoding_header(msg::String, CRC_enable::Bool, CR_payload::Int8, CR_header::Int8, DE_header::Bool, SF::Int8)::Vector{Int}
    # Step 1: Convert message to bytes
    msg_bytes = string_to_bytes(msg)

    # Step 2: Create header bits
    header_bits = header_creation(msg_bytes, CRC_enable, CR_payload)

    # Step 3: Hamming encode the header bits
    header_bits_HammingEncoded = hamming_encoding(header_bits, CR_header)

    # Step 4: Add zero padding for alignment
    header_bits_zeroPadded = zero_padding(header_bits_HammingEncoded, CR_header, DE_header, SF)

    # Step 5: Interleave the bits for error robustness
    header_interleaved_Matrix = interleaving(header_bits_zeroPadded, CR_header, DE_header, true, SF)

    # Step 6: Apply Gray reverse coding to generate symbols
    header_symbols = gray_reverse_coding(header_interleaved_Matrix, DE_header)

    return header_symbols
end
