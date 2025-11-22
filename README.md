# Proxecto ASIR: Infraestructura y Despliegue en AWS

Este proyecto demuestra el despliegue de una aplicación web (Todo-PHP) en una infraestructura de alta disponibilidad en AWS, utilizando **Terraform** para la Infraestructura como Código (IaC) y **Ansible** para la gestión de configuración.

## Arquitectura

La infraestructura se despliega en una VPC con las siguientes características:

*   **Alta Disponibilidad**: Distribución en 2 Zonas de Disponibilidad (AZs).
*   **Seguridad**:
    *   **Subredes Públicas**: Solo para el Balanceador de Carga (ALB) y NAT Gateway.
    *   **Subredes Privadas**: Para los servidores de aplicación (EC2) y la base de datos (RDS).
    *   **Bastion Host**: Punto de entrada único para administración (SSH).
*   **Escalabilidad**: Auto Scaling Group (ASG) para los servidores de aplicación.
*   **Base de Datos**: RDS MySQL gestionada.

## Requisitos Previos

*   Windows 10/11 con WSL2 (Ubuntu).
*   Cuenta de AWS (o Sandbox de Pluralsight).
*   Terraform >= 1.0.
*   Ansible >= 2.9.

Ver [Guía de Configuración](README_SETUP.md) para la instalación de las herramientas.

## Estructura del Proyecto

```text
proxecto-asir/
├── terraform/      # Código de infraestructura (VPC, EC2, RDS...)
├── ansible/        # Configuración de servidores (Apache, PHP, App)
├── app/            # Código fuente de la aplicación
└── docs/           # Documentación detallada
```

## Despliegue Rápido

1.  **Configuración de Credenciales AWS**:
    ```bash
    aws configure
    ```

2.  **Despliegue de Infraestructura**:
    ```bash
    cd terraform
    terraform init
    terraform apply
    ```

3.  **Configuración de Aplicación**:
    (Consultar [Manual de Despliegue](docs/manual_despliegue.md) para el flujo completo de creación de AMI y despliegue).

## Licencia

Proyecto educativo para el ciclo ASIR.
