#!/usr/bin/php
<?php

// Entrada:	
// $text: texto sobre el que buscar
// $pattern: plantilla regexp a buscar
// $waited: resultado esperado true|false
// Salida:
// $passed: Resultado del proceso true|false
function comprobar ($text, $pattern, $waited) {
	// ponemos en Mayusculas quitando espacios
	$v=strtoupper(trim($text));
	// Buscamos la coincidencia
	$result=preg_match($pattern,$v);
	// comprobamos si pasa o no pasa
	$passed=($result==$waited);
	
	return $passed;
	
}

// array para probar 
$arr = array();
$arr[]=array("1.3.0",'/^[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+$/',true);
$arr[]=array("1.33.50",'/^[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+$/',true);
$arr[]=array("12.33.30-SNAPSHOT",'/^[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+$/',false);

$arr[]=array("1.3.0-SNAPSHOT",'/^[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+-SNAPSHOT$/',true);
$arr[]=array("10.33.100-SNaPsHOT",'/^[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+-SNAPSHOT$/',true);

$arr[]=array("1.3.0-beta",'/^[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+-BETA[[:digit:]]+$/',false);
$arr[]=array("1.3.0-beta1",'/^[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+-BETA[[:digit:]]+$/',true);
$arr[]=array("1.3.0-Beta99",'/^[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+-BETA[[:digit:]]+$/',true);
$arr[]=array("1.3.0BETA9",'/^[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+-BETA[[:digit:]]+$/',false);

$arr[]=array("1.3.0",'/^[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+-M[[:digit:]]+$/',false);
$arr[]=array("1.3.0-M99",'/^[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+-M[[:digit:]]+$/',true);
$arr[]=array("1.3.0-m99",'/^[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+-M[[:digit:]]+$/',true);
$arr[]=array("1.3.0M100",'/^[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+-M[[:digit:]]+$/',false);

$arr[]=array("1.3.0-RC",'/^[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+-RC[[:digit:]]+$/',false);
$arr[]=array("1.3.0-RC1",'/^[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+-RC[[:digit:]]+$/',true);
$arr[]=array("1.3.0-rc10",'/^[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+-RC[[:digit:]]+$/',true);

$arr[]=array("Delicias-ga",'/^[A-Z]+-GA$/',true);
$arr[]=array("Callao-GA",'/^[A-Z]+-GA$/',true);
$arr[]=array("Callao1-GA",'/^[A-Z]+-GA$/',false);
$arr[]=array("Callao-GA3",'/^[A-Z]+-GA$/',false);

$arr[]=array("Delicias-GA-SNAPSHOT",'/^[A-Z]+-GA-SNAPSHOT$/',true);
$arr[]=array("Callao-GA-SNaPShOT",'/^[A-Z]+-GA-SNAPSHOT$/',true);

$arr[]=array("Delicias-SR",'/^[A-Z]+-SR[[:digit:]]+$/',false);
$arr[]=array("Delicias-SR1",'/^[A-Z]+-SR[[:digit:]]+$/',true);

$arr[]=array("Callao-SR-SNAPSHOT",'/^[A-Z]+-SR[[:digit:]]+-SNAPSHOT$/',false);
$arr[]=array("Callao-SR1-SNAPSHOT",'/^[A-Z]+-SR[[:digit:]]+-SNAPSHOT$/',true);

foreach($arr as $k => $v) {
	$ret=comprobar($v[0],$v[1],$v[2]);
	echo "[".$v[0]."]->[".$v[1]."] --> ".($ret?"Passed":"NOT Pass").PHP_EOL;
}



//
//$ver="LATEST-SNAPSHOT";
//
//$appver_tipo = "R";
//	if (preg_match("/snapshot/i", $ver)) {
//		$appver_tipo = "S";
//	}
//	if (preg_match("/latest/i", $ver)) {
//		if ($appver_tipo == "S") {
//			$ver="latestSnapshot";
//		} else {
//			$ver="latestRelease";
//		}
//	}	
//echo "[ ".$appver_tipo." ]  ".$ver.PHP_EOL;
//
//
//
//
//   case "vers": 
//		// Validar Formato x.x.x o x.x.x-SNAPSHOT o x.x.x-betax
//		$v=strtoupper(trim($v));
//		if ( preg_match('/[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+/',$v) ) {
//			$bVers=true; 
//		}
//		if ( preg_match('/[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+-SNAPSHOT/',$v) ) {
//			$bVers=true; 
//		}
//		if ( preg_match('/[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+-beta[[:digit:]]+/',$v) ) {
//			$bVers=true; 
//		}
//		// Validar Formato x.x.x[-Mx|-RCx], 
//		if ( preg_match('/[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+-M[[:digit:]]+/',$v) ) {
//			$bVers=true; 
//		}
//		if ( preg_match('/[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+-RC[[:digit:]]+/',$v) ) {
//			$bVers=true; 
//		}
//		// Validar Formato (SOLO apparq) ESTACIÓN[-GA|-SRx|-GA-SNAPSHOT|-SRx-SNAPSHOT]
//		if ( preg_match('/[A-Z]+-GA/',$v) ) {
//			$bVers=true; 
//		}
//		if ( preg_match('/[A-Z]+-GA-SNAPSHOT/',$v) ) {
//			$bVers=true; 
//		}
//		if ( preg_match('/[A-Z]+-SR[[:digit:]]+/',$v) ) {
//			$bVers=true; 
//		}
//		if ( preg_match('/[A-Z]+-SR[[:digit:]]+-SNAPSHOT/',$v) ) {
//			$bVers=true; 
//		}
//		break;
//
//	
//
//
?>

