# ArgoCD App-of-Apps Demo with Strimzi Kafka

This project demonstrates a comprehensive GitOps workflow using ArgoCD's "app-of-apps" pattern to manage a complete Kafka ecosystem with Strimzi. It showcases how to deploy, configure, and manage Apache Kafka clusters, topics, and related services using declarative GitOps principles.

## What This Project Demonstrates

### 🚀 GitOps with ArgoCD
- **App-of-Apps Pattern**: Hierarchical application management with automated sync
- **Sync Wave Management**: Controlled deployment ordering using ArgoCD sync waves
- **Local Git Server**: Real-time GitOps development workflow with instant feedback
- **Automated Sync**: Self-healing deployments with prune and sync policies

### ⚙️ Strimzi Kafka Operator
- **Cluster Configuration**: Deploy and manage Kafka clusters declaratively
- **Topic Management**: Automated Kafka topic creation and lifecycle management
- **Resource Optimization**: CPU, memory, and storage configuration for production workloads
- **High Availability**: Multi-broker setup with ZooKeeper and pod disruption budgets

### 📊 Kafka Ecosystem Components
- **Kafka UI**: Web-based cluster monitoring and topic management
- **Schema Registry**: Centralized schema management for Avro/JSON/Protobuf schemas
- **Schema Publishing**: Automated jobs for schema deployment and validation
- **Topic Examples**: Pre-configured topics with proper partitioning and replication

### 🔄 Schema Management Workflow
- **Schema Registry Integration**: Confluent Schema Registry for centralized schema storage
- **Automated Schema Publishing**: Jobs that validate and publish schemas on deployment
- **Version Control**: Schema evolution and compatibility management
- **GitOps Schema Deployment**: Schema-as-code with version tracking

### 🛠️ DevOps Best Practices
- **Infrastructure as Code**: All configurations stored in Git with versioning
- **Declarative Management**: Kubernetes-native resource definitions
- **Environment Consistency**: Reproducible deployments across environments
- **Observability**: Built-in monitoring and logging capabilities

## Learning Objectives

After working with this project, you'll understand how to:

### Strimzi Kafka Management
- **Deploy Kafka Clusters**: Configure multi-broker Kafka clusters with custom resource definitions
- **Manage Topics Declaratively**: Create and manage Kafka topics using KafkaTopic CRDs
- **Configure Resource Limits**: Set appropriate CPU, memory, and storage for Kafka brokers
- **Setup High Availability**: Implement ZooKeeper clusters and pod disruption budgets
- **Monitor Cluster Health**: Use Kafka UI and kubectl to monitor cluster status

### Schema Registry Operations
- **Deploy Schema Registry**: Setup Confluent Schema Registry alongside Kafka
- **Publish Schemas Automatically**: Create jobs that validate and publish schemas
- **Manage Schema Evolution**: Handle schema compatibility and versioning
- **Integrate with Applications**: Connect producers/consumers to Schema Registry

### GitOps Workflows
- **App-of-Apps Pattern**: Structure hierarchical application deployments
- **Sync Wave Orchestration**: Control deployment order with ArgoCD sync waves
- **Automated Deployments**: Configure self-healing and automated sync policies
- **Local Development**: Setup local Git servers for rapid iteration

### Kubernetes Best Practices
- **Namespace Management**: Organize resources across logical namespaces
- **Resource Management**: Configure requests, limits, and storage classes
- **Configuration Management**: Use ConfigMaps and Helm values for customization
- **Job Scheduling**: Deploy one-time and recurring jobs for maintenance tasks

## Use Cases

This project template can be adapted for various real-world scenarios:

### Event-Driven Microservices
- Deploy Kafka as the backbone for microservice communication
- Use Schema Registry to enforce data contracts between services
- Manage topic creation and configuration through GitOps
- Monitor message flows with Kafka UI

### Data Pipeline Management
- Setup Kafka Connect for data ingestion and export
- Configure topics with appropriate retention and partitioning
- Use schema evolution for data format changes
- Deploy processing jobs alongside the Kafka cluster

### Development Environment Setup
- Quickly spin up complete Kafka environments for development
- Test schema changes and topic configurations
- Validate applications against realistic Kafka setups
- Share consistent environments across development teams

### Production Kafka Deployment
- Adapt configurations for production workloads
- Implement proper resource limits and storage classes
- Setup monitoring and alerting with integrated tools
- Manage schema deployments through CI/CD pipelines

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [helm](https://helm.sh/docs/intro/install/)
- [git](https://git-scm.com/downloads)
- Python 3 (for local Git HTTP server)

## Quick Start

1. **Setup Kind cluster with ArgoCD:**
   ```bash
   ./setup-cluster.sh
   ```

2. **Setup local Git server:**
   ```bash
   ./setup-git-server.sh
   ```

3. **Deploy root application:**
   ```bash
   kubectl apply -f root-app.yaml
   ```

4. **Access ArgoCD UI:**
   - URL: http://localhost:30443
   - Username: `admin`
   - Password: (displayed after running setup-cluster.sh)

## Project Structure

```
.
├── apps/
│   ├── simple-app.yaml                    # ArgoCD Application for simple nginx app
│   ├── simple-app/                        # Helm chart for simple nginx app
│   │   ├── Chart.yaml
│   │   ├── values.yaml
│   │   └── templates/
│   ├── strimzi-operator.yaml              # ArgoCD Application for Strimzi operator (sync-wave: 1)
│   ├── kafka-cluster.yaml                 # ArgoCD Application for Kafka cluster (sync-wave: 2)
│   ├── kafka-cluster/                     # Helm chart for Kafka cluster
│   │   ├── Chart.yaml
│   │   ├── values.yaml
│   │   └── templates/
│   │       ├── kafka.yaml
│   │       ├── kafka-connect.yaml
│   │       └── pdb.yaml
│   ├── kafka-topics.yaml                  # ArgoCD Application for Kafka topics
│   ├── kafka-ui.yaml                      # ArgoCD Application for Kafka UI
│   ├── confluent-schema-registry-app.yaml # ArgoCD Application for Confluent Schema Registry
│   ├── confluent-schema-registry/         # Helm chart for Schema Registry
│   │   ├── Chart.yaml
│   │   └── values.yaml
│   ├── schema-publisher-job-app.yaml      # ArgoCD Application for schema publishing job (sync-wave: 3)
│   └── schema-publisher-job/              # Schema publisher job resources
│       ├── schema-publisher-config.yaml   # ConfigMap with Python script
│       └── schema-publisher-job.yaml      # Job definition
├── kafka-topics/              # Kafka topic definitions
│   ├── foo-topic.yaml         # Example Kafka topic
│   └── bar-topic.yaml         # Example Kafka topic
├── scripts/
│   ├── init-git.sh            # Initialize local Git server (alternative)
│   ├── sync-git.sh            # Sync changes to Git server
│   └── stop-git.sh            # Stop Git servers and cleanup
├── root-app.yaml              # Root ArgoCD Application (app-of-apps)
├── setup-cluster.sh           # Setup Kind cluster with ArgoCD
└── setup-git-server.sh        # Setup local Git server with HTTP/Git protocol
```

## Local Git Server Setup

This project uses a local Git server to enable real-time GitOps workflows:

1. **Git Daemon** serves on port 9418 (`git://host.docker.internal:9418/argocd-demo.git`)
2. **HTTP Server** serves on port 8090 for Git over HTTP
3. **Bare Repository** stored at `/tmp/argocd-demo.git` for serving to ArgoCD

### Git Server URLs:
- **From containers (ArgoCD)**: `git://host.docker.internal:9418/argocd-demo.git`
- **From localhost**: `git://localhost:9418/argocd-demo.git`
- **HTTP access**: `http://localhost:8090/argocd-demo.git`

## Adding New Applications

To add a new application to the app-of-apps pattern:

1. **Create Helm chart directory:**
   ```bash
   mkdir -p apps/my-new-app/{templates,charts}
   ```

2. **Create ArgoCD Application manifest:**
   ```yaml
   # apps/my-new-app.yaml
   apiVersion: argoproj.io/v1alpha1
   kind: Application
   metadata:
     name: my-new-app
     namespace: argocd
   spec:
     project: default
     source:
       repoURL: git://host.docker.internal:9418/argocd-demo.git
       targetRevision: HEAD
       path: apps/my-new-app
       helm:
         valueFiles:
         - values.yaml
     destination:
       server: https://kubernetes.default.svc
       namespace: default
     syncPolicy:
       automated:
         prune: true
         selfHeal: true
       syncOptions:
       - CreateNamespace=true
   ```

3. **Create Helm chart files** (use `apps/simple-app/` as template)

4. **Sync changes to Git server:**
   ```bash
   ./scripts/sync-git.sh
   ```

ArgoCD will automatically detect and deploy the new application within ~3 minutes.

## Strimzi Kafka Operator

This project includes the Strimzi Kafka operator for running Apache Kafka on Kubernetes:

### Components

1. **Strimzi Operator** (`apps/strimzi-operator.yaml`):
   - Deploys the Strimzi Kafka operator using the official Helm chart
   - Manages Kafka clusters, topics, and users via Custom Resources
   - Version: 0.47.0 with Kafka 3.8.0 support

2. **Kafka Cluster** (`apps/kafka-cluster.yaml`):
   - Example 3-node Kafka cluster with ZooKeeper
   - Persistent storage (10Gi for Kafka, 5Gi for ZooKeeper)
   - Entity operators for topic and user management
   - Pod disruption budgets for high availability

### Kafka Cluster Configuration

The default Kafka cluster includes:
- **3 Kafka brokers** with 1Gi memory, 500m CPU each
- **3 ZooKeeper nodes** with 512Mi memory, 250m CPU each  
- **Internal listeners** on ports 9092 (plain) and 9093 (TLS)
- **Persistent storage** with configurable storage classes
- **Topic and User operators** for resource management

### Accessing Kafka

Once deployed, you can access Kafka using:

```bash
# Check Kafka cluster status
kubectl get kafka -n kafka

# Check Kafka pods
kubectl get pods -n kafka

# Port forward to Kafka (for testing)
kubectl port-forward svc/my-cluster-kafka-bootstrap -n kafka 9092:9092

# Create a test topic
kubectl apply -f - <<EOF
apiVersion: kafka.strimzi.io/v1beta2  
kind: KafkaTopic
metadata:
  name: test-topic
  namespace: kafka
  labels:
    strimzi.io/cluster: my-cluster
spec:
  partitions: 3
  replicas: 3
EOF
```

### Customizing Kafka Configuration

Edit `apps/kafka-cluster/values.yaml` to customize:
- Replica counts for Kafka and ZooKeeper
- Resource requests and limits
- Storage configuration
- Kafka broker settings
- Enable/disable Kafka Connect
- Monitoring configuration

### Kafka Topics

The project includes a dedicated ArgoCD application for managing Kafka topics (`apps/kafka-topics.yaml`):

- **Topic Management**: Automatically deploys KafkaTopic custom resources
- **Example Topics**: `foo-topic` and `bar-topic` with 3 partitions and replicas
- **Configuration**: Topics include retention, segment size, and cleanup policies
- **Namespace**: Topics are deployed to the `kafka` namespace

Topic definitions are stored in the `kafka-topics/` directory and managed as Kubernetes custom resources by the Strimzi operator.

### Kafka UI

The project includes Kafka UI for web-based cluster management (`apps/kafka-ui.yaml`):

- **Version**: 0.7.5 using the official Provectus Helm chart
- **Access**: Available on NodePort 30080 (http://localhost:30080)
- **Features**: Topic management, consumer groups, message browsing
- **Configuration**: Pre-configured to connect to the `my-cluster` Kafka cluster
- **Resources**: 256Mi-512Mi memory, 100m-200m CPU limits

### Confluent Schema Registry

The project includes Confluent Schema Registry for managing Avro/JSON schemas (`apps/confluent-schema-registry-app.yaml`):

- **Version**: Latest from Confluent Helm chart
- **Purpose**: Centralized schema management for Kafka producers/consumers
- **Integration**: Connected to the Kafka cluster for schema storage
- **Namespace**: Deployed to the `kafka` namespace

### Schema Publisher Job

A dedicated job for publishing protobuf schemas to the Schema Registry (`apps/schema-publisher-job-app.yaml`):

- **Purpose**: Automated schema publishing and validation
- **Components**: ConfigMap with Python script and Job definition  
- **Sync Wave**: Deploys after Kafka cluster (sync-wave: 3)
- **Location**: Resources in `apps/schema-publisher-job/` directory

## Sync Wave Management

The project uses ArgoCD sync waves to ensure proper deployment ordering:

- **Wave 1**: `strimzi-operator.yaml` - Deploys Strimzi operator first
- **Wave 2**: `kafka-cluster.yaml` - Deploys Kafka cluster after operator  
- **Wave 3**: `schema-publisher-job-app.yaml` - Deploys schema publisher after cluster
- **Wave 0 (default)**: All other applications deploy in parallel

Note: The `kafka` namespace is created automatically by applications that have `CreateNamespace=true` in their syncOptions.

## Advanced Features

### Custom Resource Definitions (CRDs)

This project leverages several Kubernetes CRDs for declarative management:

- **Kafka**: Defines Kafka cluster configuration including brokers, storage, and listeners
- **KafkaTopic**: Manages topic creation with partitions, replicas, and retention policies  
- **KafkaUser**: Creates Kafka users with authentication and authorization (extensible)
- **Application**: ArgoCD applications for GitOps workflow management

### Configuration Customization

#### Kafka Cluster Tuning
Edit `apps/kafka-cluster/values.yaml` to customize:
```yaml
kafka:
  replicas: 3                    # Number of Kafka brokers
  resources:
    requests:
      memory: "1Gi"              # Memory per broker
      cpu: "500m"                # CPU per broker
    limits:
      memory: "2Gi"
      cpu: "1000m"
  storage:
    size: "10Gi"                 # Persistent storage per broker
    class: "standard"            # Storage class
  config:
    log.retention.hours: 168     # 7 days retention
    log.segment.bytes: 1073741824 # 1GB segments
    num.network.threads: 8
    num.io.threads: 8
```

#### Schema Registry Configuration
The Schema Registry can be configured for different compatibility levels:
```yaml
schemaRegistry:
  config:
    compatibilityLevel: "BACKWARD"  # BACKWARD, FORWARD, FULL, NONE
    avroCompatibilityLevel: "BACKWARD"
```

#### Topic Management Examples
Create new topics by adding YAML files to `kafka-topics/`:
```yaml
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaTopic
metadata:
  name: user-events
  namespace: kafka
  labels:
    strimzi.io/cluster: my-cluster
spec:
  partitions: 12
  replicas: 3
  config:
    retention.ms: 604800000      # 7 days in milliseconds
    compression.type: "producer"
    min.insync.replicas: 2
```

### Monitoring and Observability

#### Built-in Monitoring
- **Kafka UI**: Web interface at http://localhost:30080
- **ArgoCD Dashboard**: GitOps management at http://localhost:30443
- **Kubectl Commands**: Direct cluster inspection

#### Health Checks
```bash
# Check Kafka cluster health
kubectl get kafka -n kafka
kubectl get kafkatopics -n kafka

# Monitor broker pods
kubectl get pods -n kafka -l app.kubernetes.io/name=kafka

# Check Schema Registry
kubectl logs -f deployment/schema-registry -n kafka

# View topic details
kubectl describe kafkatopic foo-topic -n kafka
```

### Extending the Project

#### Adding New Components
1. **Kafka Connect**: Add connectors for data integration
2. **Kafka Streams**: Deploy stream processing applications
3. **Monitoring Stack**: Prometheus, Grafana for metrics
4. **Security**: TLS, SASL authentication, and ACLs

#### Custom Jobs and Automation
The schema publisher job demonstrates how to:
- Run initialization tasks after cluster deployment
- Validate configurations before deployment
- Automate maintenance tasks with Kubernetes Jobs
- Integrate external tools with the Kafka ecosystem

### Production Considerations

#### Security Hardening
- Enable TLS encryption for client connections
- Configure SASL authentication (SCRAM-SHA-512, OAuth)
- Implement proper RBAC and network policies
- Use secrets for sensitive configuration

#### Performance Optimization
- Tune JVM settings for Kafka brokers
- Configure appropriate storage classes and IOPS
- Optimize network configuration for throughput
- Set proper resource requests and limits

#### High Availability
- Deploy across multiple availability zones
- Configure proper pod disruption budgets
- Implement backup and disaster recovery procedures
- Setup monitoring and alerting for critical metrics

## Useful Commands

```bash
# View all applications
kubectl get applications -n argocd

# Port forward to ArgoCD server (alternative access)
kubectl port-forward svc/argocd-server -n argocd 8080:80

# View simple-app logs
kubectl logs -f deployment/simple-app -n default

# Check simple-app service
kubectl get svc simple-app -n default

# Check Kafka cluster status
kubectl get kafka -n kafka

# Check Kafka pods and services
kubectl get pods,svc -n kafka

# View Strimzi operator logs
kubectl logs -f deployment/strimzi-cluster-operator -n kafka

# Access Kafka UI (web interface)
# URL: http://localhost:30080

# Check Kafka topics
kubectl get kafkatopics -n kafka

# View Kafka UI logs
kubectl logs -f deployment/kafka-ui -n kafka

# Sync changes to Git server
./scripts/sync-git.sh

# Stop Git servers and cleanup
./scripts/stop-git.sh

# Restart Git servers
./setup-git-server.sh

# Delete the cluster
kind delete cluster --name argocd-cluster
```

## Development Workflow

### Making Changes to Applications

1. **Edit application files** (Helm values, templates, etc.)
   ```bash
   # Example: Update replica count
   vim apps/simple-app/values.yaml
   ```

2. **Sync changes to Git server:**
   ```bash
   ./scripts/sync-git.sh
   ```

3. **ArgoCD automatically detects and deploys changes** within ~3 minutes

4. **Manual sync** (for immediate deployment):
   ```bash
   # Sync root app (will sync all child apps)
   kubectl patch app root-app -n argocd -p '{"operation":{"sync":{"revision":"HEAD"}}}' --type merge
   
   # Sync specific app
   kubectl patch app simple-app -n argocd -p '{"operation":{"sync":{"revision":"HEAD"}}}' --type merge
   ```

### Git Server Management

- **Stop Git servers:** `./scripts/stop-git.sh`
- **Start/Restart Git servers:** `./setup-git-server.sh`
- **Alternative Git setup:** `./scripts/init-git.sh`
- **Check Git server status:** `git ls-remote git://localhost:9418/argocd-demo.git`

### Branch Considerations

⚠️ **Important**: Ensure your Git server is pushing to the correct branch:
- This repository uses `main` branch
- The sync script pushes to `main` branch (fixed from original `master`)
- ArgoCD pulls from `HEAD` which should point to `main`

## How It Works

1. **Local Git Server**: 
   - Git daemon serves on port 9418 (`git://host.docker.internal:9418/argocd-demo.git`)
   - HTTP server on port 8090 for Git over HTTP
   - Bare repository at `/tmp/argocd-demo.git` serves content to ArgoCD

2. **App-of-Apps Pattern**: 
   - `root-app.yaml` monitors the `apps/` directory 
   - Automatically deploys any `*.yaml` files in `apps/` as ArgoCD Applications
   - Each application references Helm charts in subdirectories

3. **Automated Sync**: 
   - All applications configured with automated sync (`prune: true`, `selfHeal: true`)
   - Changes to Git repository are automatically deployed within ~3 minutes
   - Manual sync available via kubectl patch commands

4. **Helm Integration**: 
   - Applications use Helm charts for templating
   - `simple-app` demonstrates nginx deployment with custom HTML content
   - Values can be customized in `values.yaml` files

5. **Container Access**: 
   - ArgoCD running in Kind cluster accesses Git server via `host.docker.internal`
   - Local development uses `localhost` for Git operations

## Architecture Components

- **Kind Cluster**: Local Kubernetes cluster with ArgoCD
- **Git Daemon**: Serves repository via Git protocol
- **HTTP Server**: Alternative Git access via HTTP
- **ArgoCD**: GitOps controller monitoring Git repository
- **Helm Charts**: Application templates and configurations

## Troubleshooting

### Common Issues

1. **simple-app not syncing**:
   ```bash
   # Check if Git server is running
   git ls-remote git://localhost:9418/argocd-demo.git
   
   # Verify branch sync (should be main, not master)
   ./scripts/sync-git.sh
   ```

2. **Git server connection issues**:
   ```bash
   # Restart Git servers
   ./scripts/stop-git.sh
   ./setup-git-server.sh
   ```

3. **ArgoCD application errors**:
   ```bash
   # Check ArgoCD logs
   kubectl logs -f deployment/argocd-server -n argocd
   kubectl logs -f deployment/argocd-repo-server -n argocd
   ```

4. **Helm template validation**:
   ```bash
   helm template apps/simple-app/
   helm lint apps/simple-app/
   ```

5. **Complete reset**:
   ```bash
   ./scripts/stop-git.sh
   kind delete cluster --name argocd-cluster
   ./setup-cluster.sh
   ./setup-git-server.sh
   kubectl apply -f root-app.yaml
   ```