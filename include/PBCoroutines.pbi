;PBCoroutines.pbi

CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
	Debug "Error, macos not supported"
	End
CompilerEndIf

CompilerIf #PB_Compiler_OS = #PB_OS_Linux And #PB_Compiler_Processor = #PB_Processor_x86
	Debug "Error, only linux 64 bit supported"
	End
CompilerEndIf

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
	XIncludeFile "windows\winnt.pbi"

CompilerElseIf #PB_Compiler_OS = #PB_OS_Linux
	XIncludeFile "linux/aco.pbi"

CompilerElseIf #PB_Compiler_OS = #PB_OS_MacOS

CompilerEndIf

;- co_handle
Structure co_handle
	CompilerIf #PB_Compiler_OS = #PB_OS_Windows
		mainCo.i ;fiber
		thisCo.i ;fiber
		isEnd.b

	CompilerElseIf #PB_Compiler_OS = #PB_OS_Linux
		*mainCo.aco_t
		*thisCo.aco_t
		
	CompilerElseIf #PB_Compiler_OS = #PB_OS_MacOS
	
	CompilerEndIf
	
	arg.i
EndStructure

;- co_global
Structure co_global
	CompilerIf #PB_Compiler_OS = #PB_OS_Windows
		dummy.i
		
	CompilerElseIf #PB_Compiler_OS = #PB_OS_Linux
		*shareStack.aco_share_stack_t
		
	CompilerElseIf #PB_Compiler_OS = #PB_OS_MacOS
	
	CompilerEndIf
EndStructure

