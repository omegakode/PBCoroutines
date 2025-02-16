;PBCoroutines.pb

EnableExplicit

XIncludeFile "include" + #PS$ + "PBCoroutines.pbi"

Procedure.i co_get_global()
	Static.co_global *cg
	
	If *cg = 0
		*cg = AllocateMemory(SizeOf(co_global))
	EndIf
	
	CompilerIf #PB_Compiler_OS = #PB_OS_Windows
		
	CompilerElseIf #PB_Compiler_OS = #PB_OS_Linux
		If *cg\shareStack = 0
			*cg\shareStack = aco_share_stack_new(0)
		EndIf 
		
	CompilerElseIf #PB_Compiler_OS = #PB_OS_MacOS
	
	CompilerEndIf

	ProcedureReturn *cg
EndProcedure

Procedure.l co_lib_init()
	co_get_global() ;init global
EndProcedure

Procedure.l co_lib_shutdown()
	Protected.co_global *cg = co_get_global()

	CompilerIf #PB_Compiler_OS = #PB_OS_Windows
	
	CompilerElseIf #PB_Compiler_OS = #PB_OS_Linux
		If *cg\shareStack
			aco_share_stack_destroy(*cg\shareStack)
			*cg\shareStack = 0
		EndIf
		
	CompilerElseIf #PB_Compiler_OS = #PB_OS_MacOS
	
	CompilerEndIf
EndProcedure

Procedure.l co_thread_init()
	CompilerIf #PB_Compiler_OS = #PB_OS_Windows
		
	CompilerElseIf #PB_Compiler_OS = #PB_OS_Linux
		aco_thread_init(0)
		
	CompilerElseIf #PB_Compiler_OS = #PB_OS_MacOS
	
	CompilerEndIf
EndProcedure

Procedure.i co_create(*mainCoHandle.co_handle, fp.i, arg.i)
	Protected.co_handle *newCoHandle
	
	*newCoHandle = AllocateMemory(SizeOf(co_handle))
	*newCoHandle\arg = arg
	
	CompilerIf #PB_Compiler_OS = #PB_OS_Windows		
		If *mainCoHandle = 0 ;Create mainCo
			*newCoHandle\mainCo = ConvertThreadToFiber_(0)
			*newCoHandle\thisCo = *newCoHandle\mainCo
			
		Else
			*newCoHandle\thisCo = CreateFiber_(0, fp, *newCoHandle)
			*newCoHandle\mainCo = *mainCoHandle\thisCo
		EndIf
		
	CompilerElseIf #PB_Compiler_OS = #PB_OS_Linux
		Protected.co_global *cg = co_get_global()
		
		If *mainCoHandle = 0 ;Create mainCo
			*newCoHandle\mainCo = aco_create(0, 0, 0, 0, 0)
			*newCoHandle\thisCo = *newCoHandle\mainCo
			
		Else
			*newCoHandle\thisCo = aco_create(*mainCoHandle\mainCo, *cg\shareStack, 0, fp, *newCoHandle)
			*newCoHandle\mainCo = *mainCoHandle\thisCo
		EndIf
		
	CompilerElseIf #PB_Compiler_OS = #PB_OS_MacOS
	
	CompilerEndIf
	
	ProcedureReturn *newCoHandle
EndProcedure

Procedure.l co_resume(*co.co_handle)
	CompilerIf #PB_Compiler_OS = #PB_OS_Windows
		SwitchToFiber_(*co\thisCo)

	CompilerElseIf #PB_Compiler_OS = #PB_OS_Linux
		aco_resume(*co\thisCo)
		
	CompilerElseIf #PB_Compiler_OS = #PB_OS_MacOS
	
	CompilerEndIf
EndProcedure

Procedure.l co_destroy(*co.co_handle)
	CompilerIf #PB_Compiler_OS = #PB_OS_Windows
		DeleteFiber_(*co\thisCo)
		
	CompilerElseIf #PB_Compiler_OS = #PB_OS_Linux
		aco_destroy(*co\thisCo)
		
	CompilerElseIf #PB_Compiler_OS = #PB_OS_MacOS
	
	CompilerEndIf
	
	FreeMemory(*co)
EndProcedure

Procedure.i co_put_arg(*co.co_handle, arg.i)
	*co\arg = arg
EndProcedure

Procedure.i co_get_arg(*co.co_handle)
	ProcedureReturn *co\arg
EndProcedure

Procedure.l co_ended(*co.co_handle)
	CompilerIf #PB_Compiler_OS = #PB_OS_Windows
		ProcedureReturn *co\isEnd
		
	CompilerElseIf #PB_Compiler_OS = #PB_OS_Linux
		ProcedureReturn *co\thisCo\is_end
		
	CompilerElseIf #PB_Compiler_OS = #PB_OS_MacOS
	
	CompilerEndIf
EndProcedure

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
	Macro co_yield(co)
		SwitchToFiber_(co\mainCo)
	EndMacro
	
	Macro co_exit(co)
		co\isEnd = 1
		co_yield(co)         
	EndMacro

CompilerElseIf #PB_Compiler_OS = #PB_OS_Linux
	Macro co_yield(co)
		aco_yield(co\thisCo)
	EndMacro
	
	Macro co_exit(co)
		aco_exit(co\thisCo)
	EndMacro
	
CompilerElseIf #PB_Compiler_OS = #PB_OS_MacOS

CompilerEndIf


