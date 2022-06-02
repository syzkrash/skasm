module assembler

import util

const opmap_raw = $embed_file("opmap")

fn prep_opmap() ?map[string]u8 {
	println("preparing opmap...")
	mut opmap := map[string]u8{}
	for ln in opmap_raw.to_string().split_into_lines() {
		ln_sane := util.sanitize_line(ln)
		if ln_sane == "" || ln_sane.starts_with("//") {
			continue
		}
		elems := ln_sane.split(" ")
		key := elems[0].to_upper()
		val := u8(to_num(elems[1], 8)?)
		opmap[key] = val
	}
	return opmap
}
