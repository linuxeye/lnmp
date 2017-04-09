# -*- coding: utf-8 -*-

from __future__ import print_function
import struct
import io

try:
    range = xrange
except NameError:
    pass


def _left_rotate(n, b):
    """Left rotate a 32-bit integer n by b bits."""
    return ((n << b) | (n >> (32 - b))) & 0xffffffff


def _process_chunk(chunk, h0, h1, h2, h3, h4):
    """Process a chunk of data and return the new digest variables."""
    assert len(chunk) == 64

    w = [0] * 80

    # Break chunk into sixteen 4-byte big-endian words w[i]
    for i in range(16):
        w[i] = struct.unpack(b'>I', chunk[i * 4:i * 4 + 4])[0]

    # Extend the sixteen 4-byte words into eighty 4-byte words
    for i in range(16, 80):
        w[i] = _left_rotate(w[i - 3] ^ w[i - 8] ^ w[i - 14] ^ w[i - 16], 1)

    # Initialize hash value for this chunk
    a = h0
    b = h1
    c = h2
    d = h3
    e = h4

    for i in range(80):
        if 0 <= i <= 19:
            # Use alternative 1 for f from FIPS PB 180-1 to avoid bitwise not
            f = d ^ (b & (c ^ d))
            k = 0x5A827999
        elif 20 <= i <= 39:
            f = b ^ c ^ d
            k = 0x6ED9EBA1
        elif 40 <= i <= 59:
            f = (b & c) | (b & d) | (c & d)
            k = 0x8F1BBCDC
        elif 60 <= i <= 79:
            f = b ^ c ^ d
            k = 0xCA62C1D6

        a, b, c, d, e = ((_left_rotate(a, 5) + f + e + k + w[i]) & 0xffffffff,
                         a, _left_rotate(b, 30), c, d)

    # Add this chunk's hash to result so far
    h0 = (h0 + a) & 0xffffffff
    h1 = (h1 + b) & 0xffffffff
    h2 = (h2 + c) & 0xffffffff
    h3 = (h3 + d) & 0xffffffff
    h4 = (h4 + e) & 0xffffffff

    return h0, h1, h2, h3, h4


class Sha1Hash(object):
    """A class that mimics that hashlib api and implements the SHA-1 algorithm."""

    name = 'python-sha1'
    digest_size = 20
    block_size = 64

    def __init__(self):
        # Initial digest variables
        self._h = (
            0x67452301,
            0xEFCDAB89,
            0x98BADCFE,
            0x10325476,
            0xC3D2E1F0,
        )

        # bytes object with 0 <= len < 64 used to store the end of the message
        # if the message length is not congruent to 64
        self._unprocessed = b''
        # Length in bytes of all data that has been processed so far
        self._message_byte_length = 0

    def update(self, arg):
        """Update the current digest.
        This may be called repeatedly, even after calling digest or hexdigest.

        Arguments:
            arg: bytes, bytearray, or BytesIO object to read from.
        """
        if isinstance(arg, (bytes, bytearray)):
            arg = io.BytesIO(arg)

        # Try to build a chunk out of the unprocessed data, if any
        chunk = self._unprocessed + arg.read(64 - len(self._unprocessed))

        # Read the rest of the data, 64 bytes at a time
        while len(chunk) == 64:
            self._h = _process_chunk(chunk, *self._h)
            self._message_byte_length += 64
            chunk = arg.read(64)

        self._unprocessed = chunk
        return self

    def digest(self):
        """Produce the final hash value (big-endian) as a bytes object"""
        return b''.join(struct.pack(b'>I', h) for h in self._produce_digest())

    def hexdigest(self):
        """Produce the final hash value (big-endian) as a hex string"""
        return '%08x%08x%08x%08x%08x' % self._produce_digest()

    def inner_digest(self):

        tmp = struct.unpack(">5I", struct.pack("<5I", *self._h))
        return '%08x%08x%08x%08x%08x' % tmp

    def _produce_digest(self):
        """Return finalized digest variables for the data processed so far."""
        # Pre-processing:
        message = self._unprocessed
        message_byte_length = self._message_byte_length + len(message)

        # append the bit '1' to the message
        message += b'\x80'

        # append 0 <= k < 512 bits '0', so that the resulting message length (in bytes)
        # is congruent to 56 (mod 64)
        message += b'\x00' * ((56 - (message_byte_length + 1) % 64) % 64)

        # append length of message (before pre-processing), in bits, as 64-bit big-endian integer
        message_bit_length = message_byte_length * 8
        message += struct.pack(b'>Q', message_bit_length)

        # Process the final chunk
        # At this point, the length of the message is either 64 or 128 bytes.
        h = _process_chunk(message[:64], *self._h)
        if len(message) == 64:
            return h
        return _process_chunk(message[64:], *h)


def sha1(data):
    """SHA-1 Hashing Function
    A custom SHA-1 hashing function implemented entirely in Python.
    Arguments:
        data: A bytes or BytesIO object containing the input message to hash.
    Returns:
        A hex SHA-1 digest of the input message.
    """
    return Sha1Hash().update(data).hexdigest()


class Sha1Util(object):

    @staticmethod
    def get_sha1_by_slice(file_name, slice_size):
        """ Get SHA array based on Qcloud Slice Upload Interface

        :param file_name: local file path
        :param slice_size: slice size in bit
        :return: sha array like [{“offset”:0, “datalen”:1024,”datasha”:”aaa”}, {}, {}]
        """
        from os import path

        with open(file_name, 'rb') as f:

            result = []
            file_size = path.getsize(file_name)
            sha1_obj = Sha1Hash()
            for current_offset in range(0, file_size, slice_size):

                data_length = min(slice_size, file_size - current_offset)
                sha1_obj.update(f.read(data_length))
                sha1_val = sha1_obj.inner_digest()
                result.append({"offset": current_offset, "datalen": data_length, "datasha": sha1_val})

            result[-1]['datasha'] = sha1_obj.hexdigest()
            return result


if __name__ == '__main__':
    # Imports required for command line parsing. No need for these elsewhere
    import argparse
    import sys
    import os

    # Parse the incoming arguments
    parser = argparse.ArgumentParser()
    parser.add_argument('input', nargs='?',
                        help='input file or message to hash')
    args = parser.parse_args()

    data = None

    if args.input is None:
        # No argument given, assume message comes from standard input
        try:
            # sys.stdin is opened in text mode, which can change line endings,
            # leading to incorrect results. Detach fixes this issue, but it's
            # new in Python 3.1
            data = sys.stdin.detach()
        except AttributeError:
            # Linux ans OSX both use \n line endings, so only windows is a
            # problem.
            if sys.platform == "win32":
                import msvcrt

                msvcrt.setmode(sys.stdin.fileno(), os.O_BINARY)
            data = sys.stdin
    elif os.path.isfile(args.input):
        # An argument is given and it's a valid file. Read it
        data = open(args.input, 'rb')
    else:
        data = args.input

    # Show the final digest
    print('sha1-digest:', sha1(data))
