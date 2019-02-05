#!/usr/bin/php -q
<?php

$propertiesFile="_mma.properties";
if ( ! file_exists($propertiesFile) ) {
  die("Error NO EXISTE archivo de configuracion: [".$propertiesFile."]".PHP_EOL); 
} else {
  $userMM=$passMM="";
  $fp=fopen($propertiesFile,"r") or die("Error NO PUEDO LEER archivo de configuracion: [".$propertiesFile."]".PHP_EOL); 
  while(!feof($fp)){
    $arrLine=explode("=",fgets($fp));
    if ( $arrLine[0] == "USERMM" ) { $userMM=trim($arrLine[1]); }
    if ( $arrLine[0] == "PASSMM" ) { $passMM=trim($arrLine[1]); }
  }
  fclose($fp);
  if ( strlen($userMM) == 0 || strlen($passMM) == 0 ) {
    die("Error NO EXISTEN Variables de configuracion: [".$userMM.":".$passMM."]".PHP_EOL); 
  } 
}

$url = "http://".$userMM.":".$passMM."@srkmloadtest.mutua.es/wsRest/rc3/apirec/sendDeploy";

$json_file = array(
                "status" => "failed",
                "credential" => "mmaWebDeploy",
                "name" => "SoporteAceleradores_ACP_80",
                "started" => "2017-01-04T16:02:52.778629+00:00",
                "extra_vars" => array(
                               "NODE" =>  "dep010",
                               "DOMAIN" =>  "intranet.mutua.es",
                               "CLEAN_TMP" =>  true,
                               "APP_NAME" =>  " SoporteAceleradoresEAR",
                               "DEPLOY_STATICS" =>  true,
                               "AMBIT" =>  "interno",
                               "SERVER" =>  "ITapps01",
                               "ENVIRON" =>  "ACP",
                               "CONTEXT" =>  "soporteaceleradores",
                               "APP_VERSION" =>  "1.0.0",
                               "PORT" =>  "12037",
                               "CELL_NAME" =>  "ACPIT"
                ),
                "traceback" => "",
                "friendly_name" => "Job",
                "created_by" => "jmaba5e",
                "project" => "TecnoWebDeploy",
                "url" => "https://172.22.20.21/#/jobs/619",
                "finished" => "2017-01-04T16:04:23.290316+00:00",
                "hosts" => array(
                               "srkmoteans010" => array(
                                               "skipped" => 6,
                                               "ok" => 16,
                                               "changed" => 8,
                                               "dark" => 0,
                                               "failed" => false,
                                               "processed" => 1,
                                               "failures" => 0
                               ),
                               "srkmsaadep011" => array(
                                               "skipped" => 0,
                                               "ok" => 4,
                                               "changed" => 1,
                                               "dark" => 0,
                                               "failed" => true,
                                               "processed" => 1,
                                               "failures" => 1
                               ),
                               "srkmsaadep010" => array(
                                               "skipped" => 1,
                                               "ok" => 5,
                                               "changed" => 1,
                                               "dark" => 0,
                                               "failed" => false,
                                               "processed" => 1,
                                               "failures" => 0
                               )
                ),
                "playbook" => "deploy.yml",
                "limit" => "",
                "id" => 619,
                "inventory" => "ACP"
);
$content = json_encode($json_file);
 
$curl = curl_init($url);
curl_setopt($curl, CURLOPT_HEADER, false);
curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
curl_setopt($curl, CURLOPT_HTTPHEADER,array("Content-type: application/json"));
curl_setopt($curl, CURLOPT_POST, true);
curl_setopt($curl, CURLOPT_POSTFIELDS, $content);
$json_response = curl_exec($curl);
$status = curl_getinfo($curl, CURLINFO_HTTP_CODE);
if ( $status != 200 ) {
    die("Error: call to URL $url failed with status $status, response $json_response, curl_error " . curl_error($curl) . ", curl_errno " . curl_errno($curl));
}
 
curl_close($curl);
$response = json_decode($json_response, true);
print_r($response,true);
?>