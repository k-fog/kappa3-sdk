import sys

if len(sys.argv) != 3:
    print(f"Usage: {sys.argv[0]} <input.bin> <output.hex>")
    sys.exit(1)

input_file = sys.argv[1]
output_file = sys.argv[2]

with open(input_file, "rb") as f:
    data = f.read()

with open(output_file, "w") as f:
    for b in data:
        f.write(f"{b:02X}\n")