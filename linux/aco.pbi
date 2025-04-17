;aco.pbi

#CO_LIB_PATH = #PB_Compiler_Home + "purelibraries" + #PS$ + "userlibraries" + #PS$

ImportC #CO_LIB_PATH + "libaco.a"
	aco_thread_init.l(p.i)
	aco_create_thread.i(arg.i, shareStack.i)
	aco_create.i(main_co.i, share_stack.i, save_stack_sz.l, co_fp.i, arg.i)
	aco_resume.l(co.i)
	aco_destroy.l(co.i)
	aco_share_stack_new.i(sz.l)
	aco_share_stack_destroy.l(st.i)
	acosw.i(from_co.i, to_co.i)
	aco_get_gtls_co.i()
EndImport

;- aco_save_stack_t
Structure aco_save_stack_t Align #PB_Structure_AlignC
	ptr.i
	sz.i
	valid_sz.i
	max_cpsz.i
	ct_save.i
	ct_restore.i
EndStructure

;- aco_share_stack_t
Structure aco_share_stack_t Align #PB_Structure_AlignC
	ptr.i          
	sz.i
	align_highptr.i
	align_retptr.i
	align_validsz.i
	align_limit.i
	owner.i
	guard_page_enabled.a
	real_ptr.i
	real_sz.i
	CompilerIf Defined(ACO_USE_VALGRIND, #PB_Constant)
		valgrind_stk_id.l
	CompilerEndIf
EndStructure

;- aco_t
Structure aco_t Align #PB_Structure_AlignC
	;cpu registers' state
	CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
		CompilerIf Defined(ACO_CONFIG_SHARE_FPU_MXCSR_ENV, #PB_Constant)
			reg.i[6]
		CompilerElse
			reg.i[8]
		CompilerEndIf
		
	CompilerElseIf  #PB_Compiler_Processor = #PB_Processor_x64 
		CompilerIf Defined(ACO_CONFIG_SHARE_FPU_MXCSR_ENV, #PB_Constant)
			reg.i[8]
		CompilerElse
			reg.i[9]
		CompilerEndIf
	CompilerEndIf
	
	*main_co.aco_t
	arg.i
	is_end.a
	fp.i
	save_stack.aco_save_stack_t
	*share_stack.aco_share_stack_t
EndStructure

Macro aco_yield(yield_co)
	acosw(yield_co, yield_co\main_co)
EndMacro

Macro aco_exit(co)
	co\is_end = 1
	co\share_stack\owner = #Null
	co\share_stack\align_validsz = 0
	aco_yield(co)         
EndMacro

  