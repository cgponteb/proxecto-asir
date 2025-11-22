# Guion de Demostración: Infraestructura y Despliegue en AWS

Guía de presentación para la defensa del proyecto (10 de diciembre).

## 1. Introducción (2 min)
*   **Objetivo**: Demostración de infraestructura de alta disponibilidad, escalable y automatizada.
*   **Stack Tecnológico**: Terraform (IaC), Ansible (Gestión de Configuración), AWS.
*   **Arquitectura**: Presentación del diagrama de red.
    *   **VPC**: Segmentación de red (Subredes Públicas/Privadas).
    *   **Acceso**: Load Balancer (Público) y Bastion Host (Gestión).
    *   **Seguridad**: Aplicación y Base de Datos aisladas en subredes privadas.

## 2. Despliegue de Infraestructura (5 min)
*   **Acción**: Ejecución del despliegue desde terminal.
    ```bash
    cd terraform && terraform apply --auto-approve
    ```
*   **Narrativa (durante el despliegue)**:
    *   Explicación de la estructura modular del código (`networking`, `compute`, `database`).
    *   Ventajas de la modularización: Reutilización, mantenimiento y orden.
*   **Hito**: Finalización del despliegue. Mostrar outputs (URL del Load Balancer).

## 3. Despliegue de Aplicación y Golden AMI (5 min)
*   **Contexto**: Inicialización de los servidores de aplicación.
*   **Explicación**: Concepto de **Golden AMI** (Inmutabilidad y tiempos de arranque reducidos).
*   **Acción**:
    1.  Verificación de instancias en consola AWS.
    2.  Ejecución del playbook de Ansible para generación de imagen:
        ```bash
        ansible-playbook playbooks/build_ami.yml ...
        ```
    3.  (Opcional) Mención a la pre-generación de la AMI para optimización de tiempos en la demo.
*   **Resultado**: Acceso a la aplicación web a través del ALB. Creación de tarea de prueba.

## 4. Resiliencia y Auto Scaling (3 min)
*   **Prueba de Alta Disponibilidad**:
    *   Simulación de fallo: Terminación manual de una instancia EC2 en la consola.
*   **Observación**:
    *   El Auto Scaling Group detecta la anomalía de salud.
    *   Aprovisionamiento automático de una nueva instancia de reemplazo.
    *   Continuidad del servicio garantizada por el Load Balancer.

## 5. Actualización sin Interrupciones (Rolling Update) (5 min)
*   **Escenario**: Despliegue de una nueva versión de la aplicación (v2.0).
*   **Acción**:
    1.  Actualización de la variable `app_ami_id` en `terraform.tfvars`.
    2.  Aplicación de cambios:
        ```bash
        terraform apply
        ```
*   **Explicación Técnica**:
    *   Detección de cambio en Launch Template.
    *   Política `instance_refresh`: Rotación secuencial de instancias.
*   **Visualización**: Monitorización en tiempo real del ciclo de vida de las instancias (Terminating -> Pending -> Running).

## 6. Conclusiones y Cierre
*   **Resumen**: Beneficios de la Infraestructura como Código, Inmutabilidad y Alta Disponibilidad.
*   **Limpieza**: Destrucción de recursos.
    ```bash
    terraform destroy
    ```
