# UltraKeyboard
Extend your keyboard beyond all limits.

## How it works:

It uses a new keyboard layout named "IT Unicode EPTO 1 (Full Unicode Keyboard)".
This layout contains a lot of unicode characters. It is not enough for us.

I want write "Ｌａｒｇｅ" and ⓇⓄⓊⓃⒹ and some others ☺ ☻ ♣ █ 🙂 💩

To extends the keyboard layout and functions it uses Autohotkey.
The Autohotkey's language is very complex to do a new keyboard layout with deadkeys, translator etcà

This php script do all works for you.

## More keyboard modes and functions:

### Mapped layout by category:

This mode uses a deadkey and a character to select the layout.
Example: Write the character "≤".
Press AltGr + The Dot into numpad
Then to select (opening category) press "(".
Then select the first characher into the map, press "1".

### Named keys:

Press AltGr + CapsLock, digit :), then press enter.
It write: 🙂

### No more accidental CapsLock:

Use Shift + CapsLock instead.

### Write Ｌａｒｇｅ (translator) :

Press AltGr + Shift + CapsLock and write in large mode.

(End width enter or space).

## How to use:

First install the "IT Unicode EPTO 1 (Full Unicode Keyboard)" from EPTOKeyboard directory, then put in autorun the file KeyboardExtender.exe from bin direcotry.

Press AltGr + (Media ♫) to open the help window.

## How to customize:

First install Autohotkey.

The are some folders into HotKeysBuilder directory:

### To change DeadKeys:

The files into the DeadKeys direcotry defines the deadkeys by configuration text files.

Put a unicode chacarcter into the space before comments ( start from ; ) .
You can also use a unicode escape like: <0x1234>
   
### To change Mapped layout DeadKeys: 

Modify the file ExtLayout/MAP-LAY.txt
Leave blank the first two lines.
For each line put the first character as the DeadKey, next characters are mapped automatically after the mapped DeadKey.

### To change the named keys:

Edit the file ExtConfig/NamedKeys.txt

For each line the word is the name of the character, after space put the character or a string.

### To change or add a Translator:

Edit the file ExtConfig/Translators.txt

Put in the first column a character from keyboard (don't use modificators).

All numbers are in hexadecimal.

The second column contains a number to subtract from current character from keyboard.

The third column contains the first unicode character.

The fourth column contains the last unicode character.

The last column can contains a short description.

For exmple: 
x 20 E000 E0FF

Press key [ AltGr + Shift + CapsLock ], then enter in translator mode.
Press key "x", then it select this translator:

x 20 E000 E0FF

Press "!" then the character is 0x21, is subtracted to 20, then result is 1, then add the E000, the sends the unicode character E001.

## Edit main layout or move the DeadKeys:

Edit the file ExtConfig/Vars.ini

It contains the association between button variables and Autohotkey's hotkeys.

Remark:

The file ExtConfig/VarsNames.ini contains the button descriptions.



 
