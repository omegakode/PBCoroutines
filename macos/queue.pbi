;queue.pbi

ImportC ""
	dispatch_get_global_queue.i(id.i, flags.i)
	dispatch_async_f(queue.i, context.i, work.i)
	dispatch_sync(queue.i, block.i)
	dispatch_async_and_wait(queue.i, block.i)
	_dispatch_main_q
EndImport

Macro dispatch_get_main_queue()
	@_dispatch_main_q
EndMacro

#DISPATCH_QUEUE_PRIORITY_HIGH = 2
#DISPATCH_QUEUE_PRIORITY_DEFAULT = 0
#DISPATCH_QUEUE_PRIORITY_LOW = -2
#DISPATCH_QUEUE_PRIORITY_BACKGROUND = -32768