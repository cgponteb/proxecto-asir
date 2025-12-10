# Manual de Despliegue y Operación

Este documento detalla los procedimientos para desplegar, actualizar y destruir la infraestructura y la aplicación.

## 1. Despliegue Inicial de Infraestructura

El primer paso consiste en la creación de la red, la base de datos y el balanceador de carga. Puedes consultar el [diagrama de arquitectura](./infrastructure.md) para más detalle.

1.  **Acceder al directorio de infraestructura**:
    ```bash
    cd terraform
    ```
2.  **Inicializar Terraform** (descarga de plugins y proveedores):
    ```bash
    terraform init
    ```
3.  **Revisar el plan de ejecución**:
    ```bash
    terraform plan
    ```
4.  **Aplicar los cambios**:
    ```bash
    terraform apply
    ```
    *Confirmar la operación escribiendo `yes` cuando se solicite.*

Al finalizar, se obtendrán los datos de acceso necesarios, como `alb_dns_name` (URL de la aplicación) y `bastion_public_ip`.

## 2. Creación de la Imagen Base (Golden AMI)

Para permitir que el Auto Scaling Group lance instancias con la aplicación pre-configurada, es necesario generar una AMI (Amazon Machine Image).

13.  **Lanzamiento de Instancia de Construcción**:
    La infraestructura incluye un servidor dedicado (`build-server`) en la subred privada para este propósito. No es necesario lanzar instancias manuales.

2.  **Ejecución de Ansible**:
    Desde el entorno local (WSL), acceder al directorio `ansible`:
    ```bash
    cd ansible
    ```
    Ejecutar el playbook `build_ami.yml`. El inventario dinámico detectará automáticamente la instancia `build-server` (etiquetada como `Tier: Build`).
    Solo es necesario proporcionar la IP del Bastion para el túnel SSH:
    ```bash
    ansible-playbook playbooks/build_ami.yml -e "bastion_ip=<IP_BASTION>"
    ```
    *Nota: Sustituye `<IP_BASTION>` por el valor de `bastion_public_ip` obtenido en el paso 1.*

3.  **Generación de la AMI**:
    Desde la consola de AWS, seleccionar la instancia configurada y ejecutar "Actions > Image and templates > Create image".
    *   Nombre sugerido: `v1-todo-app`
    *   Registrar el **AMI ID** generado (ej. `ami-0123456789abcdef0`).

## 3. Despliegue de la Aplicación (Actualización ASG)

Una vez disponible la AMI con la aplicación:

1.  **Actualizar configuración**:
    Editar el archivo `terraform/terraform.tfvars`:
    ```hcl
    app_ami_id = "ami-0123456789abcdef0" # ID de la nueva AMI
    ```
2.  **Aplicar cambios**:
    ```bash
    terraform apply
    ```
    Terraform detectará la actualización en el Launch Template. La configuración de `instance_refresh` en el ASG iniciará la rotación automática de instancias (Rolling Update).

## 4. Verificación

1.  Obtener la URL del Load Balancer (`alb_dns_name`) desde el output de Terraform.
2.  Acceder a través de un navegador web.
3.  Verificar el correcto funcionamiento de la aplicación Todo-PHP.

## 5. Destrucción de Recursos

Para eliminar la infraestructura y evitar costes adicionales:

```bash
cd terraform
terraform destroy
```
