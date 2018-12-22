;! AutoHotkey_L
#SingleInstance force
#KeyHistory 0

lastLayout := ""
lastIdi := ""
HPPage := 0

SKey(v) {
 Input, nick, L16, {delete}{esc}{end}{home}{space}{enter}
 SendInput % v[nick]
}

XKey(v, idi) {
 Global lastLayout
 Global lastIdi
  
 lastIdi := idi
 lastLayout := idi

 Input, kTable, L1, {delete}{esc}{end}{home}{enter}
 Input, kIndex, L1, {delete}{esc}{end}{home}{enter}
 code := % kTable . kIndex
 lastLayout := idi . "-" . Ord(kTable)
 Send % v[code]
 
}

DKey(v, idi) {
 Global lastLayout
 Global lastIdi
  
 lastIdi := idi
 lastLayout := ""
 
 Input, key, L1 M, {delete}{esc}{home}{end}
 p := 0
 if (GetKeyState("LControl") AND GetKeyState("RAlt")) {

   if (GetKeyState("Shift")) {
    p := 9 
   } else {
    p := 8
   }
 
 } else {
      
   if (GetKeyState("Control")) {
   	p += 1
   }
   
   if (GetKeyState("Alt")) {
   	p += 2
   }
   
   if (GetKeyState("Shift")) {
     	p += 4
   }

 }
  
 j := Ord(key)
 j := Format( "{:04X}" , j )
 k := Chr( 65 + p ) . j
 
 lastLayout := idi . "-" . Chr( 65 + p )

 Send % v[k]

}

RTranslator(obj) {

 Global lastLayout
 Global lastIdi
  
 lastIdi := ""
 lastLayout := "Translator"

   Input base, L1, {delete}{esc}{home}{enter}{ctrl}{alt}

   if not obj[base] {
	Send ?
	return
	}

   Loop {
	Input key, L1, {delete}{esc}{home}{enter}{ctrl}{alt}

	numChar := Ord( key )
	numChar -= obj[base]["s"]

	if ( numChar < 0 ) {
		Send % key
		break
		}

	numChar += obj[base]["o"]

	if ( numChar > obj[base]["m"] ) {
		Send % key
		break
		}

	char := Chr( numChar )
	SendInput % char
   }
}

HelpEx() {
 Global lastLayout
 Gui, Destroy
 
 if (lastLayout == "") {
  return
 }

 img := A_ScriptDir . "\" . lastLayout . ".png"
 Gui, Add, Picture, , %img%
 Gui, Add, Button, gHPMAIN w80, Layouts
 Gui, Show, , Keyboard Layout
 return

 GuiClose:
 GuiEscape:
 Gui, Destroy
 return
}

HelpGui() { 
  Global HelpIndex
  Global HelpText
  Global RootHelp

  Gui, Destroy
  Input key, L8, {delete}{esc}{home}{enter}{ctrl}{alt}
  img := A_ScriptDir . "\" . HelpIndex[key]

  if ( key == "*" ) {
   Gui, Font, s8, Courier New
   Gui, Add, Text,, %RootHelp% 
   Gui, Add, Button, gHPMAIN w80, Layouts
   Gui, Show, , Keyboard Layout Main
   return
  }

  if ( HelpIndex[key] == "" ) {
   Gui, Font, s8, Courier New
   Gui, Add, Text,, %HelpText% 
   Gui, Add, Button, gHPMAIN w80, Layouts
   Gui, Show, , Keyboard Layout Index

  } else {
   Gui, Add, Picture, , %img%
   Gui, Add, Button, gHPMAIN w80, Layouts
   Gui, Show, , Keyboard Layout
  }

 return
}

DTag() {
  ClipWait, 1, 0
  iStr := Clipboard
  len := StrLen(iStr)
  oStr := ""
  pox := 1

  While( pox <= len ) {
    cChar := Ord(SubStr(iStr, pox, 1))
    pox++
    cChar := cChar & 0x7F
    if (cChar != 0x40) 
      oStr := oStr . Chr(cChar)
  }

 MsgBox, 0x40040, TAG, %oStr%
 
}

ETag() {
  Input iStr, L256, {delete}{esc}{end}{home}{space}{enter}
   
  len := StrLen(iStr)
  oStr := Chr(0xE0100)
  pox := 1

  While( pox <= len ) {
    cChar := Ord(SubStr(iStr, pox, 1))
    pox++
    cChar := cChar & 0x7F
    cChar := cChar | 0xE0000
    oStr := oStr . Chr(cChar)
  } 

 pox := Chr(0xE0101)
 oStr := oStr . pox

 SendInput % oStr
 
}

ACV() {
 ClipWait, 1
 iStr := Clipboard
 SendInput % iStr
}

VAX() {
 ClipWait, 1
 iStr := Clipboard
 Clibpoard := iStr
}

HPOpen(p) {

 Global HPPage
 Global HPMax
 Global HPTxt
 Global HPImg
 Global RootHelp
 Global HelpText

 HPPage += p

 if ( HPPage < 0 ) {
  HPPage := 0
 }

 if ( HPPage >= HPMax ) {
  HPPage := HPMax - 1
 }
  
  img := A_ScriptDir . "\" . HPImg[HPPage]
  title := "Layout: " . HPTxt[HPPage]

  Gui, Add, Picture, , %img%
  Gui, Add, Button, gPREV w80, < Prev
  Gui, Add, Button, gNEXT w80 xp+84 yp+0, Next >
  Gui, Add, Button, gHELPm w80 xp+84 yp+0, Main
  Gui, Add, Button, gHELPi w80 xp+84 yp+0, Index
  Gui, Add, Button, gHELPf w80 xp+84 yp+0, Help
  Gui, Show, , % title

  return

  PREV:
   Gui, Destroy
   HPOpen(-1)
   return

  NEXT:

   Gui, Destroy
   HPOpen(1)
   return

  HELPm:
   Gui, Destroy
   Gui, Font, s8, Courier New
   Gui, Add, Text,, %RootHelp% 
   Gui, Add, Button, gHPMAIN w80, Layouts
   Gui, Show, , Keyboard Layout Main
   return

  HELPi:
   Gui, Destroy
   Gui, Font, s8, Courier New
   Gui, Add, Text,, %HelpText% 
   Gui, Add, Button, gHPMAIN w80, Layouts
   Gui, Show, , Keyboard Layout Index
   return

   HELPf:
   file := A_ScriptDir . "\HELP"
   FileRead, text, %file%
   Gui, Destroy
   Gui, Font, s8, Courier New
   Gui, Add, Text,, %text%
   Gui, Add, Button, gHPMAIN w80, Layouts
   Gui, Show, , Keyboard Help
   return

}

HPStart() {
 Global HPPage
 HPPage := 0
 HPOpen(0)
}

Bumb() {
 HPMAIN:
 Gui, Destroy
 HPStart()
 return

}

