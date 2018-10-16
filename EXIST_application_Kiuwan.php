#!/usr/bin/php
<?php
include 'functionsKiuwan.php';

if ($argc < 2 ) {
    exit( "Usage: ".$argv[0]." <ApplicationName>".PHP_EOL );
}
$APPL=$argv[1];

// Buscamos si existe la aplicacion en KW
$ret=kiuwanCall("apps/".$APPL);
if ( $ret['ReturnCode'] != 200 ) {
    echo "false".PHP_EOL;
} else {
    echo "true".PHP_EOL;
}
?>