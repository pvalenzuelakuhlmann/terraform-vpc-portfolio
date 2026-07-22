# Terraform VPC Portfolio

Proyecto de infraestructura como código que despliega una red privada virtual (VPC) 
en AWS desde cero, junto con un servidor EC2 accesible desde internet. El objetivo 
es demostrar el manejo de networking básico en AWS usando Terraform, sin depender 
de la VPC default de la cuenta.

## Arquitectura

- **VPC** (`10.0.0.0/16`): red privada aislada donde vive toda la infraestructura.
- **Subnet pública** (`10.0.1.0/24`): asigna IP pública automática a los recursos que caigan en ella.
- **Internet Gateway**: punto de entrada/salida de tráfico entre la VPC e internet.
- **Route Table**: enruta todo el tráfico saliente (`0.0.0.0/0`) hacia el Internet Gateway.
- **Route Table Association**: conecta la route table con la subnet pública.
- **Security Group**: permite tráfico entrante por HTTP (80) y SSH (22).
- **Instancia EC2**: servidor desplegado dentro de la subnet, protegido por el Security Group.

## Cómo ejecutarlo

```bash
terraform init
terraform plan
terraform apply
```

Al aplicar, se solicitará el valor de la variable `nombre_bucket` (si aplica a tu versión), 
u otras variables sin valor por defecto.

Al finalizar las pruebas, destruir los recursos para evitar costos:
```bash
terraform destroy
```

## Decisiones de diseño

Se optó por una subnet pública simple, sin separación público/privado ni NAT Gateway, 
priorizando simplicidad y costo cero para un proyecto de aprendizaje. En un entorno de 
producción real, la práctica recomendada sería separar la EC2 en una subnet privada, 
usando un NAT Gateway para tráfico saliente y exponiendo solo un load balancer en la 
subnet pública.

