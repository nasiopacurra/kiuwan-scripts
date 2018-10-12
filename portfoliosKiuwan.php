#!/usr/bin/php
<?php
include 'functionsKiuwan.php';

$ret=kiuwanCall("portfolios");
// print_r($ret);
echo $ret['ReturnCode'].PHP_EOL;
// echo $ret['Headers']['x-quotalimit'][0].PHP_EOL;
// echo $ret['Headers']['x-quotalimit-remaining'][0].PHP_EOL;
print_r($ret['Body']);
 
?>