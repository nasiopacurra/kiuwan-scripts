#!/usr/bin/php
<?php
// ---------------------------------------------------------------------------
// Busca los datos en LDAP en base a un codigo de usuario (amasa3w)
// ---------------------------------------------------------------------------

$ret_email = "";
if ($argc == 2) {

	$idWin = $argv[1];

	$ldap_server = "ldap://directorio.mutua.es";
	$ldap_port = "389";
	$auth_user = "uid=readerall,ou=especiales,ou=usuarios,dc=mutua,dc=es";
	$auth_pass = "mglcdc";
	$base_dn = "DC=mutua, DC=es";
	
	$filter = "(|(uid=".$idWin."))";
	
	// connect to server
	if ($connect=ldap_connect($ldap_server, $ldap_port)) { 
		// bind to server
		if ($bind=@ldap_bind($connect, $auth_user, $auth_pass)) { 
			// search active directory
			if ($search=@ldap_search($connect, $base_dn, $filter)) { 
				if (ldap_count_entries($connect,$search) == 1) {
					$info = ldap_get_entries($connect, $search);
					print_r($info, true);
					$ret_email = $info[0]["mail"][0];
				} else {
					echo "ERROR: ldap_count_entries > 1";
				}
			} else {
				echo "ERROR: en ldap_search";
			}
		} else {
			echo "ERROR: en ldap_bind";
		}
	} else {
		echo "ERROR: en ldap_connect";
	}
}

echo $ret_email.PHP_EOL;

?>
