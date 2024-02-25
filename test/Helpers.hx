function print(message:String) {
	#if (js && !nodejs)
	trace(message);
	#else
	Sys.println(message);
	#end
	return message;
}
// @todo: Other simple test stuff
