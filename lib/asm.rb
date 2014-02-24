# Cinch plugin, which uses Metasploit's Rex::Assembly::Nasm
# module to assemble and disassembl x86/x64 opcodes.

# Examples:
#
# instructions to opcodes
# 15:26 <@warrick> !x86 cmp eax, 1
# 15:26 < podge> 00000000  83F801            cmp eax,byte +0x1
# 
# hex opcodes to instructions
# 15:27 <@warrick> !x86 83F801
# 15:27 < podge> warrick: 00000000  83F801            cmp eax,byte +0x1

require 'cinch'
require 'rex'

class ASM
  include Cinch::Plugin

  set :prefix, /^!/
  match(/(x86|x64)(.*)/)

  def execute(m)
    c, s = m.message.split(' ', 2)
    bits = (c =~ /^!x86/) ? 32 : 64
    s.strip!
    s.gsub!(/(\r|\n)/, '') 
    s.gsub!(/\\n/, "\n")
    s.gsub!(';', "\n")

    case s
    when /^[a-fA-F0-9]+$/, /^(\\x[a-fA-F0-9]{2})+$/
      s.gsub!(/\\x/, '') 
      bin = s.chars.each_slice(2).map { |t| t.join.to_i(16).chr }.join
      m.reply(Rex::Assembly::Nasm.disassemble(bin), bits)
    else
      bin = Rex::Assembly::Nasm.assemble(s, bits)
      m.reply(Rex::Assembly::Nasm.disassemble(bin, bits))
    end 
  end 
end
