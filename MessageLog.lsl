key userKey;
list messageList = ["test", "Test2"];
integer messageIndex = 0;

integer inRange(integer z, integer y) {
	if (z > y) {
		return 1;
	}
	else {
		return 0;
	}
}

default
{
	state_entry()
	{
		userKey = llGetOwnerKey(llGetOwner());
	}
	link_message(integer sender_num, integer num, string msg, key id)
	{
		integer numOfMessages = llGetListLength(messageList) -1;
		if(userKey == id) {
			if (msg == "next") {
				llOwnerSay("i hit next current index" + (string)messageIndex + "| number of messages" + (string)numOfMessages);
				++messageIndex;
				if(inRange(messageIndex, numOfMessages)) {
					messageIndex = 0;
				}
				llOwnerSay(llList2String(messageList, messageIndex));
			}
			else if (msg == "delete") {
				messageList = llDeleteSubList(messageList, messageIndex, messageIndex);
				llOwnerSay("message " + llList2String(messageList, messageIndex) + "has been deleted");
				--messageIndex;
			}
			else if (msg == "delete all") {
				messageList = [];
			}
			else if (msg == "read"){
				llOwnerSay(llList2String(messageList, messageIndex));
			}
		}
		else {
			messageList += llParseString2List(msg,[],[]);
			llOwnerSay("Your message has been saved");
		}
	}
}