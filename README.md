# Exposing JVM Metrics in Spring Boot and Monitoring with Kube Prometheus Stack

## Step 1: Exposing JVM Metrics in Spring Boot

### 1. Add Micrometer and Prometheus Dependencies
Add the following dependencies in your `pom.xml` (for Maven) or `build.gradle` (for Gradle):

```xml
<!-- For Maven -->
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-core</artifactId>
</dependency>
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-registry-prometheus</artifactId>
</dependency>
```

```groovy
// For Gradle
implementation 'io.micrometer:micrometer-core'
implementation 'io.micrometer:micrometer-registry-prometheus'
```

### 2. Configure Micrometer
Ensure Prometheus is set as the metrics registry in your Spring Boot `application.properties` or `application.yml`:

```properties
management.endpoints.web.exposure.include=prometheus
management.endpoint.prometheus.enabled=true
```

### 3. Start Your Spring Boot Application
When you start your Spring Boot application, it will expose metrics at the `/actuator/prometheus` endpoint.

## Step 2: Deploy Kube Prometheus Stack

### 1. Install Prometheus Operator
Use Helm to install the Kube Prometheus Stack, which includes Prometheus, Alertmanager, and Grafana:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack --create-namespace
```

### 2. Create a ServiceMonitor
Create a `ServiceMonitor` resource to tell Prometheus to scrape the metrics from your Spring Boot application. Create a YAML file `servicemonitor.yaml`:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: demo-prometheus-service
  labels:
    release: prometheus #This label allows Prometheus to find service monitors in the cluster and register them.
spec:
  selector:
    matchLabels:
      app: demo-prometheus
  endpoints:
  - port: web
    path: /actuator/prometheus
    interval: 30s
```

### 3. Deploy the `ServiceMonitor`
Apply the `ServiceMonitor`:

```bash
kubectl apply -f servicemonitor.yaml
```

### 4. Expose Your Spring Boot Application
Ensure your Spring Boot application is deployed and exposed via a Service in Kubernetes, e.g.,:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo-prometheus-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: demo-prometheus
  template:
    metadata:
      labels:
        app: demo-prometheus
    spec:
      containers:
        - name: demo-prometheus
          image: farhanluckali/demo-prometheus:latest
          ports:
            - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: demo-prometheus-service
  labels:
    app: demo-prometheus
spec:
  selector:
    app: demo-prometheus
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
      name: web
  type: NodePort

```

## Step 3: Monitoring Your Application

### 1. Access Prometheus
Access Prometheus to verify that it is scraping metrics from your Spring Boot application. You can expose  Prometheus service via NodePort :


Open `http://localhost:Nodeport` in your browser and check under the "Targets" tab.

### 2. Access Grafana
Grafana is included in the Kube Prometheus Stack. You can expose Grafana service via NodePort  

Open `http://localhost:Nodeport` in your browser. Default login credentials are usually `admin`/`prom-operator`. Create a new dashboard to visualize your JVM metrics.

## Conclusion
This tutorial covers the basics of exposing JVM metrics in a Spring Boot application, deploying a Kube Prometheus Stack, and monitoring your application metrics using Prometheus and Grafana. You can extend this by creating more advanced Grafana dashboards or setting up alerting rules in Prometheus.
