import net.http
import util
import time
import os

[inline; noreturn]
fn on_quit(msg string) {
	println(msg)
	exit(1)
}

[inline; noreturn]
fn on_err(err IError, msg string) {
	println("$msg: $err")
	exit(1)
}

[inline]
fn write(mut f os.File, txt string) {
	f.write_string(txt) or { on_err(err, "Could not write") }
}

fn to_num(s string, bits int) ?u64 {
	if s.starts_with("0x") {
		return s.trim_string_left("0x").parse_uint(16, bits)
	}
	return s.parse_uint(10, bits)
}

println("Fetching new opmap")
r := http.get("https://raw.githubusercontent.com/syzkrash/skvm/nightly/opmap")
	or { on_err(err, "Could not fetc") }
if r.status_code != 200 {
	on_quit("Got non-200 response: $r.status_code")
}

println("Parsing opmap")
mut opmap := map[string]u8{}
for ln in r.text.split_into_lines() {
	ln_sane := util.sanitize_line(ln)
	if ln_sane == "" || ln_sane.starts_with("//") {
		continue
	}
	elems := ln_sane.split(" ")
	key := elems[0].to_upper()
	val := u8(to_num(elems[1], 8)?)
	opmap[key] = val
}

println("Writing new opmap.v")
mut f := create("assembler/opmap.v")
	or { on_err(err, "Could not create file") }
defer { f.close() }

t := time.now().custom_format("Do MMM YYYY HH:mm:ss (Z)")
write(mut f, "// Generated with gen_op.vsh on $t\n")
write(mut f, "module assembler\nconst opmap := map[string]u8{\n")
for op, code in opmap {
	write(mut f, "\t\"$op\": $code,\n")
}
write(mut f, "}\n")

println("Done!")
