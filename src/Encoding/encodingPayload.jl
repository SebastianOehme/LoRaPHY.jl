include("string2bytes.jl")
include("HammingEncoding.jl")
include("ZeroPadding.jl")
include("Interleaving.jl")
include("GrayReverseCoding.jl")
include("PayloadCRC.jl")
include("Whitening.jl")
include("../Utilities/hex2bitvector.jl")


"""
    encoding_payload(msg::String, crcType::Symbol, CR_payload::Int, DE_payload::Bool, SF::Int) -> Vector{Int64}

Encodes the payload of a LoRa message by performing the following steps:
1. Converts the message string to bytes.
2. Computes the CRC for the message.
3. Applies whitening to the message bytes.
4. Encodes the message and CRC bits using Hamming coding.
5. Zero-pads the encoded bits for alignment.
6. Splits the payload into blocks, applies interleaving, and performs Gray reverse coding.

# Arguments:
- `msg`: The message to encode as a string.
- `crcType`: Type of CRC to use (e.g., `:CCITT`).
- `CR_payload`: Coding rate for the payload.
- `DE_payload`: Whether data rate optimization is enabled.
- `SF`: Spreading factor.

# Returns:
A vector of integers representing the encoded payload symbols.
"""
function encoding_payload(msg::String, crcType::Symbol, CR_payload::Int8, DE_payload::Bool, SF::Int8)::Vector{Int64}
    # Step 1: Convert message to bytes
    msg_bytes = string_to_bytes(msg);

    # Step 2: Compute CRC bytes
    crc_bytes = PacketComputeCrc(msg_bytes, crcType);

    # Step 3: Apply whitening to message bytes
    msg_bytes_whitened = whitening(msg_bytes);

    # Step 4: Concatenate whitened message bytes with CRC bytes
    MsgPlusCRC_bytes = vcat(msg_bytes_whitened, crc_bytes);

    # Step 5: Convert bytes to bits
    MsgPlusCRC_bits = hex_to_bitvector(MsgPlusCRC_bytes);

    # Step 6: Hamming encode the bits
    MsgPlusCRC_bits_HammingEncoded = hamming_encoding(MsgPlusCRC_bits, CR_payload);

    # Step 7: Add zero padding
    MsgPlusCRC_bits_zeroPadded = zero_padding(MsgPlusCRC_bits_HammingEncoded, CR_payload, DE_payload, SF);

    # Adjust spreading factor for LDRO (Long Distance Radio Optimization)
    if(DE_payload == true)
        SF_LDRO = SF - 2;
    else 
        SF_LDRO = SF;
    end

    # Calculate block size based on the adjusted spreading factor
    blockSize = 8 * SF_LDRO

    # Initialize an empty vector to store payload symbols
    payload_symbols = Int64[]

    # Step 8: Process the payload in blocks
    for i in 0:blockSize:length(MsgPlusCRC_bits_zeroPadded)-1
        # Interleave the current block
        payload_interleaved_Matrix = interleaving(
            MsgPlusCRC_bits_zeroPadded[i+1:i+blockSize], 
            CR_payload, 
            DE_payload, 
            false, 
            SF
        );

        # Apply Gray reverse coding
        symbols_payload_block = gray_reverse_coding(payload_interleaved_Matrix, DE_payload);

        # Append the symbols to the payload
        payload_symbols = vcat(payload_symbols, symbols_payload_block)
    end

    return payload_symbols
end