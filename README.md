# skasm

skasm is an assembler for the [skvm](https://github.com/syzkrash/skvm) virtual
machine. The syntax of this assembler is based on the pseudocode used in skvm
issues.

## Example

*this is not functional, yet.*

```c
// put "Hello, world!" to 0x100 in memory at startup
// this will be data embedded into the binary, not written by the assembled
// bytecode
TEXT hi 0x100 "Hello, world!"

// push the PRINT callback to the stack
PUSHB $PRINT

// push a pointer to the hello world onto the stack
PUSHP 0x100 // or PUSHP $hi

// call back to the vm to execute the PRINT callback
CALLBACK
```
