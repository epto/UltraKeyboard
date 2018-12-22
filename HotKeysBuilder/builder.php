<?php

function setVars($out) {
	global $vars;
	
	foreach($vars as $k => $v) {
		$k = '{$'.$k.'}';
		$out = str_replace($k,$v,$out);
		}
	
	$out = preg_replace_callback('/<0x(?<h>[0-9A-Fa-f]{1,8})>/','hexCharToChar',$out);
	
	return $out;
	}

function getFile($file) {
	$str = file_get_contents($file);
	if ($str===false) return false;
	
	if (strpos($str,"\xEF\xBB\xBF")!==0) {
		if (!preg_match('/^[\\x00-\\x7E]*$/',$str)) die("Errore di codifica del file `$file`\nDeve essere UTF8 con BOM oppure ASCII\n");
	}
	
	$str = setVars($str);
	return explode("\n",$str);
	}
	
function hexCharToChar($match) {
	$match = hexdec($match['h']);
	return chrW($match);
	}

class SpecialKey {
	private $str;
	public $prop = array(
		'size'	=>	8	)
		;
	
	function __set($x,$y) {
		$this->prop[$x]=$y;
	}
	
	function __get($x) {
		return $this->prop[$x];
	}
	
	function __isset($x) {
		return isset($this->prop[$x]);
	}
		
	function __construct($x) {
		$this->str = $x;
	}
	
	function __toString() {
		return $this->str;
		}
	}

function charCode($char) {
	$char = mb_convert_encoding($char,'UTF-16BE','UTF8');
	$char = unpack('n*',$char);
	return $char[1];
	}
	
function chrW($charCode) {
	$char = pack('N',$charCode);
	$char = mb_convert_encoding($char,'UTF8','UTF-32BE');
	return $char;
	}

function mkId($str) {
	$tok = explode(' ',$str);
	asort($tok);
	$tok = implode(' ',$tok);
	$tok = strtolower($tok);
	$tok = str_replace(' ','',$tok);
	return md5($tok);
	}

function parseFile($fileName,&$deadKeys) {
	$file = getFile($fileName) or die("Errore nel file `$fileName`\n");
	$deadKey='';

	foreach($file as $num => $line) {
		$num++;
		list($line) = explode(';',$line,2);
		$line = str_replace("\xEF\xBB\xBF",'',$line);
		$line = str_replace("\t"," ",$line);
		$line = trim($line,"\r\n ");
		$line = preg_replace('/\\x20+/',' ',$line);
		if ($line=='') continue;
		
		$tok = explode(' ',$line);
		
		if ($tok[0] == 'DK') {
			$tok[0] = '';
			$deadKey = trim(implode(' ',$tok));
			$deadKeyId = mkId($deadKey);
			if (!isset($deadKeys[$deadKeyId])) {
				$deadKeys[$deadKeyId] = array(
					'dk'	=>	$deadKey,
					'files'	=>	array(),
					'map'	=>	array(),
					);
				}
				
			$deadKeys[$deadKeyId]['files'][] = $fileName;
			continue;
			}

		if ($tok[0] == 'K') {
			if (!isset($tok[2])) continue;
			if ($deadKey == '') die("Manca il comando DK alla linea $num nel file `$fileName`\n");
			if (isset($deadKeys[$deadKeyId]['map'][ $tok[1] ])) die("Doppia definizione per {$tok[1]} alla linea $num nel file `$fileName`\n");
			$deadKeys[$deadKeyId]['map'][ $tok[1] ] = $tok[2];
			continue;
			}
			
		die("Errore di sintassi in linea $num nel file `$fileName` \n\"$line\"\n");
		
	}
}

function parseMapLay($file,$MapLayKey) {
		
	$order="1234567890qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM";
	$extLayout = getFile($file) or die("Errore nel file `$file`\n");

	$extLay = array();

	foreach($extLayout as $line) {
		$line = str_replace(["\xEF\xBB\xBF", "\t","\r","\n",' '],'',$line);
		if ($line=='') continue;
				
		$line = mb_convert_encoding($line,'UTF-16BE','UTF8');
		$line = unpack('n*',$line);
		
		$tableId = array_shift($line);
		$line = array_values($line);
		foreach($line as $id => $char) {
			$char = pack('n',$char);
			$char = mb_convert_encoding($char,'UTF8','UTF-16BE');
			$pox = chr($tableId) . $order[ $id ];
			$extLay[ $pox ] = $char;
		}
			
	}
	
	return [
		'dk'	=>	$MapLayKey,
		'map'	=>	$extLay]
		;
		
}

function loadLayer() {
	$layer = getFile('Hardware/BASE-LAY.txt') or die("Errore BASE-LAY\n");	
	$nStart = true;
	$button = array();

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
	return $button;	
}

function loadKeyboard($jsonFile) {
	
	$json = file_get_contents($jsonFile) or die("Errore nel file `$jsonFile`\n");
	$json = json_decode($json,true);
	if (!is_array($json)) die("Errore di codifica nel file `$jsonFile`\n");
	
	$imgFile = $json['img'];
	$imgFile = pathinfo($jsonFile,PATHINFO_DIRNAME) . '/'. $imgFile;
	
	$img = imagecreatefrompng($imgFile) or die("Errore nel file immagine `$imgFile` specificato in `$jsonFile`\n");
	
	if (isset($json['font'])) {
		$font = $json['font'];
		$font = pathinfo($jsonFile,PATHINFO_DIRNAME) . '/'. $font;
	} else {
		$font = 'lib/FONT.ttf';
	}
	
	if (!file_exists($font)) die("Errore nel file font `$font` specificato in `$jsonFile`\n");
	
	$json['font'] = $font;
	
	if (!isset($json['map'])) $json['map'] = array();
	
	foreach($json['rows'] as $row) {
	
		$charList = mb_convert_encoding($row['map'],'UTF-16BE','UTF8');
		$charList = unpack('n*',$charList);
		$x = 0;
		foreach($charList as $char) {
			if (isset($json['map'][$char])) continue;
			$button = $row;
			unset($button['map']);
			unset($button['buttons']);
			$button['x0'] = $button['x0'] + $x * $button['buttonW'];
			$button['k'] = true;
			$button['orig'] = chrW($char);
			$json['map'][$char] = $button;
			$x++;
		}
	}
		
	$json['img'] = $img;
	$json['translate'] = loadLayer();
	return $json;
	
}

class LayoutMap {
	private $keyboard=null;
	public $type = 'x';
	public $id='';
	public $layout = array();
	public $flags = array();
	public $description = '';
	
	function __construct(&$kbd,$description) {
		$this->keyboard = $kbd;
		$this->description = $description;
		}
		
	public function hasKeys() { return count($this->layout)>0; }
		
	function drawLayout($fileOut,&$index=array()) {
		
		$desc = $this->description;
		
		$button = array();
		$index[ pathinfo($fileOut,PATHINFO_BASENAME) ] = $desc;
		
		$wh = imagesx($this->keyboard['img']);
		$he = imagesy($this->keyboard['img']);
		$im = imagecreate($wh,$he);
		
		imagecopy($im,$this->keyboard['img'],0,0,0,0,$wh,$he);
		
		$pal = [
			imagecolorallocate($im,128,128,128),
			imagecolorallocate($im,0,0,0),
			imagecolorallocate($im,0,0,255),
			imagecolorallocate($im,128,0,0)
			
		] ;
		
		foreach($this->layout as $key => $char) {
						
			if (!isset($this->keyboard['map'][$key])) {
				echo "Bad Key: $key\n";
				continue;
			}	
			
			$k = $this->keyboard['map'][$key];
			
			if ($char instanceof SpecialKey) {
				
				$k = array_merge($k,$char->prop);
				$char = "$char";
				
			} else {
				
				$char = pack('n*',$char);
				$char = mb_convert_encoding($char,'UTF8','UTF-16BE');
						
			}
					
			
			$k['text'] = $char;
			
			$button[ $key ] = $k;	
		}
		
		foreach($this->keyboard['button'] as $key => $k) {
			if ($key == 'Space') continue;
			
			if (!isset($k['text'])) $k['text'] = $key;
			$k['pal'] = in_array($key,$this->flags) ? 1:0;
			$button[ $key ] = $k;
		}
		
		$button['Space'] = $this->keyboard['button']['Space'];
		$button['Space']['text'] = $desc;
		
		foreach($button as $key) {
			
			if (isset($key['pal'])) {
				$c = $pal[ $key['pal'] ] ;
			} else {
				$c = $pal[ 1 ] ;
			}
			
			if (isset($key['size'])) {
				$s = $key['size'];
			} else {
				$s = 12;
			}
			
			$this->ttfButton($im,$this->keyboard['padding'],$key,$s,$this->keyboard['font'],$c,$pal);
		}
		
		imagepng($im,$fileOut);
		imagedestroy($im);
		
	}
	
	private function ttfText(&$img,$x0,$y0,$wh,$he,$fontSize,$fontFile,$color,$text) {
		$box = imagettfbbox($fontSize, 0, $fontFile, $text);
		$tx0 = $box[6];
		$ty0 = $box[7];
		$tw = $box[2];
		$th = $box[3];
		$txHe = abs($th - $ty0);
		$txWh = abs($tw - $tx0);
		
		$cx =floor( ( $wh / 2 ) - ( $txWh / 2) ) ;
		$cy =floor( ( $he / 2 ) - ( $txHe / 2) ) ;
		$cxL = $cx;
		$cyL = $cy;
		$cx-=$tx0;
		$cy-=$ty0;
		$cx+=$x0;
		$cy+=$y0;

		return imagettftext($img,$fontSize,0,$cx,$cy,$color,$fontFile,$text);
		}
	
	private function ttfButton(&$img,$padding,$button,$fontSize,$fontFile,$color,$pal) {
		$x0 = $button['x0']+$padding;
		$y0 = $button['y0']+$padding;
		$wh = $button['buttonW']-$padding*2;
		$he = $button['buttonH']-$padding*2;
		$text = $button['text'];
		
		$box = imagettfbbox($fontSize, 0, $fontFile, $text);
		
		$tx0 = $box[6];
		$ty0 = $box[7];
		$tw = $box[2];
		$th = $box[3];
		$txHe = abs($th - $ty0);
		$txWh = abs($tw - $tx0);
		
		$cx =floor( ( $wh / 2 ) - ( $txWh / 2) ) ;
		$cy =floor( ( $he / 2 ) - ( $txHe / 2) ) ;
		$cxL = $cx;
		$cyL = $cy;
		$cx-=$tx0;
		$cy-=$ty0;
		$cx+=$x0;
		$cy+=$y0;

		if (isset($button['orig'])) $this->ttfText($img,$x0,$y0,floor($button['buttonW']/4), floor($button['buttonH']/5),8,$fontFile,$pal[3],$button['orig']);

		return imagettftext($img,$fontSize,0,$cx,$cy,$color,$fontFile,$text);
		
	}
	
	public function setKey($buttonCode,$buttonCharCode,$onlyOne=false) {
		if ($onlyOne and isset($this->layout[$buttonCode])) return;
		$this->layout[$buttonCode] = $buttonCharCode;
	}
	
	public function setKeyEx($buttonCode,$buttonCharCode) {
		$code = dechex($buttonCode);
		$code = strtoupper($code);
		$code = str_pad($code,4,'0',STR_PAD_LEFT);
		if (isset($this->keyboard['translate'][$code])) $code = $this->keyboard['translate'][$code];
		$code = hexdec($code);
		$this->layout[$code] = $buttonCharCode;
	}
	
	public function setKeyByCode($code,$char) {
		
		if (!$char instanceof SpecialKey) {
			$char = mb_convert_encoding($char,'UTF-16BE','UTF8');
			$char = unpack('n*',$char);
			$char = $char[1];
		}
		
		$code = substr($code,1);
		if (isset($this->keyboard['translate'][$code])) $code = $this->keyboard['translate'][$code];
		
		$code = hexdec($code);
		$this->layout[$code] = $char;
	}
		
}

function unloadKeyboard(&$json) {
	@imagedestroy($json['img']);
	$json=null;
}

$KeyFlagsMode = [
	'A'	=>	null,
	'B'	=>	['LCTRL'],
	'C'	=>	['Alt'],
	'D'	=>	['LCTRL','Alt'],
	'E'	=>	['LShift'],
	'F'	=>	['LCTRL','LShift'],
	'G'	=>	['Alt','LShift'],
	'H'	=>	['LCTRL','Alt','LShift'],
	'I'	=>	['AltGr'],
	'J'	=>	['AltGr','Shift'] ]
	;

$KeyFlagsPodorico = [
	'A'	=>	'',
	'B'	=>	'c',
	'C'	=>	'a',
	'D'	=>	'ca',
	'E'	=>	's',
	'F'	=>	'cs',
	'G'	=>	'as',
	'H'	=>	'cas',
	'I'	=>	'g',
	'J'	=>	'gs' ]
	;


function dePodoricoSyntax($str) {

	$PodoricoSyntax = [
		'<^>!'	=>	'AltGr',
		'#'		=>	'Win',
		'<^'	=>	'LCTRL',
		'^>'	=>	'RCTRL',
		'<+'	=>	'LShift',
		'+>'	=>	'RShift',
		'+'		=>	'Shift',
		'!'		=>	'Alt',
		'^'		=>	'CTRL'] ;

	foreach($PodoricoSyntax as $k => $v) {
		$str = str_replace($k," $v ",$str);
		}
	
	return '[ '.trim( preg_replace('/\\x20+/',' ',$str),' ').' ]' ;
	
	}

$vars = parse_ini_file('ExtConfig/Vars.ini') or die("Errore variabili `Vars.ini`\n");
$varsNames = parse_ini_file('ExtConfig/VarsNames.ini') or die("Errore variabili `VarsNames.ini`\n");

$RootHelp = '';
foreach($varsNames as $k => $v) {
	if (!isset($vars[$k])) continue;
	$x = dePodoricoSyntax($vars[$k]);
	$x = trim($x,"[] ");
	$RootHelp .= str_pad($x,40,' ')."$v\n";
	}
	
$RootHelp = str_replace('`','',$RootHelp);
$RootHelp = str_replace('"','""',$RootHelp);
$RootHelp = str_replace("\t","`t",$RootHelp);
$RootHelp = str_replace("\n","`n",$RootHelp);

$Keyboard = loadKeyboard('Hardware/KEYBOARD.json');
$groupImg = array();

$file = getFile('ExtConfig/NamedKeys.txt') or die("Errore nel file `NamedKeys.txt`\n");
$NamedKeysDK = '';
$NickKeys = array();

foreach($file as $num => $line) {
	$num++;
	$line = str_replace(["\xEF\xBB\XBF","\r","\n","\0"],'',$line);
	$line = str_replace("\t",' ',$line);
	$line = trim($line,' ');
	if ($line=='') continue;
	$line = preg_replace('/\\x20+/',' ',$line);
	$tok = explode(' ',$line,2);
	
	if ($tok[0]=='.') {
		if ($NamedKeysDK) die("Duplice definizione DeadKey per `NameKeys.txt` alla linea $num\n");
		$NamedKeysDK = $tok[1];
		continue;
	}
	
	if (count($tok)==2) {
		$NickKeys[ $tok[0] ] = $tok[1];
		continue;
	}
	
	die("Errore definizione sul file `NameKeys.txt` alla linea $num\n");
	
}

if (!$NamedKeysDK) die("Definizione DeadKey assente per `NameKeys.txt`\n");

$file = getFile('ExtConfig/Translators.txt') or die("Errore su `Translators`\n");
$transKey = '';

$Translators = array();
$DKHIndex = array();

foreach($file as $num => $line) {
	$num++;
	$line = str_replace(["\xEF\xBB\XBF","\r","\n","\0"],'',$line);
	list($line)=explode(';',$line,2);
	$line = str_replace("\t",' ',$line);
	$line = trim($line,' ');
	if ($line=='') continue;
	$line = preg_replace('/\\x20+/',' ',$line);
	$tok = explode(' ',$line);
	
	if ($tok[0]=='.') {
		if ($transKey) die("Duplice definizione DeadKey per `Translators.txt` alla linea $num\n");
		$transKey = $tok[1];
		continue;
	}
	
	if (count($tok)>3) {
		if (isset($Translators[$tok[0]])) die("Duplice definizione DeadKey per `Translators.txt` alla linea $num\n");
		if (isset($tok[4])) $txt = $tok[4]; else $txt = chrW(hexdec($tok[2])).' '.chrW(hexdec($tok[3]));
		$Translators[$tok[0]] = array(
			's'	=>	hexdec($tok[1]),
			'o'	=>	hexdec($tok[2]),
			'm'	=>	hexdec($tok[3]),
			't'	=>	$txt)
			;
		continue;
	}
	
	die("Errore definizione sul file `Translators.txt` alla linea $num\n");
}

if (!$transKey) die("Definizione DeadKey assente per `Translators.txt`\n");

$file = getFile('ExtLayout/index.txt') or die("Errore nel file index\n");
$ExtLayout = array();

foreach($file as $num => $line) {
	$num++;
	$line = str_replace(["\xEF\xBB\XBF","\r","\n","\0"],'',$line);
	$line = str_replace("\t",' ',$line);
	$line = trim($line,' ');
	if ($line=='') continue;
	$line = preg_replace('/\\x20+/',' ',$line);
	$line = str_replace('::',"\0",$line);
	$line = explode("\0",$line);
	if (count($line)!=2) die("Errore alla linea $num del file `index.txt`\n");
	$subFile = trim($line[1],' ');
	$deadKey = trim($line[0],' ');
	if (stripos("{$subFile}\n",".txt\n")===false) $subFile.='.txt';
	$mapId = mkId($deadKey);
	if (isset($ExtLayout[$mapId])) die("Duplice definizione per `{$deadKey}` nel file `$subFile`\n");
	$ExtLayout[$mapId] = parseMapLay("ExtLayout/$subFile",$deadKey);
}

$ExtLayout = array_values($ExtLayout);


$ls = glob('DeadKeys/*.txt');

$deadKeys = array();
foreach($ls as $file) {
	parseFile($file,$deadKeys);
	}

$deadKeys = array_values($deadKeys);

$template = file_get_contents('lib/Keyboard.ahk') or die("Errore di accesso al template\n");
$template = str_replace("\xEF\xBB\xBF",'',$template);

$out = "\xEF\xBB\xBF";
$out.= $template."\r\n";

$out.= "; Dati: \r\n";

foreach($ExtLayout as $num => $data) {
	$out.= "; MAP-LAY {$data['dk']}\r\n";
	$out.= "ExtKeysMap{$num} := Object()\r\n";	
	
	foreach($data['map'] as $k => $v) {
		$out.= "ExtKeysMap{$num}[\"{$k}\"] := \"{$v}\"\r\n";
	}

}

$deadKeysMaps = array();

foreach($deadKeys as $num => $data) {
	
	$out.= "\r\n";
	$out.= "; DeadKey {$data['dk']}\r\n";
	$out.= "DeadKey{$num} := Object()\r\n";
		
	foreach($data['map'] as $code => $char) {
		
		$type = $code[0];
		$sid = $num.$type;
		
		if (!isset($deadKeysMaps[$sid])) {
			
			if (@$KeyFlagsMode[$type]) {
				$xy=' '.implode(' + ',$KeyFlagsMode[$type] );
			} else {
				$xy='';
			}
			
			$deadKeysMaps[$sid] = new LayoutMap($Keyboard,trim("DeadKey ".dePodoricoSyntax($data['dk'])." $xy"));
			$deadKeysMaps[$sid]->flags = $KeyFlagsMode[$type] ? $KeyFlagsMode[$type] : [];
			$deadKeysMaps[$sid]->type = $type;
			$deadKeysMaps[$sid]->id = 'DK-'.$num.'-'.$type;
			
		}
		
		$deadKeysMaps[$sid]->setKeyByCode($code,$char);
		
		$out.= "DeadKey{$num}[\"{$code}\"] := \"{$char}\"\r\n";
	}
}

$out.="\r\n";

foreach($deadKeysMaps as $num => $KeysMap) {
	
	$fileOut = "out/{$KeysMap->id}.png";
	
	if (!$KeysMap->hasKeys()) {
		@unlink($fileOut);
		continue;
		}
		
	$KeysMap->drawLayout($fileOut,$DKHIndex);
	$sid = "DK{$num}";
	
	if (!isset($groupImg[$sid])) {
		$groupImg[$sid] = array(
			'g'	=>	'DK',
			'i'	=>	$num,
			'l'	=>	array()	)
			;
	}
	
	$groupImg[$sid]['l'][] = $fileOut;
	
}

$deadKeysMaps = $KeysMap = null;

$out.= "; Nick\r\n";
$out.= "NickKeys := Object()\r\n";	

foreach($NickKeys as $k => $v) {
	$out.= "NickKeys[\"{$k}\"] := \"{$v}\"\r\n";
	}

$Podorico ='; {${██@PODORICO@██}$} ;';
$out.="$Podorico\r\n";

$out.= "; Translators\r\n";

$o = array();
foreach($Translators as $key => $data) {
	$s = array();
	
	foreach( $data as $k => $v) {
		if ($k == 't') continue;
		$s[] = '"'.$k.'":'.$v;
		}
	
	$s = implode(', ',$s);
	$o[] = '"'.$key.'":{'.$s.'}';
	}
$o = implode(', ',$o);
$out.='Trs := {'.$o.'}'."\r\n";

$GLayout = new LayoutMap($Keyboard,"Translators ".dePodoricoSyntax($transKey));
foreach($Translators as $key => $data) {
	
	$x = new SpecialKey($data['t']);
	$x->pal = 2;
	$x->size = 8;
	$GLayout->setKeyEx( ord($key) , $x ) ;
}

$GLayout->drawLayout('out/Translators.png',$DKHIndex);

$out.="; Hotkeys: \r\n";

foreach($ExtLayout as $num => $data) {
	$out.= "; MAP-LAY {$data['dk']} \r\n";
	$out.= "{$data['dk']}::XKey(ExtKeysMap{$num}, \"Ext-{$num}\")\r\n";
	$out.="\r\n";	
}

$GLayouts = array();
$ILayouts = array();

foreach($ExtLayout as $num => $data) {
	
	foreach($data['map'] as $key => $char) {
		$k1 = $key[0];
		$k2 = $key[1];
		$sid = $num.$k1;
		
		if (!isset($GLayouts[$sid])) {
			$GLayouts[$sid] = new LayoutMap($Keyboard,"Ext ".dePodoricoSyntax($data['dk'])." + $k1");
			$GLayouts[$sid]->id = "Ext-{$num}-".ord($k1);
		}
		
		if (!isset($ILayouts[$num])) {
			$ILayouts[$num] = new LayoutMap($Keyboard,"Ext ".dePodoricoSyntax($data['dk']));
			$ILayouts[$num]->id = "Ext-{$num}";
			$ILayouts[$num]->done = array();
		}
		
		if (!isset($ILayouts[$num]->done[$k1])) {
			$ILayouts[$num]->done[$k1] = true;
			$x = new SpecialKey($char);
			$x->pal = 2;
			$x->size=12;
			$ILayouts[$num]->setKeyEx(ord($k1),$x);
			}
		
		$char = mb_convert_encoding($char,'UTF-16BE','UTF8');
		$char = unpack('n*',$char);
		$char = $char[1];
		
		$GLayouts[$sid]->setKey(ord($k2),$char);
						
	}
}

foreach($GLayouts as $GLayout) {
	$file = 'out/'.$GLayout->id.'.png';
	if (!$GLayout->hasKeys()) {
		@unlink($file);
		continue;
		}
	
	$GLayout->drawLayout($file,$DKHIndex);
	}

foreach($ILayouts as $GLayout) {
	$file = 'out/'.$GLayout->id.'.png';
	if (!$GLayout->hasKeys()) {
		@unlink($file);
		continue;
		}
	
	$GLayout->drawLayout($file,$DKHIndex);
	}

$GLayouts=$ILayouts=$GLayout=null;

$ls = glob('out/*.png');
$imgs = array();
$imgt = array();
foreach($ls as $k) {
	if (preg_match('/^out\\/(?<file>DK-(?<dk>[0-9]{1,3})-(?<f>[A-J]{1})\\.png)$/',$k,$match)) {
		$id = "d".$match['dk'].$KeyFlagsPodorico[$match['f']];
		$imgs[$id] = $match['file'];
		$imgt[$id] = $DKHIndex[ $match['file'] ];
		continue;
	}
	
	if (preg_match('/^out\\/(?<file>Ext-(?<dk>[0-9]{1,3})-(?<f>[0-9]{1,6})\\.png)$/',$k,$match)) {
		$id = "e".$match['dk'].chrW($match['f']);
		$imgs[$id] = $match['file'];
		$imgt[$id] = $DKHIndex[ $match['file'] ];
		continue;
	}
	
	if (preg_match('/^out\\/(?<file>Ext-(?<dk>[0-9]{1,3})\\.png)$/',$k,$match)) {
		$id = "e".$match['dk'];
		$imgs[$id] = $match['file'];
		$imgt[$id] = $DKHIndex[ $match['file'] ];
		continue;
	}
	
	if ($k=='out/Translators.png') {
		$imgs['t'] = 'Translators.png';
		$imgt['t'] = $DKHIndex[ 'Translators.png' ];
		}
		
}

$imgs['*'] = '';
$imgt['*'] = 'Main Layout';

$prev = "HelpIndex := Object()\r\n";

foreach($imgs as $id => $v) {
	$prev.="HelpIndex[\"".str_replace('"','""',$id)."\"] := \"{$v}\"\r\n";
	
}
$x = "";
foreach($imgt as $id => $v) {
	$y = "{$id}`t$v`n";
	$x.= str_replace('"','""',$y);
}

$prev.= "HelpText := \"$x\"\r\n";
$prev.= "RootHelp := \"$RootHelp\"\r\n";

$prev.="HPImg := Object()\r\n";
$prev.="HPTxt := Object()\r\n";
$prev.="HPMax := ".count($DKHIndex)."\r\n";

$x=0;
foreach($DKHIndex as $file => $text) {
	$prev.="HPImg[{$x}] := \"".str_replace('"','""',$file)."\"\r\n";
	$prev.="HPTxt[{$x}] := \"".str_replace('"','""',$text)."\"\r\n";
	$x++;
	}

$out = str_replace($Podorico,$prev,$out);

$x = file_get_contents('lib/prevHotkeys.ahk') or die("Errore di accesso su `prevHotkeys.ahk`\n");
$x = str_replace("\xEF\xBB\xBF","",$x);

$out.="$x\r\n";
$x = null;

foreach($deadKeys as $num => $data) {
	$out.= "\r\n";
	$out.= "; DeadKey {$data['dk']}\r\n";
	$out.= "{$data['dk']}::DKey(DeadKey{$num}, \"DK-{$num}\")\r\n";
	$out.= "\r\n";
}

$out.= "{$NamedKeysDK}::SKey(NickKeys)\r\n";
$out.= "\r\n";

$out.= "{$transKey}::RTranslator(Trs)\r\n";
$out.= "\r\n";

$out.= '{$LastHelp}::HelpEx()'."\r\n";
$out.= "\r\n";

$out.= '{$HelpGui}::HelpGui()'."\r\n";

$x = file_get_contents('lib/hotkeys.ahk') or die("Errore di accesso su `hotkeys.ahk`\n");
$x = str_replace("\xEF\xBB\xBF","",$x);

$out.=$x;
$x=null;

$out.= "\r\n";
$out = setVars($out);

file_put_contents('out/KeyboardExtender.ahk',$out) or die("Errore di salvataggio\n");

$x = file_get_contents('ExtConfig/help.txt') or die("Errore di accesso su `help.txt`\n");
$x = str_replace("\xEF\xBB\xBF","",$x);
$x = setVars($x);
$x = dePodoricoSyntax($x);
$x = trim($x,"\t\r\n[] ");

file_put_contents('out/HELP',$x) or die("Errore di salvataggio\n");
unloadKeyboard($Keyboard);

