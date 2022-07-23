# reproducing a niche GDB 12.1 bug

Bug that exists in GDB 12.1 when trying to disassemble particular addresses in
ARM binaries.

To try it out:

```bash
# 1. built the docker image
❯ docker build -t gdb-arm-dis-crash-repro .
# 2. run the test command
❯ docker run --rm -i -t gdb-arm-dis-crash-repro bash -c \
    "/opt/gdb/gdb/gdb /opt/example-semihosting.elf -batch --ex 'disassemble 0x8003c44,+2'"
Dump of assembler code from 0x8003c44 to 0x8003c46:


Fatal signal: Segmentation fault
----- Backtrace -----
0x55e9c2c2a0a3 gdb_internal_backtrace_1
        /opt/gdb/gdb/bt-utils.c:122
0x55e9c2c2a163 _Z22gdb_internal_backtracev
        /opt/gdb/gdb/bt-utils.c:168
0x55e9c2e0cf09 handle_fatal_signal
        /opt/gdb/gdb/event-top.c:904
0x55e9c2e0d0c1 handle_sigsegv
        /opt/gdb/gdb/event-top.c:977
0x7fde6e0fe51f ???
0x55e9c335e91a mapping_symbol_for_insn
        /opt/gdb/opcodes/arm-dis.c:11868
0x55e9c335e5d3 find_ifthen_state
        /opt/gdb/opcodes/arm-dis.c:11743
0x55e9c335fb3f print_insn
        /opt/gdb/opcodes/arm-dis.c:12284
0x55e9c335fcd7 print_insn_little_arm
        /opt/gdb/opcodes/arm-dis.c:12334
0x55e9c2b57ac9 _Z18default_print_insnmP16disassemble_info
        /opt/gdb/gdb/arch-utils.c:1041
0x55e9c2ba13bc gdb_print_insn_arm
        /opt/gdb/gdb/arm-tdep.c:7808
0x55e9c2b623f3 _Z18gdbarch_print_insnP7gdbarchmP16disassemble_info
        /opt/gdb/gdb/gdbarch.c:3324
0x55e9c2d3090f _ZN16gdb_disassembler10print_insnEmPi
        /opt/gdb/gdb/disasm.c:832
0x55e9c2d2e9da _ZN29gdb_pretty_print_disassembler17pretty_print_insnEPK11disasm_insn10enum_flagsI20gdb_disassembly_flagE
        /opt/gdb/gdb/disasm.c:292
0x55e9c2d2ed65 dump_insns
        /opt/gdb/gdb/disasm.c:354
0x55e9c2d3049b do_assembly_only
        /opt/gdb/gdb/disasm.c:754
0x55e9c2d30dab _Z15gdb_disassemblyP7gdbarchP6ui_out10enum_flagsI20gdb_disassembly_flagEimm
        /opt/gdb/gdb/disasm.c:912
0x55e9c2c7d98d print_disassembly
        cli/cli-cmds.c:1442
0x55e9c2c7e0c3 disassemble_command
        cli/cli-cmds.c:1611
0x55e9c2c84db5 do_simple_func
        cli/cli-decode.c:95
0x55e9c2c8a666 _Z8cmd_funcP16cmd_list_elementPKci
        cli/cli-decode.c:2514
0x55e9c32513c5 _Z15execute_commandPKci
        /opt/gdb/gdb/top.c:702
0x55e9c2f4ded3 catch_command_errors
        /opt/gdb/gdb/main.c:523
0x55e9c2f4e0e7 execute_cmdargs
        /opt/gdb/gdb/main.c:618
0x55e9c2f4f70d captured_main_1
        /opt/gdb/gdb/main.c:1320
0x55e9c2f4f943 captured_main
        /opt/gdb/gdb/main.c:1341
0x55e9c2f4f9ba _Z8gdb_mainP18captured_main_args
        /opt/gdb/gdb/main.c:1366
0x55e9c2aa53e5 main
        /opt/gdb/gdb/gdb.c:32
---------------------
A fatal error internal to GDB has been detected, further
debugging is not possible.  GDB will now terminate.

This is a bug, please report it.  For instructions, see:
<https://www.gnu.org/software/gdb/bugs/>.

```

To run gdb within gdb, for debugging, run something like this:

```bash
❯ docker run --rm -i -t gdb-arm-dis-crash-repro bash -c \
    "gdb --args /opt/gdb/gdb/gdb /opt/example-semihosting.elf -batch --ex 'disassemble 0x8003c44,+2'"
```
