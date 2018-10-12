#!/usr/bin/php
<?php
include 'functionsKiuwan.php';

$ret=kiuwanCall("info");
// print_r($ret);
// echo $ret['ReturnCode'].PHP_EOL;
// echo $ret['Headers']['x-quotalimit'][0].PHP_EOL;
// echo $ret['Headers']['x-quotalimit-remaining'][0].PHP_EOL;
// print_r($ret['Body']);
 
date_default_timezone_set('Europe/Madrid');
$timeStamp=date("Y-m-d H:i:s",strtotime("now"));
echo "[ ".$timeStamp." ] apiKiuwan [".$ret['ReturnCode']."] Limit:[".$ret['Headers']['x-quotalimit'][0]."] Remaining:[".$ret['Headers']['x-quotalimit-remaining'][0]."]".PHP_EOL;
?>