include("Encoding/encodingHeader.jl")
include("Encoding/encodingPayload.jl")

include("Decoding/decodingHeader.jl")
include("Decoding/decodingPayload.jl")

# Default LoRa Configuration Parameters
SF = Int8(10)            # Spreading Factor: {7, 8, 9, 10, 11, 12}
CR_payload = Int8(3)     # Coding Rate: CR = 1 (4/5), CR = 2 (4/6), CR = 3 (4/7), CR = 4 (4/8)
CRC_enable = true        # Cyclic Redundancy Check: {true, false}
DE_payload = false       # Data Rate Optimization: {true, false}, true when T_s > 16 ms
preamble_length = 8      # Preamble length: {6-65535}

# Fixed LoRa Parameters
const CR_header = Int8(4)      # Coding Rate of the header
const DE_header = true   # Data Rate Optimization for the header

# Define CRC types as symbols
const CRC_TYPE_CCITT = :ccitt  # default
const CRC_TYPE_IBM = :ibm

# Example Payload Message
msg = "Hi"  # Payload message


header_symbols = encoding_header(msg, CRC_enable, CR_payload, CR_header, DE_header, SF)
payload_symbols = encoding_payload(msg, CRC_TYPE_CCITT, CR_payload, DE_payload, SF )

# concatinate the symbols together
symbols = vcat(header_symbols, payload_symbols)

payload_length_bytes_decoded, CR_Payload_decoded, CRC_enabled_decoded = decoding_header(symbols, DE_header::Bool, SF::Int8, CR_header::Int8)
msg = decoding_payload(symbols, DE_payload, SF, CR_Payload_decoded, CRC_enabled_decoded)