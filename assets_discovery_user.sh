#!/bin/bash

#El usuario tiene privilegios de root
if [[ $EUID -ne 0 ]]; then 
	echo "Este script requiere de privilegios de root"
	exit 1
fi

#Creación del usuario
# Comprobación si el usuario ya existe
if id "discovery" >/dev/null 2>&1; then
	echo -e "El usuario discovery ya existe. Procediendo a quitarle permisos de escritura... \n"
else
	useradd discovery;
fi

#Eliminación de privilegios al usuario
discovery_privileges=$(sudo find / -type f -perm /u=w -user discovery 2> /dev/null)
echo -e "Archivos con permiso de escritura para discovery: \n $discovery_privileges \n \nEliminando...\n"

while IFS= read -r file; do
    sudo chmod -w "$file"
done <<< "$discovery_privileges"

echo -e "Se han eliminado los permisos de escritura para 'discovery'."
