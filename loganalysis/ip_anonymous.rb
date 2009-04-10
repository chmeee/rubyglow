#!/usr/bin/env ruby

require 'crypt/rijndael'
require 'ipaddr'

module IP

class Anonymous
  def initialize(key)
    m_key = key[0..15].pack("C16")
    @m_pad = key[16..31].pack("C16")

    @ecb = Crypt::Rijndael.new(m_key)
    @m_pad = @ecb.encrypt_block(@m_pad)

    @first_4bytes_pad = @m_pad.unpack("N").first
  end

  def anonymize(address)
    result = 0

    if address !~ /^\d{1,3}(?:\.\d{1,3}){3}$/
      puts "ERROR [#{__LINE__}]: invalid IP address format"
      return
    end
    
    address = address.split(".").map{ |e| e.to_i }.pack("C4").unpack("N").first
    rin_input = @m_pad.unpack("C16")

    rin_input[0] =   @first_4bytes_pad >> 24
    rin_input[1] = ((@first_4bytes_pad <<  8 & 0xffffffff) >> 24)
    rin_input[2] = ((@first_4bytes_pad << 16 & 0xffffffff) >> 24)
    rin_input[3] = ((@first_4bytes_pad << 24 & 0xffffffff) >> 24)

    rin_output = @ecb.encrypt_block(rin_input.pack("C16")).unpack("C").first
    result |= (rin_output >> 7) << 31

    31.times do |n|
      position = n + 1
      first_4bytes_input = ((address >> (32-position)) << (32-position)) |
                           ((@first_4bytes_pad << position & 0xffffffff) >> position)

      rin_input[0] =   first_4bytes_input >> 24
      rin_input[1] = ((first_4bytes_input <<  8 & 0xffffffff) >> 24)
      rin_input[2] = ((first_4bytes_input << 16 & 0xffffffff) >> 24)
      rin_input[3] = ((first_4bytes_input << 24 & 0xffffffff) >> 24)

      rin_output = @ecb.encrypt_block(rin_input.pack("C16")).unpack("C").first
      result |= (rin_output >> 7) << (31-position)
    end

    IPAddr.new(result ^ address, Socket::AF_INET).to_s
  end
end

end
