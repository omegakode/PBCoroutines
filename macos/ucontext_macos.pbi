ImportC ""
	swapcontext(a.i, b.i)
	getcontext(ctx.i)
	makecontext(c.i, f.i, pc.l, p1.L, p2.l)
	setcontext(c.i)
EndImport

#_XOPEN_SOURCE = 1

Structure stack_t Align #PB_Structure_AlignC
	ss_sp.i ;void *     /* signal stack base */
	ss_size.l; __darwin_size_t       /* signal stack length */
	ss_flags.l ;int      /* SA_DISABLE And/Or SA_ONSTACK */
EndStructure 

Structure _STRUCT_X86_EXCEPTION_STATE64 Align #PB_Structure_AlignC
	__trapno.w ;__uint16_t
	__cpu.w ;__uint16_t
	__err.l ;__uint32_t
	__faultvaddr.q ;__uint64_t
EndStructure

Structure _STRUCT_X86_THREAD_STATE64 Align #PB_Structure_AlignC
		__rax.q;__uint64_t
		__rbx.q;__uint64_t
		__rcx.q;__uint64_t
		__rdx.q;__uint64_t
		__rdi.q;__uint64_t
		__rsi.q;__uint64_t
		__rbp.q;__uint64_t
		__rsp.q;__uint64_t
		__r8.q;__uint64_t
		__r9.q;__uint64_t
		__r10.q;__uint64_t
		__r11.q;__uint64_t
		__r12.q;__uint64_t
		__r13.q;__uint64_t
		__r14.q;__uint64_t
		__r15.q;__uint64_t
		__rip.q;__uint64_t
		__rflags.q;__uint64_t
		__cs.q;__uint64_t
		__fs.q;__uint64_t
		__gs.q;__uint64_t
EndStructure

Structure _STRUCT_MMST_REG Align #PB_Structure_AlignC
		__mmst_reg.b[10];char
		__mmst_rsrv.b[6];char
EndStructure

Structure _STRUCT_XMM_REG Align #PB_Structure_AlignC
	__xmm_reg.b[16];char
EndStructure

Structure _STRUCT_X86_FLOAT_STATE64 Align #PB_Structure_AlignC
	__fpu_reserved.l[2]; int
		__fpu_fcw.w;_STRUCT_FP_CONTROL		/* x87 FPU control word */
		__fpu_fsw.w;_STRUCT_FP_STATUS		/* x87 FPU status word */
			__fpu_ftw.b;__uint8_t		/* x87 FPU tag word */
			__fpu_rsrv1.b;__uint8_t		/* reserved */ 
			__fpu_fop.w;__uint16_t		/* x87 FPU Opcode */

	;/* x87 FPU Instruction Pointer */
			__fpu_ip.l;__uint32_t		/* offset */
			__fpu_cs.w;__uint16_t		/* Selector */

			__fpu_rsrv2.w;__uint16_t		/* reserved */

	;/* x87 FPU Instruction Operand(Data) Pointer */
			__fpu_dp.l;__uint32_t		/* offset */
			__fpu_ds.w;__uint16_t		/* Selector */

			__fpu_rsrv3.w;__uint16_t		/* reserved */
			__fpu_mxcsr.l;__uint32_t		/* MXCSR Register state */
			__fpu_mxcsrmask.l;__uint32_t	/* MXCSR mask */
		__fpu_stmm0._STRUCT_MMST_REG;		/* ST0/MM0   */
		__fpu_stmm1._STRUCT_MMST_REG;		/* ST1/MM1  */
		__fpu_stmm2._STRUCT_MMST_REG;		/* ST2/MM2  */
		__fpu_stmm3._STRUCT_MMST_REG;		/* ST3/MM3  */
		__fpu_stmm4._STRUCT_MMST_REG;		/* ST4/MM4  */
		__fpu_stmm5._STRUCT_MMST_REG;		/* ST5/MM5  */
		__fpu_stmm6._STRUCT_MMST_REG;		/* ST6/MM6  */
		__fpu_stmm7._STRUCT_MMST_REG;		/* ST7/MM7  */
			__fpu_xmm0._STRUCT_XMM_REG;		/* XMM 0  */
			__fpu_xmm1._STRUCT_XMM_REG;		/* XMM 1  */
			__fpu_xmm2._STRUCT_XMM_REG;		/* XMM 2  */
			__fpu_xmm3._STRUCT_XMM_REG;		/* XMM 3  */
			__fpu_xmm4._STRUCT_XMM_REG;		/* XMM 4  */
			__fpu_xmm5._STRUCT_XMM_REG;		/* XMM 5  */
			__fpu_xmm6._STRUCT_XMM_REG;		/* XMM 6  */
			__fpu_xmm7._STRUCT_XMM_REG;		/* XMM 7  */
			__fpu_xmm8._STRUCT_XMM_REG;		/* XMM 8  */
			__fpu_xmm9._STRUCT_XMM_REG;		/* XMM 9  */
			__fpu_xmm10._STRUCT_XMM_REG;		/* XMM 10  */
			__fpu_xmm11._STRUCT_XMM_REG;		/* XMM 11 */
			__fpu_xmm12._STRUCT_XMM_REG;		/* XMM 12  */
			__fpu_xmm13._STRUCT_XMM_REG;		/* XMM 13  */
			__fpu_xmm14._STRUCT_XMM_REG;		/* XMM 14  */
			__fpu_xmm15._STRUCT_XMM_REG;		/* XMM 15  */
	__fpu_rsrv4.b[6*16];char	/* reserved */
	__fpu_reserved1.l;int
EndStructure

Structure mcontext_t Align #PB_Structure_AlignC ;_STRUCT_MCONTEXT64
	__es._STRUCT_X86_EXCEPTION_STATE64
	__ss._STRUCT_X86_THREAD_STATE64
	__fs._STRUCT_X86_FLOAT_STATE64
EndStructure

Structure ucontext_t Align #PB_Structure_AlignC
	uc_onstack.l ;int
	uc_sigmask.l;__darwin_sigset_t    /* signal mask used by this context */
	uc_stack.stack_t;_STRUCT_SIGALTSTACK       /* stack used by this context */
	*uc_link.ucontext_t;_STRUCT_UCONTEXT      /* pointer to resuming context */
	uc_mcsize.l ;__darwin_size_t      /* size of the machine context passed in */
	*uc_mcontext.mcontext_t;_STRUCT_MCONTEXT  /* pointer to machine specific context */
CompilerIf Defined(_XOPEN_SOURCE, #PB_Constant)
	__mcontext_data.mcontext_t;_STRUCT_MCONTEXT
CompilerEndIf
EndStructure 

;- TEST
; EnableExplicit
; 
; Global.ucontext_t main_context, func_context
; 
; ProcedureC func1(a.i)
; 	Debug #PB_Compiler_Procedure
; 	
; 	Debug a
; 	swapcontext(@func_context, @main_context)
; 	
; 	Debug "back"
; EndProcedure
; 
; 
; Procedure main()
; 	Protected.i stack
; 	
; 	getcontext(@main_context)
; 	
; 	stack = AllocateMemory(8192)
; 	
; 	getcontext(@func_context)
;   func_context\uc_stack\ss_sp = stack
; 	func_context\uc_stack\ss_size = 8192
; 	func_context\uc_link = @main_context
; 	
; 	makecontext(@func_context, @func1(), 1, 10)
; 	swapcontext(@main_context, @func_context)
; 	Debug "back 2"
; EndProcedure
; 
; main()


