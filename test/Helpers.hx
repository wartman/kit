function print(message:String) {
	#if (js && !nodejs)
	trace(message);
	#else
	Sys.println(message);
	#end
}
// @todo: Other simple test stuff
