//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//       _   ___     __            __  ___  _                               //
//      | | / (_)___/ /___ _____ _/ / / _ \(_)__ ___ ________ ________      //
//      | |/ / / __/ __/ // / _ `/ / / // / (_-</ _ `/ __/ _ `/ __/ -_)     //
//      |___/_/_/  \__/\_,_/\_,_/_/ /____/_/___/\_, /_/  \_,_/\__/\__/      //
//                                             /___/                        //
//                                                                          //
//                                        _                                 //
//                                        \`*-.                             //
//                                         )  _`-.                          //
//                                        .  : `. .                         //
//                                        : _   '  \                        //
//                                        ; *` _.   `*-._                   //
//                                        `-.-'          `-.                //
//                                          ;       `       `.              //
//                                          :.       .        \             //
//                                          . \  .   :   .-'   .            //
//                                          '  `+.;  ;  '      :            //
//                                          :  '  |    ;       ;-.          //
//                                          ; '   : :`-:     _.`* ;         //
//       Remote Options - 160110.1       .*' /  .*' ; .*`- +'  `*'          //
//                                       `*-*   `*-*  `*-*'                 //
// ------------------------------------------------------------------------ //
//  Copyright (c) 2014 - 2015 Nandana Singh, Jessenia Mocha, Alexei Maven,  //
//  Master Starship, Wendy Starfall, North Glenwalker, Ray Zopf, Sumi Perl, //
//  Kire Faulkes, Zinn Ixtar, Builder's Brewery, Romka Swallowtail et al.   //
// ------------------------------------------------------------------------ //
//  This script is free software: you can redistribute it and/or modify     //
//  it under the terms of the GNU General Public License as published       //
//  by the Free Software Foundation, version 2.                             //
//                                                                          //
//  This script is distributed in the hope that it will be useful,          //
//  but WITHOUT ANY WARRANTY; without even the implied warranty of          //
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the            //
//  GNU General Public License for more details.                            //
//                                                                          //
//  You should have received a copy of the GNU General Public License       //
//  along with this script; if not, see www.gnu.org/licenses/gpl-2.0        //
// ------------------------------------------------------------------------ //
//  This script and any derivatives based on it must remain "full perms".   //
//                                                                          //
//  "Full perms" means maintaining MODIFY, COPY, and TRANSFER permissions   //
//  in Second Life(R), OpenSimulator and the Metaverse.                     //
//                                                                          //
//  If these platforms should allow more fine-grained permissions in the    //
//  future, then "full perms" will mean the most permissive possible set    //
//  of permissions allowed by the platform.                                 //
// ------------------------------------------------------------------------ //
//         github.com/OpenCollar/opencollar/tree/master/src/remote          //
// ------------------------------------------------------------------------ //
//////////////////////////////////////////////////////////////////////////////

//Adjusted to OpenCollar name convention und format standards June 2015 Otto (garvin.twine)
//Updated Romka(romka.swallowtail)

// MESSAGE MAPS
integer CMD_TOUCH         = 100;
integer MENUNAME_REQUEST  = 3000;
integer MENUNAME_RESPONSE = 3001;
integer SUBMENU           = 3002;
integer DIALOG            = -9000;
integer DIALOG_RESPONSE   = -9001;
integer DIALOG_TIMEOUT    = -9002;

// Constants
string UPMENU         = "BACK";
string g_sParentMenu  = "Main";
string g_sHudMenu     = "HUD Style";
string g_sTextureMenu = "Textures";
string g_sOrderMenu   = "Order";

list g_lAttachPoints = [
    ATTACH_HUD_TOP_RIGHT,
    ATTACH_HUD_TOP_CENTER,
    ATTACH_HUD_TOP_LEFT,
    ATTACH_HUD_BOTTOM_RIGHT,
    ATTACH_HUD_BOTTOM,
    ATTACH_HUD_BOTTOM_LEFT,
    ATTACH_HUD_CENTER_1,
    ATTACH_HUD_CENTER_2
    ];

float g_fGap = 0.001; // This is the space between buttons
float g_Yoff = 0.002; // space between buttons and screen top/bottom border
float g_Zoff = 0.04; // space between buttons and screen left/right border
 
// Variables

vector g_vColor = <1,1,1>;
key g_kMenuID;
string g_sCurrentMenu;
list g_lButtons ; // buttons names for Order menu
list g_lPrimOrder ;
//  List must always start with '0','1'
//  0:Spacer, 1:Root, 2:Menu, 3:Couples, 4:Bookmarks, 5:Leash, 6:Beckon
//  Spacer serves to even up the list with actual link numbers

integer g_iLayout = 0;
integer g_iHidden = FALSE;
integer g_iSPosition = 69; // Nuff'said =D
integer g_iOldPos;
integer g_iNewPos;

integer g_iColumn = 0;

// themes
string g_sStylesCard=".buttons";
key g_kStylesNotecardRead;
key g_kStylesCardUUID;
string g_sStylesNotecardReadType;
integer g_iStylesNotecardLine;
string g_sCurrentTheme;
integer g_iThemesReady;
list g_lStyles;
integer g_iFistStart;


//**************************

key Dialog(key kRcpt, string sPrompt, list lChoices, list lUtilityButtons, integer iPage) {
    key kID = llGenerateKey();
    llMessageLinked(LINK_SET, DIALOG, (string)kRcpt + "|" + sPrompt + "|" + (string)iPage +
 "|" + llDumpList2String(lChoices, "`") + "|" + llDumpList2String(lUtilityButtons, "`"), kID);
    return kID;
}

FindButtons() { // collect buttons names & links
    g_lButtons = [" ", "Minimize"] ; // 'Minimize' need for texture
    g_lPrimOrder = [0, 1];  //  '1' - root prim
    integer i;
    for (i=2; i<llGetNumberOfPrims()+1; ++i) {
        g_lButtons += llGetLinkPrimitiveParams(i, [PRIM_NAME]);
        g_lPrimOrder += i;
    }
}

PlaceTheButton(float fYoff, float fZoff) {
    integer i;
    integer n = llGetListLength(g_lPrimOrder);
    vector pos;
    vector size = llGetScale();
    for (i=2; i < n; ++i) {
        if (g_iColumn==0) {  // Line
            if (g_iLayout) pos = <0,0,fZoff*(i-1)>; // vertical
            else pos = <0,fYoff*(i-1),0>; // horisontal
        } else if (g_iColumn==1) { // Column
            if (g_iLayout) { // vertical
                if (i <= (n/2)) pos = <0,0,fYoff*(i-1)>; // 1st half
                else pos = <0,fYoff,fZoff*(i-1-n/2)>;    // 2nd half
            } else { // horisontal
                if (i <= (n/2)) pos = <0,fYoff*(i-1),0>; // 1st half
                else pos = <0,fYoff*(i-1-n/2),fZoff>;    // 2nd half
            }
        } else if (g_iColumn==2) { // Alternate
            if (g_iLayout) { // vertical
                if (i&1) pos = <0,0,fYoff*(i/2)>;   // even
                else pos = <0,fYoff,fZoff*(i/2-1)>; // odd
            } else { // horisontal
                if (i&1) pos = <0,fYoff*(i/2),0>;   // even
                else pos = <0,fYoff*(i/2-1),fZoff>; // odd
            }
        }
        llSetLinkPrimitiveParamsFast(llList2Integer(g_lPrimOrder,i),[PRIM_POSITION,pos]); //,PRIM_SIZE,size]);
    }
}

BuildStylesList() {
    g_lStyles=[];
    if (llGetInventoryType(g_sStylesCard)==INVENTORY_NOTECARD) {
        g_kStylesCardUUID=llGetInventoryKey(g_sStylesCard);
        g_iStylesNotecardLine=0;
        g_sStylesNotecardReadType="initialize";
        g_kStylesNotecardRead=llGetNotecardLine(g_sStylesCard,g_iStylesNotecardLine);
    } else g_kStylesCardUUID = "";

}

DoStyle(string style) {
    if (~llListFindList(g_lStyles,[style])) {
        g_sStylesNotecardReadType=style;
        g_iStylesNotecardLine=0;
       // llOwnerSay("Applying the "+style+" theme...");
        g_kStylesNotecardRead=llGetNotecardLine(g_sStylesCard,g_iStylesNotecardLine);
    }
}

DefinePosition() {
    integer iPosition = llListFindList(g_lAttachPoints, [llGetAttached()]);
    vector size = llGetScale();
//  Allows manual repositioning, without resetting it, if needed
    if (iPosition != g_iSPosition) {     
        vector offset = <0, size.y/2+g_Yoff, size.z/2+g_Zoff>;
        if (iPosition==0||iPosition==1||iPosition==2) offset.z = -offset.z ;
        if (iPosition==2||iPosition==5) offset.y = -offset.y ;
        llSetPos(offset); // Position the Root Prim on screen
        g_iSPosition = iPosition;
    }
    if (g_iHidden)  // -- Fixes Issue 615: HUD forgets hide setting on relog.
        llSetLinkPrimitiveParamsFast(LINK_ALL_OTHERS, [PRIM_POSITION, <1.0, 0.0, 0.0>]);
    else {
        vector size = llGetScale();
        float fYoff = size.y + g_fGap; float fZoff = size.z + g_fGap; // This is the space between buttons
        if (iPosition == 0 || iPosition == 1 || iPosition == 2) fZoff = -fZoff;
        if (iPosition == 1 || iPosition == 2 || iPosition == 4 || iPosition == 5) fYoff = -fYoff;
        if (iPosition == 1 || iPosition == 4) g_iLayout = 0;

        PlaceTheButton(fYoff, fZoff); // Does the actual placement
    }
}

DoButtonOrder() {   // -- Set the button order and reset display
    integer iOldPos = llList2Integer(g_lPrimOrder,g_iOldPos);
    integer iNewPos = llList2Integer(g_lPrimOrder,g_iNewPos);
    integer i = 2;
    list lTemp = [0,1];
    for(;i<llGetListLength(g_lPrimOrder);++i) {
        integer iTempPos = llList2Integer(g_lPrimOrder,i);
        if (iTempPos == iOldPos) lTemp += [iNewPos];
        else if (iTempPos == iNewPos) lTemp += [iOldPos];
        else lTemp += [iTempPos];
    }
    g_lPrimOrder = lTemp;
    g_iOldPos = -1;
    g_iNewPos = -1;
    DefinePosition();
}


DoMenu(string sMenu) {

    string sPrompt;
    list lButtons;
    list lUtils = [UPMENU];

    if (sMenu == "Horizontal >" || sMenu == "Vertical >") {
        g_iLayout = !g_iLayout;
        DefinePosition();
        sMenu = g_sHudMenu;
    }
    else if (sMenu == "Alternate >" || sMenu == "Column >" || sMenu == "Line >") {
        g_iColumn++;
        if (g_iColumn > 2) g_iColumn = 0;
        DefinePosition();
        sMenu = g_sHudMenu;
    }
    else if (sMenu == g_sTextureMenu) { // textures
        if (g_iThemesReady) {
            sPrompt = "\nThis is the menu for styles.\n";
            sPrompt += "Selecting one of these options will\n";
            sPrompt += "change the color of the HUD buttons.\n";
            lButtons = g_lStyles;
        } else {
            llOwnerSay("Themes still loading...");
            sMenu = g_sHudMenu;
        }
    }
    else if (sMenu == g_sOrderMenu) { // Order
        sPrompt = "\nThis is the order menu, simply select the\n";
        sPrompt += "button which you want to re-order.\n\n";

        integer i;
        for (i=2;i<llGetListLength(g_lPrimOrder);++i) {
            integer pos = llList2Integer(g_lPrimOrder,i);
            lButtons += llList2List(g_lButtons,pos,pos);
        }
        lUtils = ["Reset",UPMENU];
    }
    if (sMenu == g_sHudMenu) { // Main
        sPrompt = "\nCustomize your Remote!";

        if (g_iLayout) lButtons = ["Vertical >"];
        else lButtons = ["Horizontal >"];

        if (g_iColumn==2) lButtons += ["Alternate >"];
        if (g_iColumn==1) lButtons += ["Column >"];
        if (g_iColumn==0) lButtons += ["Line >"];

        lButtons += ["Reset",g_sOrderMenu];
        if (g_kStylesCardUUID) lButtons += [g_sTextureMenu];
    }
    g_sCurrentMenu = sMenu;
    g_kMenuID = Dialog(llGetOwner(), sPrompt, lButtons, lUtils, 0);
}

OrderButton(string sButton)
{
    g_sCurrentMenu = g_sOrderMenu;
    list lButtons;
    string sPrompt;
    integer iTemp = llListFindList(g_lButtons,[sButton]);
    g_iOldPos = llListFindList(g_lPrimOrder, [iTemp]);

    sPrompt = "\nSelect the new position for swap with "+sButton+"\n\n";
    integer i;
    for(i=2;i<llGetListLength(g_lPrimOrder);++i) {
        if (g_iOldPos != i) {
            integer iTemp = llList2Integer(g_lPrimOrder,i);
            lButtons +=[llList2String(g_lButtons,iTemp)+":"+(string)i];
        }
    }
    g_kMenuID = Dialog(llGetOwner(), sPrompt, lButtons, [UPMENU], 0);
}

default
{
    state_entry() {
        //llSleep(1.0);
        g_iFistStart = TRUE;
        FindButtons(); // collect buttons names
        BuildStylesList();
        DefinePosition();
       // llOwnerSay("Finalizing HUD Reset... please wait a few seconds so all menus have time to initialize.");
        llMessageLinked(LINK_SET, MENUNAME_RESPONSE, g_sParentMenu + "|" + g_sHudMenu, "");
        DoStyle(llList2String(g_lStyles,0));
    }

    attach(key kAttached) {
        integer iAttachPoint = llGetAttached();
//      if being detached
        if (kAttached == NULL_KEY)
            return;
        else if (iAttachPoint < 31 || iAttachPoint > 38) {//http://wiki.secondlife.com/wiki/LlAttachToAvatar attach point integer values - 31-38 are hud placements
            llOwnerSay("Sorry, this device can only be placed on the HUD. Attach code: " + (string)iAttachPoint);
            llRequestPermissions(kAttached, PERMISSION_ATTACH);
            llDetachFromAvatar();
            return;
        }
        else // It's being attached and the attachment point is a HUD position, DefinePosition()
            DefinePosition();
    }

    link_message(integer iSender, integer iNum, string sStr, key kID) {
        if (iNum == MENUNAME_REQUEST && sStr == g_sParentMenu)
            llMessageLinked(LINK_SET, MENUNAME_RESPONSE, g_sParentMenu + "|" + g_sHudMenu, "");
        else if (iNum == SUBMENU && sStr == g_sHudMenu) DoMenu(g_sHudMenu);
        else if (iNum == DIALOG_RESPONSE && kID == g_kMenuID) {
            list lParams = llParseString2List(sStr, ["|"], []);
            //kID = (key)llList2String(lParams, 0);
            string sButton = llList2String(lParams, 1);
            //integer iPage = (integer)llList2String(lParams, 2);
            if (g_sCurrentMenu == g_sHudMenu) {   // -- Inside the 'Options' menu, or 'submenu'
                // If we press the 'Back' and we are inside the Options menu, go back to OwnerHUD menu
                if (sButton == UPMENU) {
                    llMessageLinked(LINK_SET, SUBMENU, g_sParentMenu, kID);
                    return;
                } else if (sButton == "Reset") {
                    llOwnerSay("Resetting the HUD-Style to the default.");
                    llResetScript();
                } else if (sButton == "Cancel") g_sCurrentMenu = g_sHudMenu;
                else g_sCurrentMenu = sButton;
            } else if (g_sCurrentMenu == g_sTextureMenu) {// -- Inside the 'Texture' menu, or 'submenu1'
                if (sButton == UPMENU) g_sCurrentMenu = g_sHudMenu;
                else {
                    DoStyle(sButton);
                    return;
                }
            } else if (g_sCurrentMenu == g_sOrderMenu) {
                if (sButton == UPMENU) g_sCurrentMenu = g_sHudMenu;
                else if (sButton == "Reset") {
                    FindButtons();
                    llOwnerSay("Order position reset to default.");
                    DefinePosition();
                } else if (llSubStringIndex(sButton,":") >= 0) { // Jess's nifty parsing trick for the menus
                    g_iNewPos = llList2Integer(llParseString2List(sButton,[":"],[]),1);
                    DoButtonOrder();
                } else {
                    OrderButton(sButton);
                    return;
                }
            }
            DoMenu(g_sCurrentMenu);
        } else if (iNum == CMD_TOUCH) {
            if (sStr == "hide") {
                g_iHidden = !g_iHidden;
                DefinePosition();
            }
        }
    }

    changed(integer iChange) {
        if (iChange & CHANGED_OWNER) llResetScript();
        if (iChange & CHANGED_LINK) llResetScript();
        if (iChange & CHANGED_INVENTORY) {
            if (llGetInventoryKey(g_sStylesCard)!=g_kStylesCardUUID) BuildStylesList();
        }
    }

    dataserver(key kID, string sData) {
        if (kID == g_kStylesNotecardRead) {
            if (sData != EOF) {
                sData = llStringTrim(sData,STRING_TRIM);
                if (sData!="" && llSubStringIndex(sData,"#") != 0) {
                    if (llGetSubString(sData,0,0) == "[") {
                        sData = llGetSubString(sData,llSubStringIndex(sData,"[")+1,llSubStringIndex(sData,"]")-1);
                        sData = llStringTrim(sData,STRING_TRIM);
                        if (g_sStylesNotecardReadType=="initialize") {  //reading notecard to determine style names
                            g_lStyles += sData;
                        } else if (sData==g_sStylesNotecardReadType) {  //we just found our section
                            g_sStylesNotecardReadType="processing";
                            g_sCurrentTheme = sData;
                        } else if (g_sStylesNotecardReadType=="processing") {  //we just found the start of the next section, we're done
                           // llOwnerSay("Applied!");
                            if (!g_iFistStart) DoMenu(g_sTextureMenu);
                            g_iFistStart = FALSE;
                            return;
                        }
                        g_kStylesNotecardRead=llGetNotecardLine(g_sStylesCard,++g_iStylesNotecardLine);
                    } else {
                        if (g_sStylesNotecardReadType=="processing") {
                            //do what the notecard says
                            list lParams = llParseStringKeepNulls(sData,["~"],[]);
                            string sButton = llStringTrim(llList2String(lParams,0),STRING_TRIM);
                            integer link = llListFindList(g_lButtons,[sButton]);
                            if (link > 0) {
                                sData = llStringTrim(llList2String(lParams,1),STRING_TRIM);
                                if (sData != "" && sData != ",") {
                                    if (sButton == "Picture") 
                                        llMessageLinked(LINK_SET, 111, sData, "");
                                    else 
                                        llSetLinkPrimitiveParamsFast(link,[PRIM_TEXTURE, ALL_SIDES, sData , <1.0, 1.0, 0.0>, ZERO_VECTOR, 0.0, PRIM_COLOR, ALL_SIDES, g_vColor, 1.0]);
                                }
                            }
                        }
                        g_kStylesNotecardRead=llGetNotecardLine(g_sStylesCard,++g_iStylesNotecardLine);
                    }
                } else g_kStylesNotecardRead=llGetNotecardLine(g_sStylesCard,++g_iStylesNotecardLine);
            } else {
                if (g_sStylesNotecardReadType=="processing") {  //we just found the end of file, we're done
                   // llOwnerSay("Applied!");
                    if (!g_iFistStart) {
                        DoMenu(g_sTextureMenu);
                        g_iFistStart = FALSE;
                    }
                } else {
                    if (g_iFistStart) {
                        DoStyle(llList2String(g_lStyles,0));
                    }
                    g_iThemesReady = TRUE;
                }
            }
        }
    }
}
