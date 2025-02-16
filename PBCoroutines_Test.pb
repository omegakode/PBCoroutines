;PBCoroutines_Test.pb

EnableExplicit

XIncludeFile "PBCoroutines.pb"

Procedure.l co_function(*co.co_handle)
	Protected.l x
	
	Debug "co_function start"
	
	x = 0
	
	For x = 1 To 5
		Debug "co_function " + Str(x)
		
		co_put_arg(*co, x)
		co_yield(*co) ;switch to main
	Next 
	
	Debug "co_function end"
	
	co_exit(*co)
EndProcedure

Procedure main()
	Protected.co_handle *mainCo, *co
	
	co_lib_init() ;init lib
	
	co_thread_init() ;init thread
	
	;main coroutine
	*mainCo = co_create(#Null, #Null, #Null)
	
	;child coroutine
	*co = co_create(*mainCo, @co_function(), 0)

	While Not co_ended(*co)
		co_resume(*co) ;switch to co_function
		
		If Not co_ended(*co) ;check if ended after last resume
			Debug "main " + Str(co_get_arg(*co))
		EndIf
	Wend 

	Debug "main done"
	
	co_destroy(*co)
	
	co_lib_shutdown() ;close lib
EndProcedure

main()

