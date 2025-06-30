import sys

def checksum(record):
    return (-sum(record)) & 0xFF

def emit_record(addr, data):
    record = [len(data), (addr >> 8) & 0xFF, addr & 0xFF, 0x00] + data
    hexstr = ":{:02X}{:04X}00{}".format(len(data), addr, ''.join(f"{b:02X}" for b in data))
    cksum = checksum(record)
    return f"{hexstr}{cksum:02X}"

def main(binfile, hexfile):
    with open(binfile, "rb") as f:
        data = f.read()

    with open(hexfile, "w") as f:
        addr = 0
        for i in range(0, len(data), 4):
            chunk = data[i:i+4]
            if len(chunk) < 4:
                chunk += b'\x00' * (4 - len(chunk))
            little_endian = list(chunk[::-1])
            f.write(emit_record(addr, little_endian) + "\n")
            addr += 1
        f.write(":00000001FF\n")  # EOF

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 bin2ihex_le.py input.bin output.hex")
    else:
        main(sys.argv[1], sys.argv[2])