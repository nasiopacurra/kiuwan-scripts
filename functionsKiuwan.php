<?php

$propertiesFile="_kiuwan.properties";
if ( ! file_exists($propertiesFile) ) {
  die("Error NO EXISTE archivo de configuracion: [".$propertiesFile."]".PHP_EOL); 
} else {
  $userKW=$passKW="";
  $fp=fopen($propertiesFile,"r") or die("Error NO PUEDO LEER archivo de configuracion: [".$propertiesFile."]".PHP_EOL); 
  while(!feof($fp)){
    $arrLine=explode("=",fgets($fp));
    if ( $arrLine[0] == "USERKW" ) { $userKW=trim($arrLine[1]); }
    if ( $arrLine[0] == "PASSKW" ) { $passKW=trim($arrLine[1]); }
  }
  fclose($fp);
  if ( strlen($userKW) == 0 || strlen($passKW) == 0 ) {
    die("Error NO EXISTEN Variables de configuracion: [".$userKW.":".$passKW."]".PHP_EOL); 
  } 
}
$credentials=base64_encode($userKW.":".$passKW);
$curl="https://api.kiuwan.com/";

function kiuwanCall($path) {
 
    global $credentials;
    global $curl;

    $curl.=$path;
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL,$curl);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($ch, CURLOPT_HTTPHEADER, array('Authorization: Basic '.$credentials));
    curl_setopt($ch, CURLINFO_HTTP_CODE, true);
    $headers=array();
    // this function is called by curl for each header received
    curl_setopt($ch, CURLOPT_HEADERFUNCTION,
      function($curl, $header) use (&$headers)
      {
        $len = strlen($header);
        $header = explode(':', $header, 2);
        if (count($header) < 2) // ignore invalid headers
          return $len;
   
        $name = strtolower(trim($header[0]));
        if (!array_key_exists($name, $headers))
          $headers[$name] = [trim($header[1])];
        else
          $headers[$name][] = trim($header[1]);
   
        return $len;
      }
    );
    if ( ! $result=curl_exec($ch) ) { die('Error: "'.curl_error($ch).'" - Code: '.curl_errno($ch)); }
    $httpcode=curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch); 
    
    return array("ReturnCode" => $httpcode,
                "Headers" => $headers,
                "Body" => json_decode($result,true));
}

function kiuwanPOST($path, $arrJson) {

    global $credentials;
    global $curl;

    $json=json_encode($arrJson);
   
    $curl.=$path;
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL,$curl);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($ch, CURLOPT_HTTPHEADER, array('Authorization: Basic '.$credentials, 'Content-type: application/json'));
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $json);
    if ( ! $result=curl_exec($ch) ) { die('Error: "'.curl_error($ch).'" - Code: '.curl_errno($ch)); }
    $httpcode=curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch); 
    
    return array("ReturnCode" => $httpcode,
                "Body" => json_decode($result,true));
}

function kiuwanDELETE($path) {

    global $credentials;
    global $curl;

    $curl.=$path;
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL,$curl);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($ch, CURLOPT_HTTPHEADER, array('Authorization: Basic '.$credentials));
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'DELETE');
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
    if ( ! $result=curl_exec($ch) ) { die('Error: "'.curl_error($ch).'" - Code: '.curl_errno($ch)); }
    $httpcode=curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch); 
    
    return array("ReturnCode" => $httpcode,
                "Body" => json_decode($result,true));
}
?>