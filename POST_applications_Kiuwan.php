#!/usr/bin/php
<?php
include 'functionsKiuwan.php';

$arrJson=array(
    "name" => "appcalidad-scs-pruebaAMS",
    "model" => "CQM_Blocker",
    "description" => "appcalidad-scs-pruebaAMS",
    "businessValue" => "CRITICAL",
    "provider" => "MMA",
    "portfolios" => array(
        array(
            "portfolioName" => "Arquitectura",
            "portfolioValue" => "Distribuido"
        ),
        array(
            "portfolioName" => "UO",
            "portfolioValue" => "Calidad_y_Testing"
        ),
        array(
            "portfolioName" => "TipoSoftware",
            "portfolioValue" => "AplicacionWeb"
        )
    )
);

$ret=kiuwanPOST("applications",$arrJson);
// print_r($ret);
echo "ReturnCode: [".$ret['ReturnCode']."]".PHP_EOL;
// echo $ret['Headers']['x-quotalimit'][0].PHP_EOL;
// echo $ret['Headers']['x-quotalimit-remaining'][0].PHP_EOL;
print_r($ret['Body']);
 
?>