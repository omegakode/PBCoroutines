;winnt.pbi

;- _NT_TIB
Structure _NT_TIB Align #PB_Structure_AlignC
	ExceptionList.i
	StackBase.i
	StackLimit.i
	SubSystemTib.i
	StructureUnion
  	FiberData.i
    Version.l
	EndStructureUnion
	ArbitraryUserPointer.i
	*Self._NT_TIB
EndStructure

CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
	Import "ntdll.lib"
		NtCurrentTeb()
	EndImport
	
CompilerElse ;X64
	Procedure.i NtCurrentTeb()
		Protected.i teb
		
		CompilerIf #PB_Compiler_Backend  = #PB_Backend_C
			asm_begin()
				!"mov rax, gs:[0x30];"
				!"mov %[teb], rax;"
		 		asm_out(teb) 
			asm_end()
							
		CompilerElse ;ASM Backend
			!mov rax, [gs:0x30]
			!mov [p.v_teb], rax
		CompilerEndIf
		
		ProcedureReturn teb
	EndProcedure
	
	Procedure.i NtCurrentPeb()
		Protected.i peb
		
		CompilerIf #PB_Compiler_Backend  = #PB_Backend_C
			asm_begin()
				!"mov rax, gs:[0x60];"
				!"mov %[peb], rax;"
		 		asm_out(peb) 
			asm_end()
							
		CompilerElse ;ASM Backend
			!mov rax, [gs:0x60]
			!mov [p.v_peb], rax
		CompilerEndIf
		
		ProcedureReturn peb
	EndProcedure
CompilerEndIf 

Procedure GetCurrentFiber()
	Protected._NT_TIB *tib
	
	*tib = NtCurrentTeb()
	If *tib
		CompilerIf #PB_Compiler_Processor = #PB_Compiler_64Bit
			If *tib\Version = *tib\FiberData ;No fiber
				ProcedureReturn 0
			
			Else 
				ProcedureReturn *tib\FiberData
			EndIf 

		CompilerElse
			ProcedureReturn *tib\FiberData
		CompilerEndIf
	EndIf 
EndProcedure

Procedure GetFiberData()
	Protected._NT_TIB *tib
	
	*tib = NtCurrentTeb()
	If *tib And *tib\FiberData
		ProcedureReturn PeekI(*tib\FiberData)
	EndIf 
EndProcedure


