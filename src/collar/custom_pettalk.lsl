key g_kWearer; // key of the s_Current g_kWearer to reset only on owner iChanges
string g_sWearerName;
integer g_iNameListener;

key BARK = "e9a2470e-9d16-e5aa-515c-39f37fe9a2cb";
//key PANT = "7de7ca8b-0582-0699-e0a1-e9ee72f23f8b";

integer g_iMuffleChannel = 300;
integer g_iMuffleEmoteChannel = 310;
string g_sMuffleSeverity = "PUPPYMODE";

//===============================================================================
//===============================================================================
// MUFFLE CHANNEL

// Send a gagged-speech version of a message to the open channel.
string mangleText(string mes, string severity)
{
        // Iterate through the speech, mushing up the wearer's diction.
    integer i;
    string sub = "";
    string rep = "";
        
    if (severity == "PUPPYMODE"){
            return "Murrp";
    } else if (severity == "MUTE"){
            return "...";
    } else { //Lime's dumb else
    
    for (i = 0; i < llStringLength(mes); i++)
    {
        sub = llGetSubString(mes, i, i);
        rep = "";
        
        if (severity == "VERY LOOSE")
        {
            // no mumble
        }
 /*       else
        if (severity == "LOOSE")
        {
            
            if (sub == "l")
                rep = "w";
            else
            if (sub == "R" || sub == "L")
                rep = "W";
            else
            if (sub == "s")
                rep = "f";
            else
            if (sub == "S")
                rep = "F";
            else
            if (sub == "t")
                rep = "g";               
            else
            if (sub == "T")
                rep = "G";                
        }
        
        else
        if (severity == "SEVERE")
        {
            if (sub == "a" || sub == "b" || sub == "j" || sub == "s" || sub == "v" || sub == "z")
                rep = "r";
            else
            if (sub == "A" || sub == "B" || sub == "J" || sub == "S" || sub == "V" || sub == "Z")
                rep = "R";
            else
            if (sub == "d" || sub == "k" || sub == "l" || sub == "w")
                rep = "f";
            else
            if (sub == "D" || sub == "K" || sub == "L" || sub == "W")
                rep = "F";            
            else
            if (sub == "g" || sub == "x")
                rep = "n";
            else
            if (sub == "G" || sub == "x")
                rep = "N";                
            else
            if (sub == "h" || sub == "i" || sub == "m" || sub == "u")
                rep = "d";
            else
            if (sub == "H" || sub == "I" || sub == "M" || sub == "U")
                rep = "D";                
            else
            if (sub == "q")
                rep = "m";
            else
            if (sub == "Q")
                rep = "M";                
        }
            else
             if (severity == "EXTREME" | severity == "TOTAL" | severity == "MUTE")
        {
             if (sub =="B" || sub =="D" || sub =="K" || sub =="T" || sub =="V") rep = "Mph";
    if (sub =="b" || sub =="d" || sub =="k" || sub =="t" || sub =="M") rep = "m";
    if (sub =="D" || sub =="J" || sub =="L" || sub =="Q" || sub =="R") rep = "M";
    if (sub =="d" || sub =="j" || sub =="l" || sub =="q" || sub =="r") rep = "ph";
    if (sub =="S") rep = "H";
    if (sub =="s") rep = "m";
            
 if (sub =="C") rep = "Mf";
    if (sub =="c") rep = "m";
 if (sub =="A" || sub =="E" || sub =="I" || sub =="O" || sub =="U") rep = "Mph";
    
             if (sub =="a" || sub =="e" || sub =="i" || sub =="o" || sub =="u") rep = "m";
                
 if (sub =="C" || sub =="V" || sub =="N" || sub =="Y") rep = "Mh";
    
         if (sub =="c" || sub =="v" || sub =="n" || sub =="y") rep = "ph";
    
 if (sub =="W" || sub =="Y" || sub =="Z" || sub =="X") rep = "Mf";
    
     if (sub =="w" || sub =="y" || sub =="z" || sub =="x") rep = "f";
    


} */
        else
        {
            llOwnerSay("muffle '" +severity + "'");
        }
    
        // Replace character if necessary.        
        if (rep != "")
        {
            mes = llDeleteSubString(mes, i, i);
            mes = llInsertString(mes, i, rep);
        }    
    }
    
    return mes;
    } //end Lime's dumb else
}

integer mumble(string mes, string severity)
{
    mes = mangleText(mes, severity);

    // Broadcast the muffled speech on the chat channel.
    
    // Store current object name.
    string storeName = llGetObjectName();

    // Set object name to given name (so it speaks as if the wearer).
    // Replace conditionals so tags use dynamic values.
    //string wearerName = llGetDisplayName(llGetOwner());
    //if(wearerName == "" || wearerName == "???") { wearerName = llKey2Name(llGetOwner());}
    llSetObjectName(g_sWearerName); //llSetObjectName(wearerName);
    
    // Broadcast the muffled speech on the chat channel.

    if (g_sMuffleSeverity == "PUPPYMODE"){//LIMED.
        integer random = (integer) llFrand (5.0); //returns a random number from zero to X-1. (6.0 = 0-5)
        //OH BOY, FLOATS. I've only been in college for three years, I don't know how to use floats.
        //no switch statement? Cool. COOL. COOL.
        if (random == 0){
            llSay(0, "/me makes a cute murrping sound.");
            llPlaySound(BARK, 1.0);
        } else if (random == 1){
            llSay(0, "/me makes cute little animal noises.");
            llPlaySound(BARK, 1.0);
        } else if (random == 2){
            llSay(0, "/me makes cute animal noises as if trying to speak.");
            llPlaySound(BARK, 1.0);
        } else if (random == 3){
            llSay(0, "/me makes a feeble attempt to speak but only makes cute animal noises.");
            llPlaySound(BARK, 1.0);
        } else if (random == 4){
            llSay(0, "/me makes animal noises almost like words but still completely unintelligible");
            llPlaySound(BARK, 1.0);
        } else if (random == 5){
            //llSay(0, "CAPTAIN, SOMETHING WENT WRONG. CONTACT LIME");
        }
    
    } 
    if ( g_sMuffleSeverity != "MUTE" & g_sMuffleSeverity != "PUPPYMODE")
        {
         llSay(0, "/me mumbles \""+mes+"\"");        
    }

    // Restore object name.
    llSetObjectName(storeName);

    return TRUE;
}

integer parseEmote(string mes, string severity)
{
    string unparsedMessage = mes;
    string parsedMessage = "";
    integer quoteIndex = llSubStringIndex(unparsedMessage, "\"");
    
    while(quoteIndex != -1)
    {
        if(quoteIndex != 0) parsedMessage += llGetSubString(unparsedMessage, 0, quoteIndex - 1);
        if(quoteIndex != llStringLength(unparsedMessage) - 1)
            unparsedMessage = llGetSubString(unparsedMessage, quoteIndex + 1, -1);
        else
            unparsedMessage = "";
        
        if(llStringLength(unparsedMessage) != 0)
        {
            quoteIndex = llSubStringIndex(unparsedMessage, "\"");
            if(quoteIndex == 0)
            {
                parsedMessage += "\"\"";
                if(llStringLength(unparsedMessage) != 1)
                    unparsedMessage = llGetSubString(unparsedMessage, quoteIndex + 1, -1);
                else
                    unparsedMessage = "";
            }
            else if(quoteIndex != -1)
            {
                string speachText = llGetSubString(unparsedMessage, 0, quoteIndex - 1);
                parsedMessage += "\"" + mangleText(speachText, severity) + "\"";
                
                if(quoteIndex != llStringLength(unparsedMessage) - 1)
                    unparsedMessage = llGetSubString(unparsedMessage, quoteIndex + 1, -1);
                else
                    unparsedMessage = "";
            }
            else
            {
                parsedMessage += "\"" + mangleText(unparsedMessage, severity) + "\"";
                unparsedMessage = "";
            }
        }
        
        quoteIndex = llSubStringIndex(unparsedMessage, "\"");
    }
    parsedMessage += unparsedMessage;
        
    // Broadcast the muffled emote on the chat channel.
    
    // Store current object name.
    string storeName = llGetObjectName();
    
    // Set object name to given name (so it speaks as if the wearer).
    // Replace conditionals so tags use dynamic values.
    //string wearerName = llGetDisplayName(llGetOwner());
    //if(wearerName == "" || wearerName == "???") { wearerName = llKey2Name(llGetOwner());}
    llSetObjectName(g_sWearerName); //llSetObjectName(wearerName);
    
    // Broadcast the muffled speech on the chat channel.
    
            llSay(0, parsedMessage);        

    // Restore object name.
    llSetObjectName(storeName);

    return TRUE;
}

//===============================================================================
//===============================================================================

default
{
    state_entry()
    {
        g_kWearer = llGetOwner();
        g_sWearerName = llGetDisplayName(llGetOwner());
        if(g_sWearerName == "" || g_sWearerName == "???") g_sWearerName = llKey2Name(llGetOwner());
        
        llListen(g_iMuffleChannel, "", llGetOwner(), "");
        llListen(g_iMuffleEmoteChannel, "", llGetOwner(), "");
        
    }

    listen(integer channel, string name, key id, string message) {
        if (channel == g_iMuffleChannel) {
            mumble(message, g_sMuffleSeverity);
        }
        
        if (channel == g_iMuffleEmoteChannel) {
            parseEmote(message, g_sMuffleSeverity);
        }        
    }
}