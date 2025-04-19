EnableExplicit

XIncludeFile "PBCoroutines.pb"

Procedure.l my_task1(co.i) 
	Debug "Task1: Step 1 "
	Debug co_get_arg(co)
	
	co_yield(co)
	Debug "Task1: Step 2 End"
EndProcedure

Procedure.l my_task2(co.i)
	Debug "Task2: Step 1 " 
	
	co_yield(co)
	
	Debug "Task2: Step 2 End "
EndProcedure

Procedure main()
	Protected.i co, co2
	
	co = co_create(@my_task1(), 10, 0, 0, 0)
	co2 = co_create(@my_task2(), 20, 0, 0, 0)

	Debug "Main: Resume Task1"
	co_resume(co)
	Debug "Main: Back from Task1"
	Debug "Main: Resume Task2"
	co_resume(co2)
	Debug "Main: Back from Task2"
	Debug "Main: Resume Task1"
	co_resume(co)
	Debug "Main: Back from Task1"
	Debug "Main: Resume Task2"
	co_resume(co2)

	co_destroy(co)
	co_destroy(co2)
EndProcedure

main()