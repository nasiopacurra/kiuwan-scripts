#!/usr/bin/php
<?php
// ---------------------------------------------------------------------------
// Utilidades para Rama Integracion en LDAP
//
// ./obtenerServicioIntegracion.php listar
// ./obtenerServicioIntegracion.php listar |more intCont_calidad
// ./obtenerServicioIntegracion.php add intCont_calidad AMASA3W
// ./obtenerServicioIntegracion.php del intCont_calidad AMASA3W
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Function listar: Emite la relacion en formato <groupName>,<idWin>
// 					de los uniqueMember de los cn 
//					de la rama OU=integracion, OU=servicios, DC=mutua, DC=es
// ---------------------------------------------------------------------------
function listar() {
	global $ldap_server;
	global $ldap_port;
	global $auth_user;
	global $auth_pass;
	
	$base_dn = "OU=integracion, OU=servicios, DC=mutua, DC=es";
	$filter = "(cn=*)";
	
	// connect to server
	if ($connect=ldap_connect($ldap_server, $ldap_port)) { 
		// bind to server
		if ($bind=@ldap_bind($connect, $auth_user, $auth_pass)) { 
			// search active directory
			if ($search=@ldap_search($connect, $base_dn, $filter)) { 
				$count=ldap_count_entries($connect,$search);
				$info = ldap_get_entries($connect, $search);
				$cnt=0;
				foreach($info as $clave => $valor){
					$groupName=$valor["cn"][0];
					if (is_array($valor)){ 
						if ( !array_key_exists('uniquemember', $valor)) {
							echo $groupName.",[vacio]".PHP_EOL;
						} else {
							$countMembers=$valor["uniquemember"]["count"];
							if (is_numeric($countMembers)){
								foreach($valor["uniquemember"] as $clave1 => $valor1) {
									if ($clave1 <> "count") { 
										$idWin=str_replace("uid=","",$valor1);
										$idWin=str_replace(",ou=personales,ou=usuarios,dc=mutua,dc=es","",$idWin);
										$idWin=str_replace(",ou=especiales,ou=usuarios,dc=mutua,dc=es","",$idWin);
										echo $groupName.",".$idWin.PHP_EOL; 
									}
								}
							}
						}
					}
				}
			} else {
				echo "ERROR: en ldap_search".PHP_EOL;
			}
		} else {
			echo "ERROR: en ldap_bind".PHP_EOL;
		}
	} else {
		echo "ERROR: en ldap_connect".PHP_EOL;
	}
}

// ---------------------------------------------------------------------------
// Function insertar: Incluye un uniqueMember="uid=<idWin>,,ou=personales,ou=usuarios,dc=mutua,dc=es"
//					en la rama "cn=<groupName>,OU=integracion, OU=servicios, DC=mutua, DC=es"
// ---------------------------------------------------------------------------
function insertar($groupName, $idWin){
	global $ldap_server;
	global $ldap_port;
	global $auth_user;
	global $auth_pass;
	
  	$base_dn = "cn=".$groupName.", OU=integracion, OU=servicios, DC=mutua, DC=es";
	$uniqueMember['uniquemember']="uid=".strtoupper($idWin).",ou=personales,ou=usuarios,dc=mutua,dc=es";
	// connect to server
	if ($connect=ldap_connect($ldap_server, $ldap_port)) { 
		// bind to server
		if ($bind=@ldap_bind($connect, $auth_user, $auth_pass)) { 
			ldap_mod_add($connect, $base_dn, $uniqueMember);
		} else {
			echo "ERROR: en ldap_bind".PHP_EOL;
		}
	} else {
		echo "ERROR: en ldap_connect".PHP_EOL;
	}
}

// ---------------------------------------------------------------------------
// Function borrar: Elimina un uniqueMember="uid=<idWin>,,ou=personales,ou=usuarios,dc=mutua,dc=es"
//					de la rama "cn=<groupName>,OU=integracion, OU=servicios, DC=mutua, DC=es"
// ---------------------------------------------------------------------------
function borrar($groupName, $idWin){
	global $ldap_server;
	global $ldap_port;
	global $auth_user;
	global $auth_pass;
	
  	$base_dn = "cn=".$groupName.", OU=integracion, OU=servicios, DC=mutua, DC=es";
	$uniqueMember['uniquemember']="uid=".strtoupper($idWin).",ou=personales,ou=usuarios,dc=mutua,dc=es";
	// connect to server
	if ($connect=ldap_connect($ldap_server, $ldap_port)) { 
		// bind to server
		if ($bind=@ldap_bind($connect, $auth_user, $auth_pass)) { 
			ldap_mod_del($connect, $base_dn, $uniqueMember);
		} else {
			echo "ERROR: en ldap_bind".PHP_EOL;
		}
	} else {
		echo "ERROR: en ldap_connect".PHP_EOL;
	}
}

$ldap_server = "ldap://directorio.mutua.es";
$ldap_port = "389";
$auth_user = "uid=AdminIntegracion,ou=especiales,ou=usuarios,dc=mutua,dc=es";
$auth_pass = "LLuop87cbg";

if ($argc >= 2) {
	switch ($argv[1]) {
		case "list":
			echo "Listando Servicio de Integracion".PHP_EOL;
			listar();
			break;
		case "add":
			echo "Insertando uniqueMember=".strtoupper($argv[3])." en ".$argv[2].PHP_EOL;
			insertar($argv[2],$argv[3]);
			break;
		case "del":
			echo "Borrando uniqueMember=".strtoupper($argv[3])." en ".$argv[2].PHP_EOL;
			borrar($argv[2],$argv[3]);
			break;
	}
}
?>