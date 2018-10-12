#!/usr/bin/php
<?php
include 'functionsKiuwan.php';

if ($argc < 2 ) {
    exit( "Usage: ".$argv[0]." <ApplicationName>\n" );
}
$APPL=$argv[1];

// Buscamos si existe la aplicacion en KW
$ret=kiuwanCall("apps/".$APPL);
if ( $ret['ReturnCode'] == 200 ) {
    // Borramos la aplicacion en KW
    $ret=kiuwanDELETE("applications?application=".$APPL);
    if ( $ret['ReturnCode'] != 200 ) {
        echo "ReturnCode: [".$ret['ReturnCode']."]".PHP_EOL;
        print_r($ret);
    }
} else {
    echo "ERROR: ReturnCode:[".$ret['ReturnCode']."] ReturnCodeKiuwan:[".$ret['Body']['errors'][0]['code']."] ".$ret['Body']['errors'][0]['message'].PHP_EOL;
}
 
?>