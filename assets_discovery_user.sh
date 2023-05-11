#!/bin/bash
#Declaración de variables

#El usuario tiene privilegios de root
if [[ $EUID -ne 0 ]]; then 
	echo "Este script requiere de privilegios de root"
	exit 1
fi

#Creación del usuario
read -p "Introduzca el nombre del usuario que se usará para el descubrimiento (si no existe se creará uno nuevo con ese nombre):" username
# Comprobación si el usuario ya existe
set -e
if id "$username" >/dev/null 2>&1; then
	echo -e "\n El usuario indicado ya existe. Procediendo a quitarle permisos de escritura al usuario ${username}. \n"
else
	echo -e "\n Creando el usuario ${username}... \n"
	read -s -p $'Introduzca una contraseña para el usuario \033[0;31mMIN 8 CARACTERES\033[0m:' password1
	
	echo

	read -s -p "Re-escriba su contraseña: " password2
	echo

	# Comparar passwords
	while [[ "$password1" != "$password2" ]]; do
    		echo "Las contraseñas no coinciden."
    		read -s -p "Introduzca la contraseña: " password1
    		echo
    		read -s -p "Re-escriba su contraseña:" password2
    		echo
	done

	useradd ${username};
  	if ! echo "${username}:${password1}" | chpasswd; then
    		echo "Error: Contraseña Inválida"
    		exit 1
	fi
fi

#Modificación del fichero SSH
echo -e "\n\n [*]Añadiendo el usuario $username al fichero de configuración SSH para que se pueda conectar mediante este protocolo...\n"
sudo sed -i "s/AllowUsers.*/& $username/" /etc/ssh/sshd_config

systemctl restart sshd
#Eliminación de privilegios al usuario
discovery_privileges=$(find / -type f -perm /u=w -user ${username} 2> /dev/null)
echo -e "[*]Archivos con permiso de escritura para ${username}: \n $discovery_privileges \n \nEliminando...\n"

while IFS= read -r file; do
    sudo chmod -w "$file"
done <<< "$discovery_privileges"

echo -e "Se han eliminado los permisos de escritura para ${username}."

