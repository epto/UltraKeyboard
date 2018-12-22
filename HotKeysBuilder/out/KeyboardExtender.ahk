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


; Dati: 
; MAP-LAY <^>!NumpadDot
ExtKeysMap0 := Object()
ExtKeysMap0["p1"] := "ᖱ"
ExtKeysMap0["p2"] := "ᖳ"
ExtKeysMap0["p3"] := "ᖰ"
ExtKeysMap0["p4"] := "ᖲ"
ExtKeysMap0["a1"] := "↓"
ExtKeysMap0["a2"] := "←"
ExtKeysMap0["a3"] := "↑"
ExtKeysMap0["a4"] := "→"
ExtKeysMap0["a5"] := "↖"
ExtKeysMap0["a6"] := "↗"
ExtKeysMap0["a7"] := "↘"
ExtKeysMap0["a8"] := "↙"
ExtKeysMap0["a9"] := "↕"
ExtKeysMap0["a0"] := "↔"
ExtKeysMap0["aq"] := "↨"
ExtKeysMap0["aw"] := "⇅"
ExtKeysMap0["ae"] := "⇆"
ExtKeysMap0["ar"] := "⇄"
ExtKeysMap0["at"] := "⇖"
ExtKeysMap0["ay"] := "⇗"
ExtKeysMap0["au"] := "⇘"
ExtKeysMap0["ai"] := "⇙"
ExtKeysMap0["d1"] := "ᗤ"
ExtKeysMap0["d2"] := "ᗧ"
ExtKeysMap0["d3"] := "ᗢ"
ExtKeysMap0["d4"] := "ᗣ"
ExtKeysMap0["d5"] := "ᗝ"
ExtKeysMap0["d6"] := "ᗜ"
ExtKeysMap0["d7"] := "ᗡ"
ExtKeysMap0["d8"] := "ᗞ"
ExtKeysMap0["q1"] := "▁"
ExtKeysMap0["q2"] := "▂"
ExtKeysMap0["q3"] := "▃"
ExtKeysMap0["q4"] := "▄"
ExtKeysMap0["q5"] := "▅"
ExtKeysMap0["q6"] := "▆"
ExtKeysMap0["q7"] := "▇"
ExtKeysMap0["q8"] := "█"
ExtKeysMap0["q9"] := "▣"
ExtKeysMap0["q0"] := "▢"
ExtKeysMap0["qq"] := "◪"
ExtKeysMap0["qw"] := "◩"
ExtKeysMap0["qe"] := "◆"
ExtKeysMap0["qr"] := "◇"
ExtKeysMap0["qt"] := "◊"
ExtKeysMap0["qy"] := "♦"
ExtKeysMap0["qu"] := "▪"
ExtKeysMap0["qi"] := "▫"
ExtKeysMap0["c1"] := "◐"
ExtKeysMap0["c2"] := "◑"
ExtKeysMap0["c3"] := "◒"
ExtKeysMap0["c4"] := "◓"
ExtKeysMap0["c5"] := "◔"
ExtKeysMap0["c6"] := "◕"
ExtKeysMap0["c7"] := "◉"
ExtKeysMap0["c8"] := "◌"
ExtKeysMap0["c9"] := "◎"
ExtKeysMap0["c0"] := "◯"
ExtKeysMap0["cq"] := "○"
ExtKeysMap0["cw"] := "●"
ExtKeysMap0["t1"] := "◢"
ExtKeysMap0["t2"] := "◤"
ExtKeysMap0["t3"] := "◣"
ExtKeysMap0["t4"] := "◥"
ExtKeysMap0["t5"] := "△"
ExtKeysMap0["t6"] := "▽"
ExtKeysMap0["t7"] := "▼"
ExtKeysMap0["t8"] := "▲"
ExtKeysMap0["t9"] := "►"
ExtKeysMap0["t0"] := "◄"
ExtKeysMap0["tq"] := "∆"
ExtKeysMap0["f1"] := "ᖴ"
ExtKeysMap0["f2"] := "ᖵ"
ExtKeysMap0["f3"] := "ᖶ"
ExtKeysMap0["f4"] := "ᖷ"
ExtKeysMap0["h1"] := "ᖸ"
ExtKeysMap0["h2"] := "ᖹ"
ExtKeysMap0["h3"] := "ᖺ"
ExtKeysMap0["h4"] := "ᖻ"
ExtKeysMap0["z1"] := "ᖼ"
ExtKeysMap0["z2"] := "ᖽ"
ExtKeysMap0["z3"] := "ᖾ"
ExtKeysMap0["z4"] := "ᖿ"
ExtKeysMap0["(1"] := "≤"
ExtKeysMap0["(2"] := "«"
ExtKeysMap0["(3"] := "᚜"
ExtKeysMap0["(4"] := "≮"
ExtKeysMap0["(5"] := "┤"
ExtKeysMap0["(6"] := "≪"
ExtKeysMap0["(7"] := "“"
ExtKeysMap0["(8"] := "◖"
ExtKeysMap0["(9"] := "｢"
ExtKeysMap0["(0"] := "｛"
ExtKeysMap0["(q"] := "｟"
ExtKeysMap0["(w"] := "《"
ExtKeysMap0["(e"] := "⁽"
ExtKeysMap0["(r"] := "‹"
ExtKeysMap0["(t"] := "【"
ExtKeysMap0[")1"] := "≥"
ExtKeysMap0[")2"] := "»"
ExtKeysMap0[")3"] := "᚛"
ExtKeysMap0[")4"] := "≯"
ExtKeysMap0[")5"] := "├"
ExtKeysMap0[")6"] := "≫"
ExtKeysMap0[")7"] := "”"
ExtKeysMap0[")8"] := "◗"
ExtKeysMap0[")9"] := "｣"
ExtKeysMap0[")0"] := "｝"
ExtKeysMap0[")q"] := "｠"
ExtKeysMap0[")w"] := "》"
ExtKeysMap0[")e"] := "⁾"
ExtKeysMap0[")r"] := "›"
ExtKeysMap0[")t"] := "】"
ExtKeysMap0["#1"] := "①"
ExtKeysMap0["#2"] := "②"
ExtKeysMap0["#3"] := "③"
ExtKeysMap0["#4"] := "④"
ExtKeysMap0["#5"] := "⑤"
ExtKeysMap0["#6"] := "⑥"
ExtKeysMap0["#7"] := "⑦"
ExtKeysMap0["#8"] := "⑧"
ExtKeysMap0["#9"] := "⑨"
ExtKeysMap0["#0"] := "⑩"
ExtKeysMap0["#q"] := "⑪"
ExtKeysMap0["#w"] := "⑫"
ExtKeysMap0["#e"] := "⑬"
ExtKeysMap0["#r"] := "⑭"
ExtKeysMap0["#t"] := "⑮"
ExtKeysMap0["#y"] := "⑯"
ExtKeysMap0["#u"] := "⑰"
ExtKeysMap0["#i"] := "⑱"
ExtKeysMap0["#o"] := "⑲"
ExtKeysMap0["#p"] := "⑳"
ExtKeysMap0["_1"] := "̹"
ExtKeysMap0["_2"] := "̜"
ExtKeysMap0["_3"] := "̟"
ExtKeysMap0["_4"] := "̠"
ExtKeysMap0["_5"] := "̪"
ExtKeysMap0["_6"] := "̺"
ExtKeysMap0["_7"] := "ᵔ"
ExtKeysMap0["_8"] := "ᵕ"

; DeadKey CapsLock
DeadKey0 := Object()
DeadKey0["J00BE"] := "ᗣ"
DeadKey0["J00B6"] := "ᗡ"
DeadKey0["J00BF"] := "ᗞ"
DeadKey0["J2261"] := "ᗜ"
DeadKey0["J2211"] := "ᖴ"
DeadKey0["J2554"] := "ᖵ"
DeadKey0["J2566"] := "ᖶ"
DeadKey0["J2557"] := "ᖷ"
DeadKey0["J00B3"] := "ᖸ"
DeadKey0["J2560"] := "ᖹ"
DeadKey0["J256C"] := "ᖺ"
DeadKey0["J2563"] := "ᖻ"
DeadKey0["I203C"] := "󠄂"
DeadKey0["I201C"] := "󠄃"
DeadKey0["I00B1"] := "ᗢ"
DeadKey0["I2264"] := "ᗧ"
DeadKey0["I2265"] := "ᗤ"
DeadKey0["I2260"] := "ᗝ"
DeadKey0["I263A"] := "◉"
DeadKey0["I25C4"] := "▢"
DeadKey0["I25BA"] := "▣"
DeadKey0["I250C"] := "▤"
DeadKey0["I252C"] := "▥"
DeadKey0["I2510"] := "▦"
DeadKey0["I258C"] := "▧"
DeadKey0["I2580"] := "▨"
DeadKey0["I2584"] := "◌"
DeadKey0["I005D"] := "╳"
DeadKey0["I00A4"] := "◢"
DeadKey0["I220F"] := "◤"
DeadKey0["I2206"] := "◣"
DeadKey0["I251C"] := "◥"
DeadKey0["I253C"] := "◩"
DeadKey0["I2524"] := "◪"
DeadKey0["I2500"] := "◨"
DeadKey0["I2502"] := "◧"
DeadKey0["I25A0"] := "◫"
DeadKey0["I0040"] := "◠"
DeadKey0["I0023"] := "◡"
DeadKey0["I00A6"] := "▭"
DeadKey0["I25AA"] := "◐"
DeadKey0["I00A9"] := "◑"
DeadKey0["I25CF"] := "◒"
DeadKey0["I2514"] := "◓"
DeadKey0["I2534"] := "◔"
DeadKey0["I2518"] := "◕"
DeadKey0["I00B5"] := "◈"
DeadKey0["A005C"] := "╲"
DeadKey0["A0031"] := "Ѧ"
DeadKey0["A0032"] := "Ѳ"
DeadKey0["A0033"] := "љ"
DeadKey0["A0034"] := "Ͼ"
DeadKey0["A0035"] := "Ͽ"
DeadKey0["A0036"] := "ϟ"
DeadKey0["A0037"] := "λ"
DeadKey0["A0038"] := "᚜"
DeadKey0["A0039"] := "᚛"
DeadKey0["A0030"] := "◯"
DeadKey0["A0027"] := "�"
DeadKey0["A00EC"] := ""
DeadKey0["A0071"] := "↖"
DeadKey0["A0077"] := "↗"
DeadKey0["A0065"] := "↘"
DeadKey0["A0072"] := "↙"
DeadKey0["A0074"] := "†"
DeadKey0["A0079"] := "↔"
DeadKey0["A0075"] := "↕"
DeadKey0["A0069"] := "η"
DeadKey0["A006F"] := "λ"
DeadKey0["A0070"] := "π"
DeadKey0["A00E8"] := "∛"
DeadKey0["A002B"] := "ʭ"
DeadKey0["A0061"] := "ⵃ"
DeadKey0["A0073"] := "ⵄ"
DeadKey0["A0064"] := "◮"
DeadKey0["A0066"] := "∫"
DeadKey0["A0067"] := "ⵅ"
DeadKey0["A0068"] := "ⵇ"
DeadKey0["A006A"] := "‡"
DeadKey0["A006B"] := "⁆"
DeadKey0["A006C"] := "⁅"
DeadKey0["A00F2"] := "þ"
DeadKey0["A00E0"] := "▰"
DeadKey0["A00F9"] := "▮"
DeadKey0["A007A"] := "ᶴ"
DeadKey0["A0078"] := "ᶳ"
DeadKey0["A0063"] := "ᶲ"
DeadKey0["A0076"] := "ᶺ"
DeadKey0["A0062"] := "ᵟ"
DeadKey0["A006E"] := "ᶣ"
DeadKey0["A006D"] := "ᵑ"
DeadKey0["A002C"] := "Γ"
DeadKey0["A002E"] := "፧"
DeadKey0["A002D"] := "Λ"
DeadKey0["F00B6"] := "◖"
DeadKey0["F03A6"] := "◗"
DeadKey0["F2666"] := "ᖼ"
DeadKey0["F2660"] := "ᖽ"
DeadKey0["F2022"] := "ᖾ"
DeadKey0["F25D8"] := "ᖿ"
DeadKey0["F2642"] := "｢"
DeadKey0["F2640"] := "｣"
DeadKey0["F2190"] := "｛"
DeadKey0["F2191"] := "｝"
DeadKey0["F2665"] := "｟"
DeadKey0["F25AC"] := "｠"
DeadKey0["F266B"] := "⁽"
DeadKey0["F266A"] := "⁾"
DeadKey0["F2126"] := "‹"
DeadKey0["F00D7"] := "›"
DeadKey0["E0021"] := "Ѫ"
DeadKey0["E0022"] := "Ѻ"
DeadKey0["E00A3"] := "њ"
DeadKey0["E0024"] := "【"
DeadKey0["E0025"] := "】"
DeadKey0["E002F"] := "╱"
DeadKey0["E0028"] := "≮"
DeadKey0["E0029"] := "≯"
DeadKey0["E003D"] := "《"
DeadKey0["E003F"] := "》"
DeadKey0["E0057"] := "ʬ"
DeadKey0["E0045"] := "ɘ"
DeadKey0["E0054"] := "τ"
DeadKey0["E0055"] := "ʉ"
DeadKey0["E004F"] := "◎"
DeadKey0["E00E9"] := "∜"
DeadKey0["E0041"] := "ɐ"
DeadKey0["E0044"] := "◭"
DeadKey0["E004B"] := "⊏"
DeadKey0["E004C"] := "⊐"
DeadKey0["E00B0"] := "▱"
DeadKey0["E00A7"] := "▯"
DeadKey0["E0056"] := "ɤ"
DeadKey0["E004D"] := "ɯ"
DeadKey0["E003B"] := "ʊ"
DeadKey0["E003A"] := "ⵆ"

; DeadKey ^CapsLock
DeadKey1 := Object()
DeadKey1["A0031"] := "ᵏ"
DeadKey1["A0032"] := "ᵐ"
DeadKey1["A0033"] := "ᵑ"
DeadKey1["A0034"] := "ᵒ"
DeadKey1["A0035"] := "ᵓ"
DeadKey1["A0036"] := "ᵗ"
DeadKey1["A0037"] := "ᵘ"
DeadKey1["A0038"] := "ᵚ"
DeadKey1["A0039"] := "ᵜ"
DeadKey1["A0030"] := "ᵝ"
DeadKey1["A0027"] := "ᵟ"
DeadKey1["A00EC"] := "ᵞ"
DeadKey1["A0071"] := "ᴽ"
DeadKey1["A0077"] := "ᵂ"
DeadKey1["A0065"] := "ᴱ"
DeadKey1["A0072"] := "ᴿ"
DeadKey1["A0074"] := "ᵀ"
DeadKey1["A0075"] := "ᵁ"
DeadKey1["A0069"] := "ᵢ"
DeadKey1["A006F"] := "ᴼ"
DeadKey1["A0070"] := "ᴾ"
DeadKey1["A00E8"] := "ᴪ"
DeadKey1["A002B"] := "ᴫ"
DeadKey1["A0061"] := "ᴬ"
DeadKey1["A0064"] := "ᴰ"
DeadKey1["A0067"] := "ᴳ"
DeadKey1["A0068"] := "ᴴ"
DeadKey1["A006A"] := "ᴶ"
DeadKey1["A006B"] := "ᴷ"
DeadKey1["A006C"] := "ᴸ"
DeadKey1["A00F2"] := "ᵣ"
DeadKey1["A00E0"] := "ᵿ"
DeadKey1["A00F9"] := "ᵤ"
DeadKey1["A007A"] := "ᵯ"
DeadKey1["A0078"] := "ᵰ"
DeadKey1["A0063"] := "ᵲ"
DeadKey1["A0076"] := "ᵥ"
DeadKey1["A0062"] := "ᴮ"
DeadKey1["A006E"] := "ᴺ"
DeadKey1["A006D"] := "ᴹ"
DeadKey1["A002C"] := "ᵠ"
DeadKey1["A002E"] := "ᵡ"
DeadKey1["A002D"] := "ᴭ"
DeadKey1["E0021"] := "ᴖ"
DeadKey1["E0022"] := "ᴗ"
DeadKey1["E00A3"] := "ᵃ"
DeadKey1["E0024"] := "ᵄ"
DeadKey1["E0025"] := "ᵅ"
DeadKey1["E0026"] := "ᵆ"
DeadKey1["E002F"] := "ᵇ"
DeadKey1["E0028"] := "ᵈ"
DeadKey1["E0029"] := "ᵉ"
DeadKey1["E003D"] := "ᵊ"
DeadKey1["E003F"] := "ᵋ"
DeadKey1["E005E"] := "ᵎ"
DeadKey1["E0051"] := "ᵍ"
DeadKey1["E0057"] := "ᴡ"
DeadKey1["E0045"] := "ᴇ"
DeadKey1["E0054"] := "ᴛ"
DeadKey1["E0055"] := "ᴜ"
DeadKey1["E004F"] := "ᴏ"
DeadKey1["E0050"] := "ᴘ"
DeadKey1["E00E9"] := "ᶵ"
DeadKey1["E0041"] := "ᴀ"
DeadKey1["E0053"] := "ᴤ"
DeadKey1["E0044"] := "ᴅ"
DeadKey1["E004A"] := "ᴊ"
DeadKey1["E004B"] := "ᴋ"
DeadKey1["E004C"] := "ᴌ"
DeadKey1["E00A7"] := "ᴜ"
DeadKey1["E005A"] := "ᴢ"
DeadKey1["E0043"] := "ᴄ"
DeadKey1["E0056"] := "ᴠ"
DeadKey1["E0042"] := "ᴃ"
DeadKey1["E004D"] := "ᴍ"
DeadKey1["E003B"] := "ᶲ"
DeadKey1["E003A"] := "ᶳ"
DeadKey1["E005F"] := "ᶴ"

; Nick
NickKeys := Object()
NickKeys[":)"] := "🙂"
NickKeys[";)"] := "😉"
NickKeys[":("] := "🙁"
NickKeys[":|"] := "😐"
NickKeys["miao"] := "😺"
NickKeys["merda"] := "💩"
NickKeys["paura"] := "😱"
NickKeys["incazzato"] := "😡"
NickKeys["diavolo"] := "😈"
NickKeys["amore"] := "😍"
NickKeys["cuore"] := "💝"
NickKeys["collision"] := "💥"
NickKeys["text"] := "💬"
NickKeys["zzz"] := "💤"
NickKeys["ok"] := "👌"
NickKeys["vaffanculo"] := "🖕"
NickKeys["pace"] := "🤝"
HelpIndex := Object()
HelpIndex["d0"] := "DK-0-A.png"
HelpIndex["d0s"] := "DK-0-E.png"
HelpIndex["d0cs"] := "DK-0-F.png"
HelpIndex["d0g"] := "DK-0-I.png"
HelpIndex["d0gs"] := "DK-0-J.png"
HelpIndex["d1"] := "DK-1-A.png"
HelpIndex["d1s"] := "DK-1-E.png"
HelpIndex["e0d"] := "Ext-0-100.png"
HelpIndex["e0f"] := "Ext-0-102.png"
HelpIndex["e0h"] := "Ext-0-104.png"
HelpIndex["e0p"] := "Ext-0-112.png"
HelpIndex["e0q"] := "Ext-0-113.png"
HelpIndex["e0t"] := "Ext-0-116.png"
HelpIndex["e0z"] := "Ext-0-122.png"
HelpIndex["e0#"] := "Ext-0-35.png"
HelpIndex["e0("] := "Ext-0-40.png"
HelpIndex["e0)"] := "Ext-0-41.png"
HelpIndex["e0_"] := "Ext-0-95.png"
HelpIndex["e0a"] := "Ext-0-97.png"
HelpIndex["e0c"] := "Ext-0-99.png"
HelpIndex["e0"] := "Ext-0.png"
HelpIndex["t"] := "Translators.png"
HelpIndex["*"] := ""
HelpText := "d0`tDeadKey [ CapsLock ]`nd0s`tDeadKey [ CapsLock ]  LShift`nd0cs`tDeadKey [ CapsLock ]  LCTRL + LShift`nd0g`tDeadKey [ CapsLock ]  AltGr`nd0gs`tDeadKey [ CapsLock ]  AltGr + Shift`nd1`tDeadKey [ CTRL CapsLock ]`nd1s`tDeadKey [ CTRL CapsLock ]  LShift`ne0d`tExt [ AltGr NumpadDot ] + d`ne0f`tExt [ AltGr NumpadDot ] + f`ne0h`tExt [ AltGr NumpadDot ] + h`ne0p`tExt [ AltGr NumpadDot ] + p`ne0q`tExt [ AltGr NumpadDot ] + q`ne0t`tExt [ AltGr NumpadDot ] + t`ne0z`tExt [ AltGr NumpadDot ] + z`ne0#`tExt [ AltGr NumpadDot ] + #`ne0(`tExt [ AltGr NumpadDot ] + (`ne0)`tExt [ AltGr NumpadDot ] + )`ne0_`tExt [ AltGr NumpadDot ] + _`ne0a`tExt [ AltGr NumpadDot ] + a`ne0c`tExt [ AltGr NumpadDot ] + c`ne0`tExt [ AltGr NumpadDot ]`nt`tTranslators [ AltGr Shift CapsLock ]`n*`tMain Layout`n"
RootHelp := "CapsLock                                DeadKey 1`nCTRL CapsLock                           DeadKey 2`nAltGr CapsLock                          Layout emoji`nAltGr Shift CapsLock                    Traslatori`nAltGr NumpadDot                         Layout per tipo`nShift Launch_Media                      Visualizza ultimo layout`nCTRL Launch_Media                       Indice layout e guida layout`nCTRL Browser_Search                     Legge un tag dalla clipboard`nCTRL Launch_Mail                        Crea un tag ||`nCTRL Shift NumpadDiv                    ACV Scrive il testo dalla clipboard`nCTRL NumpadDiv                          VAX Cambia in testo la clipboard`nAltGr Launch_Media                      Visualizza le immagini del Layout`n"
HPImg := Object()
HPTxt := Object()
HPMax := 22
HPImg[0] := "DK-0-J.png"
HPTxt[0] := "DeadKey [ CapsLock ]  AltGr + Shift"
HPImg[1] := "DK-0-I.png"
HPTxt[1] := "DeadKey [ CapsLock ]  AltGr"
HPImg[2] := "DK-0-A.png"
HPTxt[2] := "DeadKey [ CapsLock ]"
HPImg[3] := "DK-0-F.png"
HPTxt[3] := "DeadKey [ CapsLock ]  LCTRL + LShift"
HPImg[4] := "DK-0-E.png"
HPTxt[4] := "DeadKey [ CapsLock ]  LShift"
HPImg[5] := "DK-1-A.png"
HPTxt[5] := "DeadKey [ CTRL CapsLock ]"
HPImg[6] := "DK-1-E.png"
HPTxt[6] := "DeadKey [ CTRL CapsLock ]  LShift"
HPImg[7] := "Translators.png"
HPTxt[7] := "Translators [ AltGr Shift CapsLock ]"
HPImg[8] := "Ext-0-112.png"
HPTxt[8] := "Ext [ AltGr NumpadDot ] + p"
HPImg[9] := "Ext-0-97.png"
HPTxt[9] := "Ext [ AltGr NumpadDot ] + a"
HPImg[10] := "Ext-0-100.png"
HPTxt[10] := "Ext [ AltGr NumpadDot ] + d"
HPImg[11] := "Ext-0-113.png"
HPTxt[11] := "Ext [ AltGr NumpadDot ] + q"
HPImg[12] := "Ext-0-99.png"
HPTxt[12] := "Ext [ AltGr NumpadDot ] + c"
HPImg[13] := "Ext-0-116.png"
HPTxt[13] := "Ext [ AltGr NumpadDot ] + t"
HPImg[14] := "Ext-0-102.png"
HPTxt[14] := "Ext [ AltGr NumpadDot ] + f"
HPImg[15] := "Ext-0-104.png"
HPTxt[15] := "Ext [ AltGr NumpadDot ] + h"
HPImg[16] := "Ext-0-122.png"
HPTxt[16] := "Ext [ AltGr NumpadDot ] + z"
HPImg[17] := "Ext-0-40.png"
HPTxt[17] := "Ext [ AltGr NumpadDot ] + ("
HPImg[18] := "Ext-0-41.png"
HPTxt[18] := "Ext [ AltGr NumpadDot ] + )"
HPImg[19] := "Ext-0-35.png"
HPTxt[19] := "Ext [ AltGr NumpadDot ] + #"
HPImg[20] := "Ext-0-95.png"
HPTxt[20] := "Ext [ AltGr NumpadDot ] + _"
HPImg[21] := "Ext-0.png"
HPTxt[21] := "Ext [ AltGr NumpadDot ]"

; Translators
Trs := {"l":{"s":33, "o":65281, "m":65374}, "o":{"s":97, "o":9398, "m":9423}, "r":{"s":97, "o":9424, "m":9449}}
; Hotkeys: 
; MAP-LAY <^>!NumpadDot 
<^>!NumpadDot::XKey(ExtKeysMap0, "Ext-0")

+CapsLock::CapsLock


; DeadKey CapsLock
CapsLock::DKey(DeadKey0, "DK-0")


; DeadKey ^CapsLock
^CapsLock::DKey(DeadKey1, "DK-1")

<^>!CapsLock::SKey(NickKeys)

<^>!+CapsLock::RTranslator(Trs)

+Launch_Media::HelpEx()

^Launch_Media::HelpGui()
^Browser_Search::DTag()
^Launch_Mail::ETag()
^+NumpadDiv::ACV()
^NumpadDiv::VAX()
<^>!Launch_Media::HPStart()

;Run, %A_ScriptDir%\Translators.png



