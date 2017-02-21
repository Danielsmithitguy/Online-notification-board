key userKey;
integer profilePrimId;
integer statusPrimId;
vector red  = <1, 0, 0>;
vector green = <0, 1, 0>;

string profile_key_prefix = "<meta name=\"imageid\" content=\"";
string profile_img_prefix = "<img alt=\"profile image\" src=\"http://secondlife.com/app/image/";
integer profile_key_prefix_length; // calculated from profile_key_prefix in state_entry()
integer profile_img_prefix_length; // calculated from profile_key_prefix in state_entry()
key lastUserInteractionKey;
integer isUserOnline;
integer currentlyListening = 0;
integer count = 0;
integer listenHandle;
integer timerInterval = 10;
integer listenLength = 3;
init()
{
	profile_key_prefix_length = llStringLength(profile_key_prefix);
	profile_img_prefix_length = llStringLength(profile_img_prefix);
	profilePrimId = Get_Linked_Number_Cal("profilePrim");
	statusPrimId = Get_Linked_Number_Cal("statusPrim");
	userKey = llGetOwnerKey(llGetOwner());
	GetProfilePic(userKey);
	IsUserOnline();
}

IsUserOnline()
{
	llRequestAgentData(userKey, DATA_ONLINE);
}

string GetProfilePic(key id) //Run the HTTP Request then set the texture
{
	string URL_RESIDENT = "http://world.secondlife.com/resident/";
	return llHTTPRequest( URL_RESIDENT + (string)id,[HTTP_METHOD,"GET"],"");
}

integer Get_Linked_Number_Cal(string input)
{
	integer primCount = llGetNumberOfPrims();
	integer i;
	for (i=0; i<primCount+1;i++)
	{
		if (llGetLinkName(i)==input) return i;
	}
	llOwnerSay("Error with Get_Linked_Number_Cal");
	return 0;
}
setBoardStatus(vector color,integer prim)
{
	llSetLinkColor(prim, color, ALL_SIDES);
}
default
{
	state_entry()
	{
		init();
		llSetTimerEvent(timerInterval);
	}
	on_rez(integer start_param)
	{
		llResetScript();
	}
	changed(integer change)
	{
		if (change & CHANGED_OWNER)
		{
			llResetScript();
		}
	}
	//was able to find this off the WIKI website, after sending a HTTP get it then strips the
	//responce down to the users UUID
	http_response(key req,integer stat, list met, string body)
	{
		integer s1 = llSubStringIndex(body, profile_key_prefix);
		integer s1l = profile_key_prefix_length;
		if(s1 == -1)
		{ // second try
			s1 = llSubStringIndex(body, profile_img_prefix);
			s1l = profile_img_prefix_length;
		}

		if(s1 == -1)
		{ // still no match?
			//SetDefaultTextures();
		}
		else
		{
			s1 += s1l;
			key UUID=llGetSubString(body, s1, s1 + 35);
			if (UUID == NULL_KEY) {
				//SetDefaultTextures();
			}
			else {
				llSetLinkTexture(profilePrimId, UUID, ALL_SIDES);
				//llSetTexture(UUID,ALL_SIDES);
			}
		}
	}
	dataserver(key queryid, string data)
	{
		if ( data == "1" )
		{
			isUserOnline = 1;
			setBoardStatus(green,statusPrimId);
		}
		else if (data == "0")
		{
			isUserOnline = 0;
			setBoardStatus(red,statusPrimId);
		}
	}
	touch_start(integer total_number)
	{
		lastUserInteractionKey = llDetectedKey(0);
		IsUserOnline();
		if (lastUserInteractionKey == userKey) {
			state ownerInteraction;
		}
		else {
			if (isUserOnline) {
				llTextBox(lastUserInteractionKey, "Please type your message here", 30);
				//llRegionSayTo(lastUserInteractionKey, 0, "Please type your message on channle 30 I.E /30 <message> ");
				listenHandle = llListen(30, "", lastUserInteractionKey, "");
				currentlyListening = 1;
			}
			else {
				llRegionSayTo(lastUserInteractionKey, 0, "User is currently offline, please try again later");
			}
		}
	}
	timer()
	{
		IsUserOnline();
		//llOwnerSay("test1");
		if (currentlyListening)
		{
			if (count < listenLength-1 ){
				count++;
				//llOwnerSay("im listening" + (string)count);
			}
			else {
				count = 0;
				currentlyListening = 0;
				llListenRemove(listenHandle);
				llRegionSayTo(lastUserInteractionKey, 0, "Sorry youre request has timed out");
			}
		}
	}
	listen(integer channel, string name, key id, string message)
	{
		//llInstantMessage( userKey, message );
		llMessageLinked(LINK_THIS, 0, message, id);
		llRegionSayTo(lastUserInteractionKey, 0, "thank you, your message has been sent");
		llListenRemove(listenHandle);
		currentlyListening = 0;
	}
}
state ownerInteraction
{
	state_entry()
	{
		listenHandle = llListen(30, "", lastUserInteractionKey, "");
		llOwnerSay("Board is now in revewing message state, others will be unable to interact with the board untill Owner 'exits' the menu system");
	}

	state_exit()
	{
		llOwnerSay("Board no longer in use by owner, resumeing normal operations");
		llListenRemove(listenHandle);
	}
	listen(integer channel, string name, key id, string msg)
	{
		if(msg == "exit") {
			state default;
		}
		else {
			llMessageLinked(LINK_THIS, 0, msg, id);
		}
	}
}