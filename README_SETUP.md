# Guía de Configuración del Entorno (WSL)

Esta guía describe el procedimiento para preparar el entorno de desarrollo en Windows utilizando WSL (Windows Subsystem for Linux) para el despliegue del proyecto.

## 1. Instalación de WSL y Ubuntu

En caso de no disponer de WSL instalado:

1.  Abrir PowerShell como Administrador.
2.  Ejecutar: `wsl --install`
3.  Reiniciar el equipo si se solicita.
4.  Al iniciarse la terminal de Ubuntu, configurar el usuario y contraseña.

## 2. Instalación de Herramientas Base

En la terminal de Ubuntu (WSL), actualizar e instalar herramientas comunes:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl unzip git software-properties-common
```

## 3. Instalación de Terraform

Procedimiento según la guía oficial de HashiCorp:

```bash
# Instalar clave GPG y repositorio
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Instalar Terraform
sudo apt update && sudo apt install terraform
```

## 4. Instalación de Ansible

Ansible puede instalarse vía pip o repositorio PPA. Se utilizará PPA para disponer de una versión reciente:

```bash
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible
```

Instalación de dependencias para AWS:

```bash
# En Ubuntu 24.04+, instalar librerías de Python vía apt para evitar conflictos (PEP 668)
sudo apt install -y python3-boto3 python3-botocore
# Instalar la colección de AWS y MySQL para Ansible
ansible-galaxy collection install amazon.aws community.mysql
```

## 5. Instalación de AWS CLI

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

## 6. Configuración de Credenciales (Pluralsight Sandbox)

Cada inicio de Sandbox en Pluralsight genera nuevas credenciales.

1.  Copiar las credenciales del panel de Pluralsight (Access Key, Secret Key, Session Token).
2.  Ejecutar `aws configure` o editar manualmente `~/.aws/credentials`.

Ejemplo de `~/.aws/credentials`:

```ini
[default]
aws_access_key_id = ASIA...
aws_secret_access_key = ...
aws_session_token = ...
```

## 7. Verificar Instalación

```bash
terraform --version
ansible --version
aws sts get-caller-identity
```
