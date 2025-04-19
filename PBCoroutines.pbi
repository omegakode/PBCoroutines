;PBCoroutines2.pbi

XIncludeFile "asm.pb"

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
	XIncludeFile "windows\winnt.pbi"

CompilerElseIf #PB_Compiler_OS = #PB_OS_Linux
	XIncludeFile "linux/aco.pbi"
	
CompilerElseIf #PB_Compiler_OS = #PB_OS_MacOS
	XIncludeFile "macos/ucontext_macos.pbi"
CompilerEndIf

#CO_STACK_SIZE  = (64 * 1024)

Prototype co_func(co.i)
Prototype co_destroyCb(co.i)

;- Enum #CO_CREATE_FLAG_
EnumerationBinary
	#CO_CREATE_FLAG_AUTO_DESTROY
	#CO_CREATE_FLAG_AUTO_RESUME
EndEnumeration

;- Enum #CO_STATE_
Enumeration 0
	#CO_STATE_IDLE
	#CO_STATE_SCHEDULED
	#CO_STATE_FINISHED
EndEnumeration

;- co_coroutine_t
Structure co_coroutine_t Align #PB_Structure_AlignC
	CompilerIf #PB_Compiler_OS = #PB_OS_Windows
		fiber.i
		caller.i
		
	CompilerElseIf #PB_Compiler_OS = #PB_OS_Linux
		*co.aco_t
    *caller.aco_t
    
	CompilerElseIf #PB_Compiler_OS = #PB_OS_MacOS
    ctx.ucontext_t
    *caller.ucontext_t
    stack.i
	CompilerEndIf

  func.co_func
  destroyCb.co_destroyCb
  window.i
  arg.i
  state.l
  flags.l
EndStructure

Declare.i co_create(func.co_func, arg.i, flags.l, window.i, destroyCb.co_destroyCb)
Declare.l co_resume( *co.co_coroutine_t)
Declare.l co_yield(*co.co_coroutine_t)
Declare.i co_get_arg(*co.co_coroutine_t)
Declare.i co_put_arg(*co.co_coroutine_t, arg.i)
Declare.l co_destroy(*co.co_coroutine_t)
Declare.l co_get_state(*co.co_coroutine_t)





