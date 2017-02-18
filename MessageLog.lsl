list messageList = [];
integer x;

default
{
	state_entry()
	{

	}
	link_message(integer sender_num, integer num, string msg, key id)
	{
		llOwnerSay(msg);
		if (msg == "clear") {
			llOwnerSay("clearing all messages");
			messageList = [];
		}
		else if (msg == "read") {
			integer numOfMessages = llGetListLength(messageList);
			llOwnerSay((string)numOfMessages);
			for(x = 0; x > numOfMessages; x++) {
				llOwnerSay("test");
				llOwnerSay(llList2String(messageList, x));
			}
		}
		else {
			messageList += llParseString2List(msg,[],[]);
		}
	}
}