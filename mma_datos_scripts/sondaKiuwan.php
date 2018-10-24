#!/usr/bin/php
<?php

function kiuwanCall($path) {

    // userAPI
    $credentials="dXNlckFQSTp1c2VyX0FQSV8yMDE4";

    $curl="https://api.kiuwan.com/".$path;
    
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL,$curl);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($ch, CURLOPT_HTTPHEADER, array('Authorization: Basic '.$credentials));
    //curl_setopt($ch, CURLOPT_HTTPAUTH, CURLAUTH_BASIC);
    //curl_setopt($ch, CURLOPT_USERPWD, "$KW_USER:$KW_PASS");
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


$ret=kiuwanCall("info");
// print_r($ret);
// echo $ret['ReturnCode'].PHP_EOL;
// echo $ret['Headers']['x-quotalimit'][0].PHP_EOL;
// echo $ret['Headers']['x-quotalimit-remaining'][0].PHP_EOL;
// print_r($ret['Body']);

date_default_timezone_set('Europe/Madrid');
$timeStamp=date("Y-m-d H:i:s",strtotime("now"));
echo "[ ".$timeStamp." ] apiKiuwan [".$ret['ReturnCode']."] Limit:[".$ret['Headers']['x-quotalimit'][0]."] Remaining:[".$ret['Headers']['x-quotalimit-remaining'][0]."]";
?>

