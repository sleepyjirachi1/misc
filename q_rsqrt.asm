;  ==========================================================
;  Q_rsqrt (Quake III, x86_64, NASM)
;
;  Build:
;    nasm -f elf64 q_rsqrt.asm -o q_rsqrt.o
;    gcc -m64 -o q_rsqrt q_rsqrt.o -lc -no-pie
;
;  Author: Autumn		                            12/04/26       
; ==========================================================

BITS 64

global main
extern printf

section .text
main:
	movss xmm0, [number]
	call q_rsqrt

	; printf needs values ordered
	movss xmm1, xmm0
	movss xmm0, [number]

    ; printf only accepts scalar doubles
	cvtss2sd xmm0, xmm0
	cvtss2sd xmm1, xmm1

print:
	sub rsp, 8            ; Padding to ensure 16-byte alignment for printf

	mov rdi, msg          ; const char *fmt
	mov rax, 2            ; Number of XMM register args for printf call (2)
	call printf

	add rsp, 8            ; Remove earlier padding

	xor eax, eax          ; Exit success (return 0)
	ret

q_rsqrt:
    ; x2 = number -> xmm1
	movss xmm1, xmm0      

	; x2 = x2 * 0.5 -> xmm1
	mov eax, 0x3F000000
	movd xmm2, eax
	mulss xmm1, xmm2

	; i = * ( long * ) &y -> eax (long used to be 32 bit lol)
	movd eax, xmm0

	; i = 0x5f3759df - (i >> 1) -> edx
	shr eax, 1
	mov edx, 0x5f3759df
	sub edx, eax

	; y = * ( float * ) &i -> xmm0
	movd xmm0, edx
	
	; y = y * ( threehalfs - ( x2 * y * y ) )
	movss xmm2, [threehalfs]
	mulss xmm1, xmm0
	mulss xmm1, xmm0
	subss xmm2, xmm1
	mulss xmm0, xmm2

	ret

section .rodata
	number: dd 5.0        ; Hardcoded number argument for q_rsqrt
	threehalfs: dd 1.5    ; Just here to respect the original :p

	msg: db "1 / sqrt(%f) ~= %f", 10, 0

