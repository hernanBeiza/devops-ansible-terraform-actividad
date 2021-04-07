# devops-ansible-terraform-actividad
 Ejercicio entregable de Ansible y Terraform para Diplomado DevOps Usach.

## Introducción

El siguiente plan de ejecución de terraform tiene por objetivo crear dos vms, sus interfaces de red y un clúster kubernetes.

#### VM Master

- Instalar automáticamente ansible

#### VM Nodo

- Recibir instrucción de VM Máster para instalar Java y Jenkins

## Ejecutar

- Estar logueado en Azure

```
az login
````

- Listar las subscripciones asociadas a la cuenta

```
az account list
````

- Seleccionar subscripción correspondiente al diplomado

```
az account set --subscription "Azure subscription 1"
````

- Revisar que estemos en la subscripción correspondiente

```
az account show
````

- Iniciar terraform

````
terraform init
````

- Revisar plan

````
terraform plan
````

- Ejecutar plan

````
terraform apply
````

