#!/usr/bin/env python3
"""join_trk.py OUT.trk PART1.trk PART2.trk ...: joins .trk files"""
import struct
import sys

HEADER, COUNT_AT = 1000, 988
out_file, part_files = sys.argv[1], sys.argv[2:]
assert part_files, "no parts given"

first, total = None, 0
with open(out_file, "wb") as out:
    for name in part_files:
        with open(name, "rb") as part:
            head = part.read(HEADER)
            assert len(head) == HEADER and head[:5] == b"TRACK", name + " is not a .trk file"
            assert struct.unpack("<i", head[996:1000])[0] == HEADER, name + ": unexpected header size"
            if first is None:
                first = head
                out.write(head)
            same = head[:COUNT_AT] == first[:COUNT_AT] and head[COUNT_AT + 4:] == first[COUNT_AT + 4:]
            assert same, name + ": header differs from " + part_files[0]
            total += struct.unpack("<i", head[COUNT_AT:COUNT_AT + 4])[0]
            while True:
                block = part.read(8 << 20)
                if not block:
                    break
                out.write(block)
    out.seek(COUNT_AT)
    out.write(struct.pack("<i", total))
