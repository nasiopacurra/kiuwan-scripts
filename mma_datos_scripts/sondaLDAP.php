#!/usr/bin/php
<?php
// ---------------------------------------------------------------------------
// Busca los datos en LDAP en base a un codigo de usuario (amasa3w)
// ---------------------------------------------------------------------------

$ret="";

	$ldap_server = "ldap://directorio.mutua.es";
	$ldap_port = "389";
	$auth_user = "uid=readerall,ou=especiales,ou=usuarios,dc=mutua,dc=es";
	$auth_pass = "mglcdc";
	$base_dn = "DC=mutua, DC=es";
	
	$filter = "(|(uid=amasa3w))";
	
	$msInicio=microtime(true);
	// connect to server
	if ($connect=ldap_connect($ldap_server, $ldap_port)) { 
		// bind to server
		if ($bind=@ldap_bind($connect, $auth_user, $auth_pass)) { 
			// search active directory
			if ($search=@ldap_search($connect, $base_dn, $filter)) { 
				$ret="OK";
			} else {
				$ret="ERROR: en ldap_search";
			}
		} else {
			$ret="ERROR: en ldap_bind";
		}
	} else {
		$ret="ERROR: en ldap_connect";
	}
	$msFinal=microtime(true);

date_default_timezone_set('Europe/Madrid');
$ret_return=date("Y-m-d H:i:s",strtotime("now"));
$ret_ping=($msFinal-$msInicio)*1000;
	
echo "[ ".$ret_return." ] LDAP ".$ret." [ ".number_format($ret_ping,6)." ms ]".PHP_EOL;

?>
