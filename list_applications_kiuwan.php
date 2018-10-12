#!/usr/bin/php
<?php
include 'functionsKiuwan.php';

$ret=kiuwanCall("apps/list");
// print_r($ret);
echo $ret['ReturnCode'].PHP_EOL;
// echo $ret['Headers']['x-quotalimit'][0].PHP_EOL;
// echo $ret['Headers']['x-quotalimit-remaining'][0].PHP_EOL;
// print_r($ret['Body']);
$nCorrectas=$nIncorrectas=0;
$nUO=$nTP=$nARQ=0;
foreach($ret['Body'] as $k => $v) {
    $appProvider=$cTipoSoftware=$cUO=$cArquitectura=null;
    if ( array_key_exists("applicationProvider",$v) ) {
       $appProvider=$v['applicationProvider'];
    } 
    $nUO++;$nTP++;$nARQ++;
    if ( array_key_exists("applicationPortfolios",$v) ) {
        foreach($v['applicationPortfolios'] as $k1 => $v1) {
            if ( $k1 == "TipoSoftware" ) { $cTipoSoftware=$v1; $nTP--; }
            if ( $k1 == "UO") { $cUO=$v1; $nUO--; }
            if ( $k1 == "Arquitectura" ) { $cArquitectura=$v1; $nARQ--; }
        }
    } 
    $status=( ! is_null($appProvider) &&
              ! is_null($cTipoSoftware) &&
              ! is_null($cUO) &&
              ! is_null($cArquitectura) );
    $linea="";
    if ( $status ) {
        $linea=$v['name']." CORRECTA ";
        $nCorrectas++;
    } else {
        $linea=$v['name']." ".$v['applicationBusinessValue']." ";
        $linea.=(is_null($appProvider)?"SinProveedor":$appProvider)." ";
        $linea.=(is_null($cTipoSoftware)?"SinTipoSoftware":$cTipoSoftware)." ";
        $linea.=(is_null($cUO)?"SinUO":$cUO)." ";
        $linea.=(is_null($cArquitectura)?"SinArquitectura":$cArquitectura)." ";
        $nIncorrectas++;
    }
    echo $linea.PHP_EOL;
} 
echo "Correctas  : [".$nCorrectas."]".PHP_EOL;
echo "Incorrectas: [".$nIncorrectas."]".PHP_EOL;
echo "SinTipoSoftware: [".$nTP."]".PHP_EOL;
echo "SinUO: [".$nUO."]".PHP_EOL;
echo "SinArquitectura: [".$nARQ."]".PHP_EOL;


// cat listado1.txt |grep -v CORRECTA |grep -v ":" |awk '{print $1}' |awk -F "-" '{print $1}' |grep -v "#" >tipos.txt
// cat tipos.txt |sort |uniq

?>