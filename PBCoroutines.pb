;PBCoroutines.pb

EnableExplicit

XIncludeFile "PBCoroutines.pbi"

;- WINDOWS
CompilerIf #PB_Compiler_OS = #PB_OS_Windows
	Procedure.l _co_trampoline(*co.co_coroutine_t)		
	  *co\func(*co)
	  *co\finished = 1
	  SwitchToFiber_(*co\caller) ;Yield back to the caller
	EndProcedure
	
;- LINUX
CompilerElseIf #PB_Compiler_OS = #PB_OS_Linux
	Procedure.l _co_trampoline()
		Protected.aco_t *aco
		Protected.co_coroutine_t *co
		
		*aco = aco_get_gtls_co()
		*co = *aco\arg
		
	  *co\func(*co)
	  *co\finished = 1
	  aco_exit(*co\co)
	EndProcedure
	
;- MACOS
CompilerElseIf #PB_Compiler_OS = #PB_OS_MacOS
	Procedure.l _co_trampoline(low.l, high.l)
		Protected.co_coroutine_t *co
				
		*co = (high << 32) | low
		*co\func(*co)
		*co\finished = 1
		setcontext(*co\caller) ;Return to caller
	EndProcedure
CompilerEndIf

;-
Procedure.i co_create(func.co_func, arg.i)
	Protected.co_coroutine_t *co
	
	*co = AllocateMemory(SizeOf(co_coroutine_t))
	*co\func = func
	*co\arg = arg
	*co\finished = 0
		
	CompilerIf #PB_Compiler_OS = #PB_OS_Windows
		*co\caller = ConvertThreadToFiber_(#Null) ;Main thread becomes a fiber
		If *co\caller = 0 ;Main thread is already a fiber
			*co\caller = GetCurrentFiber()
		EndIf 
		
		;Create a new fiber for the coroutine
		*co\fiber = CreateFiber_(0, @_co_trampoline(), *co)
		
	CompilerElseIf #PB_Compiler_OS = #PB_OS_Linux
		Static.l initialized
    Static.i mainThread, stack
    
    If initialized = 0
			aco_thread_init(#Null)
			mainThread = aco_create(#Null, #Null, 0, #Null, #Null)
			stack = aco_share_stack_new(0)
			initialized = 1
		EndIf 

    *co\caller = aco_get_gtls_co()
    If *co\caller = 0
    	*co\caller = mainThread
    EndIf
    *co\co = aco_create(mainThread, stack, 0, @_co_trampoline(), *co)
    
	CompilerElseIf #PB_Compiler_OS = #PB_OS_MacOS
		*co\stack = AllocateMemory(#CO_STACK_SIZE)
		*co\caller = AllocateMemory(SizeOf(ucontext_t))

		getcontext(@*co\ctx)
		*co\ctx\uc_stack\ss_sp = *co\stack
		*co\ctx\uc_stack\ss_size = #CO_STACK_SIZE
		*co\ctx\uc_link = 0

		makecontext(@*co\ctx, @_co_trampoline(), 2, *co, *co >> 32)
	CompilerEndIf
	
	ProcedureReturn *co
EndProcedure

Procedure.l co_resume(*co.co_coroutine_t)
	If *co\finished
		ProcedureReturn
	EndIf 

	CompilerIf #PB_Compiler_OS = #PB_OS_Windows
		SwitchToFiber_(*co\fiber) ;Switch to the coroutine's fiber
		
	CompilerElseIf #PB_Compiler_OS = #PB_OS_Linux
		aco_resume(*co\co)
		
	CompilerElseIf #PB_Compiler_OS = #PB_OS_MacOS
		swapcontext(*co\caller, @*co\ctx)
	CompilerEndIf
EndProcedure

Procedure.l co_yield(*co.co_coroutine_t)
	CompilerIf #PB_Compiler_OS = #PB_OS_Windows
		SwitchToFiber_(*co\caller) 

	CompilerElseIf #PB_Compiler_OS = #PB_OS_Linux
		aco_yield(*co\co)

	CompilerElseIf #PB_Compiler_OS = #PB_OS_MacOS
		swapcontext(@*co\ctx, *co\caller)
	CompilerEndIf
EndProcedure

Procedure.l co_finished(*co.co_coroutine_t)
	ProcedureReturn *co\finished
EndProcedure

Procedure.l co_destroy(*co.co_coroutine_t)
	CompilerIf #PB_Compiler_OS = #PB_OS_Windows
		DeleteFiber_(*co\fiber) 

	CompilerElseIf #PB_Compiler_OS = #PB_OS_Linux
 		aco_destroy(*co\co)
 		
	CompilerElseIf #PB_Compiler_OS = #PB_OS_MacOS
		FreeMemory(*co\stack)
		FreeMemory(*co\caller)
		
	CompilerEndIf

	FreeMemory(*co)
EndProcedure

Procedure.i co_get_arg(*co.co_coroutine_t)
	ProcedureReturn *co\arg
EndProcedure

Procedure.i co_put_arg(*co.co_coroutine_t, arg.i)
	Protected.i oldArg
	
	oldArg = *co\arg
	*co\arg = arg
	ProcedureReturn oldArg
EndProcedure



