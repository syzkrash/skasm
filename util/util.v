module util

[noreturn]
pub fn on_err(err IError, msg string) {
	eprintln("$msg: $err")
	exit(1)
}

[noreturn]
pub fn on_fail(msg string) {
	eprintln(msg)
	exit(1)
}

pub fn sanitize_line(ln string) string {
	mut ln_sane := ln.trim_space().replace("  ", " ")
	for ln_sane.contains("  ") {
		ln_sane = ln_sane.replace("  ", " ")
	}
	return ln_sane
}
