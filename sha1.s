.global sha1_chunk

sha1_chunk:
	pushq %rbp          # pushing base pointer to the stack
	movq %rsp, %rbp     # base pointer pointing at the same location as the stack pointer
	
	push %r12			# storing callee-saved registers on stack
	push %r13
	push %r14
	push %r15

	movq $16, %rcx		# initializing 'i' to 16
	movq %rsi, %r8		# copying the addres of w[0] to register r8
	addq $64, %r8 		# changing the address pointing to w[0] to point to w[16]

extendloop:
	movl -12(%r8), %edx		# z = w[i-3]
	xor -32(%r8), %edx 		# z = w[i-3] xor w[i-8]
	xor -56(%r8), %edx		# z = w[i-3] xor w[i-8] xor w[i-14]
	xor -64(%r8), %edx		# z = w[i-3] xor w[i-8] xor w[i-14] xor w[i-16]
	rol $1, %edx			# z = (w[i-3] xor w[i-8] xor w[i-14] xor w[i-16]) leftrotate 1

	movl %edx, (%r8)		# w[i] = z

	add $4, %r8			# continuing to w[i+1]
	inc %rcx			# incrementing i
	cmp $79, %rcx		# looping as long as i<=79
	jle extendloop

	
	movl (%rdi), %r10d		# initializing 'a' to the value of h0
	movl 4(%rdi), %r11d		# initializing 'b' to the value of h1
	movl 8(%rdi), %r12d	# initializing 'c' to the value of h2
	movl 12(%rdi), %r13d	# initializing 'd' to the value of h3
	movl 16(%rdi), %r14d	# initializing 'e' to the value of h4

	xor %rcx, %rcx			# initializing 'i' to 0


mainloop:

	cmp $19, %rcx
	jle option1

	cmp $39, %rcx
	jle option2

	cmp $59, %rcx
	jle option3

	cmp $79, %rcx
	jle option4

endofmainloop:

	movl %r10d, %r9d	# temp = a
	roll $5, %r9d		# temp = (a leftrotate 5)
	addl %r15d, %r9d	# temp = (a leftrotate 5) + f
	addl %r14d, %r9d	# temp = (a leftrotate 5) + f + e
	addl %eax, %r9d		# temp = (a leftrotate 5) + f + e + k
	addl (%rsi), %r9d	# temp = (a leftrotate 5) + f + e + k + w[i]

	movl %r13d, %r14d	# e = d
	movl %r12d, %r13d	# d = c
    
	movl %r11d, %r12d	# c = b
	roll $30, %r12d		# c = b leftrotate 30

	movl %r10d, %r11d   # b = a
	movl %r9d, %r10d	# a = temp


	addq $4, %rsi		# continuing to w[i+1]
	inc %rcx			# i++
	cmpq $79, %rcx		# looping as long as i<=79
	jle mainloop

	addl %r10d, (%rdi)		# h0 = h0 + a
	addl %r11d, 4(%rdi)		# h1 = h1 + b
	addl %r12d, 8(%rdi) 	# h2 = h2 + c
	addl %r13d, 12(%rdi) 	# h3 = h3 + d
	addl %r14d, 16(%rdi)	# h4 = h4 + e


	popq %r15				# these registers are callee-saved so we have to restore their value
	popq %r14
	popq %r13
	popq %r12


	movq $0, %rax       # the function returns no value
	movq %rbp, %rsp
	popq %rbp           # restoring the old stack state
	
	ret

# END OF THE SHA1 CHUNK FUNCTION



option1:

	mov %r11d, %r8d		# y = b
	and %r12d, %r8d     # y = b and c
	mov %r11d, %r15d    # f = b
	not %r15d 			# f = not b
	and %r13d, %r15d    # f = (not b) and d
	or %r8d, %r15d      # f = (b and c) or ((not b) and d)
	mov $0x5A827999, %eax  # initializing 'k' to a hex value
	jmp endofmainloop

option2:

	mov %r11d, %r15d	# f = b
	xor %r12d, %r15d	# f = b xor c
	xor %r13d, %r15d	# f = b xor c xor d

	mov $0x6ED9EBA1, %eax  # initializing 'k' to a hex value
	jmp endofmainloop

option3:

	mov %r11d, %r8d		# y = b
	and %r12d, %r8d     # y = b and c

	mov %r11d, %r15d    # f = b
	and %r13d, %r15d    # f = b and d

	or %r8d, %r15d		# f = (b and c) or (b and d)

	mov %r12d, %r8d		# y = c
	and %r13d, %r8d 	# y = c and d

	or %r8d, %r15d 		# f = (b and c) or (b and d) or (c and d)

	mov $0x8F1BBCDC, %eax  # initializing 'k' to a hex value
	jmp endofmainloop

option4:

	mov %r11d, %r15d	# f = b
	xor %r12d, %r15d	# f = b xor c
	xor %r13d, %r15d	# f = b xor c xor d


	mov $0xCA62C1D6, %eax  # initializing 'k' to a hex value
	jmp endofmainloop

