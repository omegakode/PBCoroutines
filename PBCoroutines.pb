;PBCoroutines.pb

EnableExplicit

XIncludeFile "PBCoroutines.pbi"

;- WINDOWS
CompilerIf #PB_Compiler_OS = #PB_OS_Windows
	Procedure.l _co_cleanup_cb(hwnd.i, msg.l, *co.co_coroutine_t, time.l)		
		If *co\destroyCb : *co\destroyCb(*co) : EndIf

		If *co\flags & #CO_CREATE_FLAG_AUTO_DESTROY
			co_destroy(*co)
		EndIf
		
		KillTimer_(hwnd, *co)
	EndProcedure
	
	Procedure.l _co_trampoline(*co.co_coroutine_t)		
	  *co\func(*co)
	  *co\state = #CO_STATE_FINISHED
		
		If *co\window
			SetTimer_(*co\window, *co, 0, @_co_cleanup_cb())
		EndIf 
	  SwitchToFiber_(*co\caller) ;Yield back to the caller
	EndProcedure
	
;- LINUX
CompilerElseIf #PB_Compiler_OS = #PB_OS_Linux
	Procedure.l _co_cleanup_cb(*co.co_coroutine_t)
		If *co\destroyCb : *co\destroyCb(*co) : EndIf

		If *co\flags & #CO_CREATE_FLAG_AUTO_DESTROY
			co_destroy(*co)
		EndIf
		
		ProcedureReturn #False ;Run only once
	EndProcedure
	
	Procedure.l _co_trampoline()
		Protected.aco_t *aco
		Protected.co_coroutine_t *co
		
		*aco = aco_get_gtls_co()
		*co = *aco\arg
		
	  *co\func(*co)
	  *co\state = #CO_STATE_FINISHED
	  
	  If *co\window
			g_idle_add_(@_co_cleanup_cb(), *co)
		EndIf 
	  aco_exit(*co\co)
	EndProcedure
	
;- MACOS
CompilerElseIf #PB_Compiler_OS = #PB_OS_MacOS
	Procedure.l _co_trampoline(*co.co_coroutine_t)
		*co\func(*co)
	  *co\state = #CO_STATE_FINISHED
		setcontext(*co\caller) ;Return to caller
	EndProcedure
CompilerEndIf

;-
Procedure.i co_create(func.co_func, arg.i, flags.l, window.i, destroyCb.co_destroyCb)
	Protected.co_coroutine_t *co
	
	If destroyCb <> 0 And window = 0
		ProcedureReturn 0
	EndIf
	
	*co = AllocateMemory(SizeOf(co_coroutine_t))
	*co\func = func
	*co\arg = arg
	*co\state = #CO_STATE_IDLE
	*co\flags = flags
	*co\destroyCb = destroyCb
	*co\window = window
		
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

		makecontext(@*co\ctx, @_co_trampoline(), 1, *co)
	CompilerEndIf
	
	If *co\flags & #CO_CREATE_FLAG_AUTO_RESUME
		co_resume(*co)
	EndIf
	
	ProcedureReturn *co
EndProcedure

Procedure.l co_resume(*co.co_coroutine_t)
	If *co\state = #CO_STATE_FINISHED
		ProcedureReturn
	EndIf 

	*co\state = #CO_STATE_SCHEDULED
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

Procedure.l co_get_state(*co.co_coroutine_t)
	ProcedureReturn *co\state
EndProcedure



