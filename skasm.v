module main

import os

import assembler
import util

fn main() {
	if os.args.len <= 1 {
		eprintln("provide an input file.")
		exit(1)
	}
	filename := os.args[1]
	outname := filename.all_before_last(".") + ".bin"

	mut src := os.open(filename)
		or { util.on_err(err, "couldn't open source file") }
	mut out := os.create(outname)
		or { util.on_err(err, "couldn't create binary file") }

	println("assembling $filename to $outname"+"...")
	mut ctx := assembler.AssemblyContext{src: src, out: out}
	for {
		cont := ctx.next() or { util.on_err(err, "couldn't assemble") }
		if !cont {
			break
		}
	}
	ctx.finish() or { util.on_err(err, "couldn't assemble") }

	println("assembly stats:")
	println("\t$ctx.instrs instructions")
	println("\t$ctx.data.len data pieces")
}
