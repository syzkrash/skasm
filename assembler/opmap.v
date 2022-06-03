// Generated with gen_op.vsh on 3rd Jun 2022 18:10:10 (+2)
module assembler
const opmap := map[string]u8{
	"NOOP": 0,
	"PANIC": 1,
	"DROP": 16,
	"DUP": 20,
	"SWAP": 17,
	"ROT": 18,
	"OVER": 19,
	"PUSHB": 26,
	"PUSHP": 27,
	"PUSHI": 28,
	"PUSHF": 29,
	"PUSHL": 30,
	"GETB": 32,
	"SETB": 33,
	"GETP": 34,
	"SETP": 35,
	"GETI": 36,
	"SETI": 37,
	"GETF": 38,
	"SETF": 39,
	"ADD": 48,
	"SUB": 49,
	"MUL": 50,
	"DIMD": 51,
	"LSH": 52,
	"RSH": 53,
	"AND": 54,
	"OR": 55,
	"XOR": 56,
	"NOT": 57,
	"LABEL": 64,
	"FUNC": 65,
	"JMP": 66,
	"CALL": 67,
	"RET": 68,
	"JMPIF": 79,
}
