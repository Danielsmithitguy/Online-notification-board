list messageList = [];
list savedMessages = [];
integer x;
integer isUserReading = 0;
integer isUserReadingSaved = 0;
integer messageIndex = 0;
integer savedMessageIndex = 0;

readMessage(string msg){
	llOwnerSay(msg);
}

integer inRange(integer z, integer y) {
	if (z >= y) {
		return 0;
	}
	else {
		return z;
	}
}

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
			isUserReading = 1;
			integer numOfMessages = llGetListLength(messageList);
			integer numOfSavedMessages = llGetListLength(savedMessages);
			llOwnerSay((string)numOfMessages);
			while(isUserReading){
				if(numOfMessages != 0 && numOfSavedMessages != 0) {
					if(msg == "next") {
						readMessage(llList2String(messageList, messageIndex));
						messageIndex++;
						if (inRange(savedMessageIndex, numOfSavedMessages) == 0) {
							savedMessageIndex = 0;
						}

					} else if (msg == "save"){
							savedMessages += llParseString2List(msg,[],[]);
						llOwnerSay("message has been saved");
					} else if (msg == "exit"){
							isUserReading = 0;
					}
				} else if (msg == "saved") {
						isUserReadingSaved = 1;
					while(isUserReadingSaved){
						if(numOfSavedMessages > 0) {
							if(msg == "next") {
								readMessage(llList2String(savedMessages, savedMessageIndex));
								savedMessageIndex++;
								if (inRange(savedMessageIndex, numOfSavedMessages) == 0) {
									savedMessageIndex = 0;
								}

							} else if (msg == "exit"){
									isUserReadingSaved = 0;
							}
						} else {
								llOwnerSay("sorry no saved messages at this time");
							isUserReadingSaved = 0;
						}
					}
				} else {
						llOwnerSay("sorry no messages to be read at this time");
					isUserReading = 0;
				}
			}

			//for(x = 0; x > numOfMessages; x++) {
			//	llOwnerSay("test");
			//	llOwnerSay(llList2String(messageList, x));
			//}
		} else {
				messageList += llParseString2List(msg,[],[]);
		}
	}
}
