#!/usr/bin/php
<?php
include 'functionsKiuwan.php';

if ($argc < 2 ) {
    exit( "Usage: ".$argv[0]." <ApplicationName>".PHP_EOL );
}
$APPL=$argv[1];

// Buscamos si existe la aplicacion en KW
$ret=kiuwanCall("apps/".$APPL);

$v=$ret['Body'];
    print_r($v);
    echo "Name=".$v['name'].PHP_EOL;
    echo "Label=".$v['label'].PHP_EOL;
    echo "Date=".$v['date'].PHP_EOL;
    echo "applicationBusinessValue=".$v['applicationBusinessValue'].PHP_EOL;
    echo "Provider=".$v['applicationProvider'].PHP_EOL;
    foreach($v['applicationPortfolios'] as $k1 => $v1) {
        echo $k1."=".$v1.PHP_EOL;
    }
    foreach($v['Main metrics'] as $k1 => $v1) {
        if ( $v1['name'] == "Lines of code" ) {
            echo "Lines of Code=".$v1['value'].PHP_EOL;
        }
    }

?>