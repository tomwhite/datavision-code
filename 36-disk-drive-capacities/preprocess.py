# Restrict to drives the first time they appear (by serial number)
import sys

serial_numbers = set()

for line in sys.stdin:
    fields = line.split(',')
    serial_number = fields[1]
    if serial_number != "serial_number" and serial_number not in serial_numbers:
        serial_numbers.add(serial_number)
        print(",".join(fields[:5]))  # drop smart fields
