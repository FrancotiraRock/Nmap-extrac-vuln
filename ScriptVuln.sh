#!/bin/bash

greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

# Inicializa la variable ip
ip=""

# Comprueba si se proporcionó un argumento
if [ $# -eq 0 ]; then
    echo "Por favor, proporciona el nombre del archivo como argumento."
    exit 1
fi

# Bandera para indicar si estamos recopilando líneas después de encontrar una vulnerabilidad
collectingLines=false

# Lee el archivo de salida línea por línea
while IFS= read -r line
do
  # Si la línea comienza con "Nmap scan report for", extrae la dirección IP
  if [[ $line == "Nmap scan report for"* ]]; then
    ip=$(echo $line | awk '{print $5}')
    echo -e ${blueColour}"\n\n\nDirección IP: $ip${endColour}" >> vulnerabilities.txt
  fi

  # Si la línea contiene "|   VULNERABLE:", activa la bandera para empezar a recopilar líneas
  if [[ $line == *"|   VULNERABLE:"* ]]; then
    collectingLines=true
    continue
  fi

  # Si estamos recopilando líneas después de encontrar una vulnerabilidad
  if [ "$collectingLines" = true ]; then
    # Imprime la línea actual en el archivo de vulnerabilidades
    echo -e "$line" >> vulnerabilities.txt

    # Verifica si la línea contiene más información sobre la vulnerabilidad
    if [[ $line == *"Disclosure date:"* ]]; then
      collectingLines=false  # Desactiva la bandera si se ha llegado al final de la información de la vulnerabilidad
    fi
  fi

done < "$1"
