#!/usr/bin/php
<?php
include 'functionsKiuwan.php';

if ($argc < 2 ) {
    exit( "Usage: ".$argv[0]." <ApplicationName>".PHP_EOL );
}
$APPL=$argv[1];

// Buscamos si existe la aplicacion en KW
$ret=kiuwanCall("apps/".$APPL);
print_r($ret);
?>