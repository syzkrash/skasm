module assembler

fn u16bytes(n u16) []u8 {
	return [
		u8(n >> 8 & 0xFF),
		u8(n & 0xFF),
	]
}

fn u32bytes(n u32) []u8 {
	return [
		u8(n >> 24 & 0xFF),
		u8(n >> 16 & 0xFF),
		u8(n >> 8 & 0xFF),
		u8(n & 0xFF),
	]
}

struct AssemblerError {
	Error
	message string
}

fn (e AssemblerError) msg() string {
	return e.message
}
