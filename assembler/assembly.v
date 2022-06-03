module assembler

import io

import util

const word_splits = [' '[0], '\t'[0], '\n'[0]]

pub struct AssemblyContext {
pub mut:
	instrs int
	data   map[string]u16 = {}
mut:
	src    io.Reader
	out    io.Writer
	root   bool = true
	datas  bool
}

fn (mut c AssemblyContext) get_word() ?string {
	mut buf := [u8(0)]
	mut ctx := []u8{}
	for {
		c.src.read(mut &buf)?
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

fn (mut c AssemblyContext) get_bytes() ?[]u8 {
	mut buf := [u8(0)]
	mut ctx := []u8{}
	for {
		c.src.read(mut &buf)?
		if buf[0] in word_splits {
			continue
		}
		if buf[0] == '['[0] {
			break
		}
		return IError(AssemblerError{message: "expected quoted string"})
	}
	for {
		c.src.read(mut &buf)?
		if buf[0] == ']'[0] {
			break
		}
		ctx << buf[0]
	}
	byte_src := util.sanitize_line(ctx.bytestr())
	bytes := byte_src.split(" ").map(u8(to_num(it, 8)?))
	return bytes
}

fn (mut c AssemblyContext) get_str() ?[]u8 {
	mut buf := [u8(0)]
	mut ctx := []u8{}
	for {
		c.src.read(mut &buf)?
		if buf[0] in word_splits {
			continue
		}
		if buf[0] == '"'[0] {
			break
		}
		return IError(AssemblerError{message: "expected quoted string"})
	}
	for {
		c.src.read(mut &buf)?
		if buf[0] == '"'[0] {
			break
		}
		ctx << buf[0]
	}
	return ctx
}

pub fn (mut c AssemblyContext) next() ?bool {
	word := c.get_word() or { return false }
	opword := word.to_upper()

	if c.root {
		defer {
			c.root = false
		}
	}

	if opword == "DATA" {
		if !c.datas {
			c.datas = true
			if !c.root {
				c.out.write([u8(0x80)])?
			}
			c.out.write([u8(1)])?
		}
		c.data()?
		return true
	}
	if opword == "TEXT" {
		if !c.datas {
			c.datas = true
			if !c.root {
				c.out.write([u8(0x80)])?
			}
			c.out.write([u8(1)])?
		}
		c.text()?
		return true
	}
	if c.datas {
		c.datas = false
		c.out.write([u8(0), 0, 2])?
	}
	if c.root {
		c.out.write([u8(2)])?
	}
	c.instr(opword)?
	return true
}

pub fn (mut c AssemblyContext) finish() ? {
	if c.datas {
		c.out.write([u8(0), 0])?
	} else {
		c.out.write([u8(0x80)])?
	}
	c.out.write([u8(0x80)])?
}

fn (mut c AssemblyContext) data() ? {
	name := c.get_word()?
	addr := u16(to_num(c.get_word()?, 16)?)
	c.data[name] = addr
	bytes := c.get_bytes()?
	c.out.write(u16bytes(u16(bytes.len)))?
	c.out.write(u16bytes(addr))?
	c.out.write(bytes)?

	if int(addr) + bytes.len > 0xFFFF {
		warning("byte array '$name is too large: $addr + $bytes.len > 65535")
	}
}

fn (mut c AssemblyContext) text() ? {
	name := c.get_word()?
	addr := u16(to_num(c.get_word()?, 16)?)
	c.data[name] = addr
	str := c.get_str()?
	c.out.write(u16bytes(u16(str.len)))?
	c.out.write(u16bytes(addr))?
	c.out.write(str)?

	if int(addr) + str.len > 0xFFFF {
		warning("string '$name is too large: $addr + $str.len > 65535")
	}
}

fn (mut c AssemblyContext) instr(opword string) ? {
	if opword !in opmap {
		return IError(AssemblerError{message: "unknown opcode: $opword"})
	}
	opcode := opmap[opword]
	c.out.write([opcode])?

	match opword {
		"PUSHB" {
			immi_word := c.get_word()?
			immi := to_num(immi_word, 8)?
			c.out.write([u8(immi)])?
		}
		"PUSHP" {
			immi_word := c.get_word()?
			if immi_word[0] == "'"[0] {
				name := immi_word.substr(1, immi_word.len)
				addr := c.data[name] or {
					return IError(AssemblerError{message: "unknown data: $name"})
				}
				c.out.write(u16bytes(addr))?
			} else {
				immi := to_num(immi_word, 16)?
				c.out.write(u16bytes(u16(immi)))?
			}
		}
		"PUSHI" {
			immi_word := c.get_word()?
			immi := to_num(immi_word, 32)?
			c.out.write(u32bytes(u32(immi)))?
		}
		"PUSHL" {
			immi := c.get_word()?
			c.out.write(immi.bytes())?
		}
		else {}
	}

	c.instrs++
}
