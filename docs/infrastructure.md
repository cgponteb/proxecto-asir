# Infrastructure Architecture

This diagram represents the AWS infrastructure defined in the Terraform configuration.

```mermaid
graph LR
    User((User))
    Admin((Admin))

    subgraph VPC [VPC]
        
        subgraph Public_Subnets [Public Subnets]
            direction TB
            ALB[Application Load Balancer]
            Bastion[Bastion Host]
            NAT[NAT Gateway]
        end
        
        subgraph Private_Subnets [Private Subnets]
            direction TB
            subgraph ASG [Auto Scaling Group]
                App1[App Instance 1]
                App2[App Instance 2]
            end
            BuildServer[Build Server]
            RDS[(RDS Database)]
        end
    end

    %% Access Layer
    User -->|HTTP/HTTPS| ALB
    Admin -->|SSH| Bastion
    
    %% Public to Private Routing
    ALB -->|Forward| App1
    ALB -->|Forward| App2
    
    Bastion -->|SSH| App1
    Bastion -->|SSH| App2
    Bastion -->|SSH| BuildServer
    Bastion -->|SQL| RDS
    
    %% Internal Connections
    App1 -->|SQL| RDS
    App2 -->|SQL| RDS
    
    %% Outbound Connectivity
    App1 -->|Outbound| NAT
    App2 -->|Outbound| NAT
    BuildServer -->|Outbound| NAT

    %% Force Layout Rank
    NAT ~~~ BuildServer
    
    classDef public fill:#d4edda,stroke:#28a745,color:black
    classDef private fill:#cce5ff,stroke:#004085,color:black
    classDef db fill:#f8d7da,stroke:#721c24,color:black
    
    class Public_Subnets public
    class Private_Subnets private
    class RDS db
```
