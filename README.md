# ArgoCD App-of-Apps Demo with Strimzi Kafka

This project demonstrates the ArgoCD "app-of-apps" pattern with a local Git server setup for real-time GitOps workflows using Kind, Helm charts, and the Strimzi Kafka operator.

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
│   ├── simple-app.yaml        # ArgoCD Application for simple nginx app
│   ├── simple-app/            # Helm chart for simple nginx app
│   │   ├── Chart.yaml
│   │   ├── values.yaml
│   │   └── templates/
│   ├── strimzi-operator.yaml  # ArgoCD Application for Strimzi operator
│   ├── kafka-cluster.yaml     # ArgoCD Application for Kafka cluster
│   └── kafka-cluster/         # Helm chart for Kafka cluster
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── kafka.yaml
│           ├── kafka-connect.yaml
│           └── pdb.yaml
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