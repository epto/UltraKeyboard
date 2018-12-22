<?php

$baseName = @$argv[1];
if ($baseName=='') die("Manca un parametro\n");

$deadKey = @$argv[2];
if ($deadKey=='') die("Manca il parametro\n");

$layer = file('Hardware/BASE-LAY.txt') or die("Errore BASE-LAY\n");
$button = array();
$nStart = true;

$keyFlags = [
	'A'	=>	null,
	'B'	=>	'CTRL',
	'C'	=>	'ALT',
	'D'	=>	'CTRL + Alt',
	'E'	=>	'Shift',
	'F'	=>	'CTRL + Shift',
	'G'	=>	'ALT + Shift',
	'H'	=>	'CTRL + Alt + Shift',
	'I'	=>	'AltGr',
	'J'	=>	'AltGr + Shift' ]
	;

foreach($layer as $charList) {
	
	$charList = trim($charList,"\t\r\n ");
	
	if ($nStart) {
		if ($charList=='') $nStart=false;
		continue;
	}
	
	$charList = mb_convert_encoding($charList,'UNICODE','UTF8');
	$charList = unpack('n*',$charList);
	
	foreach($charList as &$char) {
		$char=dechex($char);
		$char=strtoupper($char);
		$char=str_pad($char,4,'0',STR_PAD_LEFT);
	}
		
	unset($char);
	
	$firstChar = $charList[1];
	
	foreach($charList as $char) {
		if (!isset($button[$char])) $button[$char] = $firstChar;
	}
	
}

unset($firstChar, $char, $charList, $nStart) ;
$layer = null;
$layer = file('Hardware/BASE-CODE.txt') or die("Errore lay\n");
$codes = array();

foreach($layer as $line) {
	$line = trim($line,"\t\r\n ");
	if ($line=='') continue;
	if (preg_match('/^(?<k>[A-Z0-9]{5})/',$line,$match)) {
		$codes[] = $match['k'];
	} else {
		echo "Error: $line\n";
	}
}

$codes = array_unique($codes);
unset($layer, $line, $match) ;

$outMode = array();

foreach($codes as $code) {
	$type = $code[0];
	$char = substr($code,1);
	
	$line= "K {$code}\t \t; ";
	if (@$keyFlags[$type]) $line.= "{$keyFlags[$type]} + ";
	
	if (isset($button[$char])) {
		$unicodePoint = hexdec($button[$char]);
		$unicodePoint = pack('n*',$unicodePoint);
		$unicodePoint = mb_convert_encoding($unicodePoint,'UTF8','UNICODE');
		$line.= $unicodePoint;
	} else {
		$line.= "???";
	}
	$line.= "\r\n";
	
	if (!isset($outMode[$type])) {
		
		if (@$keyFlags[$type]) {
			$code = $keyFlags[$type];
			$code = str_replace('+','-',$code);
			$code = str_replace(' ','',$code);
		} else {
			$code = 'Base';
		}
		
		$outMode[$type] = [
			'type'	=>	$code ,
			'file'	=>	$baseName.'_'.$code.'.txt' ,
			'text'	=>	"\xEF\xBB\xBF; BOM Line\r\nDK {$deadKey} ; DeadKey\r\n\r\n"
			] ;
			
	}
	
	$outMode[$type]['text'].=$line;
	
}

foreach($outMode as $type => &$file) {
	echo "DeadKey `$deadKey`\t$type > ".str_pad("`{$file['file']}`",40)." ... ";
	if (@file_put_contents($file['file'],$file['text'])) echo "Ok\n"; else echo "Errore\n";
}
