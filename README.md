# Terraform VPC Portfolio

Proyecto de infraestructura como código que despliega una arquitectura de red
productiva en AWS: VPC segmentada en subnets pública/privada, salida a internet
controlada, balanceo de carga, y alta disponibilidad mediante Auto Scaling Group.

## Arquitectura

**Flujo de tráfico entrante:**

Internet → Internet Gateway → Application Load Balancer (subnets públicas, multi-AZ) → Target Group → Auto Scaling Group / EC2 (subnet privada)

**Flujo de salida desde la subnet privada:**

EC2 (subnet privada) → NAT Gateway (ubicado en subnet pública) → Internet Gateway → Internet

### Componentes

- **VPC** (`10.0.0.0/16`): red aislada base.
- **2 subnets públicas** (multi-AZ, requisito del ALB): alojan el Load Balancer y el NAT Gateway.
- **1 subnet privada**: aloja las instancias reales, sin IP pública directa.
- **Internet Gateway**: entrada/salida para la red pública.
- **NAT Gateway**: permite que la subnet privada salga a internet (actualizaciones, descargas) sin ser accesible desde afuera.
- **Application Load Balancer**: único punto expuesto a internet; enruta tráfico HTTP hacia el Target Group.
- **Auto Scaling Group + Launch Template**: mantiene entre 1 y 2 instancias saludables, con reemplazo automático si el health check del ALB falla.
- **Security Groups en cascada**: el ALB acepta tráfico de `0.0.0.0/0`; las instancias solo aceptan tráfico proveniente del Security Group del ALB.
- **Data source dinámico**: la AMI se resuelve automáticamente al AMI más reciente de Amazon Linux 2023 disponible, en vez de un ID fijo en el código.

## Cómo ejecutarlo

```bash
terraform init
terraform plan
```

⚠️ Este proyecto se mantiene validado hasta `terraform plan` intencionalmente.
NAT Gateway y Application Load Balancer generan costos por hora en AWS; se evita
`apply` para mantener el proyecto sin costo mientras sirve como pieza de portafolio.

Si se desea aplicar:

```bash
terraform apply
# ...verificar...
terraform destroy
```

## Decisiones de diseño

- **Subnet única privada** (en vez de una por AZ): simplificación deliberada para mantener el proyecto enfocado en el patrón de red, no en redundancia completa. En producción real, se replicaría la subnet privada en múltiples AZs.
- **HTTP sin certificado**: se omitió HTTPS/ACM para mantener el alcance del proyecto en el patrón de red; sería el siguiente paso natural en un entorno real.
- **`lifecycle.ignore_changes` en el AMI**: evita que futuras versiones de la AMI fuercen un reemplazo automático de infraestructura en cada `plan`; las actualizaciones de imagen se gestionarían como un cambio deliberado, no accidental.

## Qué aprendí

Construir esto en la práctica —en vez de copiar un ejemplo— dejó claro por qué cada
pieza de networking existe: qué pasa si falta la route table association, por qué
el NAT Gateway necesita estar en la subnet pública aunque sirva a la privada, y
cómo Terraform maneja (y a veces complica) las dependencias entre recursos cuyos
IDs no se conocen hasta el momento de aplicar.
