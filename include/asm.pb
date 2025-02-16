;asm.pb

Macro asm_in(var) 
  !:[var] "r" (v_#var) 
EndMacro  

Macro asm_in2(var0, var1) 
  !:[var0] "r" (v_#var0),[var1] "r" (v_#var1) 
EndMacro  

Macro asm_in3(var0, var1, var2) 
  !:[var0] "r" (v_#var0),[var1] "r" (v_#var1),[var2] "r" (v_#var2)  
EndMacro

Macro asm_out(var)
  !".att_syntax;"
  !:[var] "=r" (v_#var)
EndMacro  

Macro asm_begin() 
  !__asm__(
  !".intel_syntax noprefix;"
EndMacro

Macro asm_beginGoto() 
  !asm goto(
  !".intel_syntax noprefix;"
EndMacro 

Macro asm_end() 
  !);
EndMacro   