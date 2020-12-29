.section ".text.boot"
 
// Make _start global.
.globl _boot
 
_boot:
    // This program focuses on only core #3.
    // The other cores will return.
    mrs   x1, mpidr_el1
    and   x1, x1, #3
    cmp   x1, #3
    bne   kick_core3

start_el1:
    // set sp
    adrp  x1, stack_top
    mov   sp, x1
    // clear bss.
    ldr   x1, =__bss_start
    ldr   w2, =__bss_size
1:  cbz   w2, 2f
    str   xzr, [x1], #8
    sub   w2, w2, #1
    cbnz  w2, 1b

2:  bl main
	ret

kick_core3:
	mov   x1, #0xF0 // See https://github.com/raspberrypi/tools/blob/master/armstubs/armstub8.S
	ldr   x2, =__start
	str   x2, [x1]
    sev
	mov   x0, #0x0
	ret
