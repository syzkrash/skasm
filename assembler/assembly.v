module assembler

import io

const word_splits = [' '[0], '\t'[0], '\n'[0]]

fn get_word(mut src io.Reader) ?string {
	mut buf := [u8(0)]
	mut ctx := []u8{}
	for {
		src.read(mut &buf)?
		if buf[0] in word_splits {
			if ctx.len == 0 {
				continue
			}
			break
		}
		ctx << buf[0]
	}
	return ctx.bytestr()
}

pub fn assemble(mut src io.Reader, mut out io.Writer) ? {
	opmap := prep_opmap()?

	mut instr_count := 0

	for {
		word := get_word(mut &src) or { break }
		opword := word.to_upper()
		if opword !in opmap {
			return IError(AssemblerError{message: "unknown opcode: $word"})
		}
		opcode := opmap[opword]
		out.write([opcode])?

		match opword {
			"PUSHB" {
				immi_word := get_word(mut &src)?
				immi := to_num(immi_word, 8)?
				out.write([u8(immi)])?
			}
			"PUSHP" {
				immi_word := get_word(mut &src)?
				immi := to_num(immi_word, 16)?
				out.write(u16bytes(u16(immi)))?
			}
			"PUSHI" {
				immi_word := get_word(mut &src)?
				immi := to_num(immi_word, 32)?
				out.write(u32bytes(u32(immi)))?
			}
			"PUSHL" {
				immi := get_word(mut &src)?
				out.write(immi.bytes())?
			}
			else {}
		}

		instr_count++
	}

	println("assembled $instr_count instructions.")
}
