

# Define CCITT
const POLYNOMIAL_CCITT = 0x1021 # x^16 + x^12 + x^5 + 1
const CRC_CCITT_SEED = 0x1D0F   # x^16 + x^15 + x^2 + 1

# Define IBM
const POLYNOMIAL_IBM = 0x8005
const CRC_IBM_SEED = 0xFFFF

# Function to compute CRC
# @param crc: Previous CRC value (UInt16)
# @param data: New data to be added to the CRC (UInt8)
# @param polynomial: CRC polynomial selection (UInt16)
# @return: New computed CRC value (UInt16)
function ComputeCrc(crc::UInt16, data::UInt8, polynomial::UInt16)
    for _ in 1:8  # Process each bit in the data byte
        # Check if the MSB of CRC and the MSB of data are different
        if xor.(((crc & 0x8000) >> 8), (data & 0x80)) != 0 
            crc <<= 1                   # Shift CRC left by one bit
            crc = xor.(crc, polynomial) # XOR with polynomial
        else
            crc <<= 1                   # Shift CRC left by one bit without XOR
        end
        data <<= 1                      # Shift data left by one bit
    end
    return crc
end

# @param buffer: Vector of UInt8 values containing the data
# @param crcType: Selects the CRC polynomial (:ccitt or :ibm)
# @return: Computed CRC value
function PacketComputeCrc(buffer::Vector{UInt8}, crcType::Symbol)
    # Select the polynomial and initial CRC based on crcType
    if crcType == CRC_TYPE_IBM
        polynomial = POLYNOMIAL_IBM
        crc = CRC_IBM_SEED
    elseif crcType == CRC_TYPE_CCITT
        polynomial = POLYNOMIAL_CCITT
        crc = CRC_CCITT_SEED
    else
        error("Invalid CRC type. Use :ccitt or :ibm.")
    end

    # Number of bytes to process in the buffer
    bufferLength = length(buffer);

    # Process each byte in the buffer
    for i in 1:bufferLength
        crc = ComputeCrc(crc, buffer[i], polynomial)
    end

   # Return the CRC based on crcType
    if crcType == CRC_TYPE_IBM
        crc_bytes = crc
    else
        crc_bytes = UInt16(~crc)  # Invert CRC bits if using CCITT
    end

    # Extract the most significant byte (MSB)
    msb = UInt8(crc_bytes >> 8)  # Shift right by 8 bits

    # Extract the least significant byte (LSB)
    lsb = UInt8(crc_bytes & 0xFF)  # Mask the lower 8 bits
    
    return crc_bytes = vcat(msb, lsb)
end