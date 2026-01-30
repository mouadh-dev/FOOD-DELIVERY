# 📊 Task 11: Monitoring & Alerting - Implementation Complete

## ✅ Status: COMPLETED

## 🎯 Overview

A comprehensive monitoring and alerting stack has been implemented using:
- **Prometheus**: Metrics collection and storage
- **Grafana**: Visualization and dashboards
- **Alertmanager**: Alert routing and management
- **Node Exporter**: System-level metrics
- **cAdvisor**: Container metrics

---

## 🛠️ Components Deployed

### 1. **Prometheus** (Port 9090)
- Metrics collection from all services
- 15-second scrape interval
- Alert rule evaluation
- Time-series database

### 2. **Grafana** (Port 3002)
- Beautiful dashboards and visualizations
- Pre-configured Prometheus datasource
- Default credentials: `admin` / `admin`
- Automatic dashboard provisioning

### 3. **Alertmanager** (Port 9093)
- Alert routing and grouping
- Email and webhook notifications
- Configured for critical and warning alerts
- Inhibition rules to reduce noise

### 4. **Node Exporter** (Port 9100)
- CPU, memory, disk metrics
- Network statistics
- File system information

### 5. **cAdvisor** (Port 8081)
- Container CPU/memory usage
- Network I/O statistics
- Filesystem metrics
- Container lifecycle events

---

## 📊 Metrics Being Monitored

### System Metrics
- ✅ CPU usage (per core and total)
- ✅ Memory usage and availability
- ✅ Disk space and I/O
- ✅ Network traffic

### Container Metrics
- ✅ CPU usage per container
- ✅ Memory usage per container
- ✅ Container restart count
- ✅ Container health status

### Application Metrics (To be added)
- 🔄 HTTP request rate
- 🔄 Response times
- 🔄 Error rates
- 🔄 Database connections

---

## 🔔 Alert Rules Configured

### Critical Alerts
1. **ServiceDown**: Service unavailable for >2 minutes
2. **HighMemoryUsage**: Memory >90% for 5 minutes
3. **MongoDBDown**: Database unavailable for >2 minutes
4. **LowDiskSpace**: Disk space <10%

### Warning Alerts
1. **HighCPUUsage**: CPU >80% for 5 minutes
2. **ContainerRestarted**: Container has restarted
3. **HighErrorRate**: Error rate >5%
4. **SlowResponseTime**: 95th percentile >1 second
5. **DiskWillFillSoon**: Disk predicted to fill in 4 hours

---

## 🚀 Quick Start

### Start Monitoring Stack
```bash
./start-monitoring.sh
```

### Stop Monitoring Stack
```bash
./stop-monitoring.sh
```

### View Logs
```bash
docker-compose -f docker-compose.monitoring.yml logs -f
```

---

## 🌐 Access URLs

| Service | URL | Credentials |
|---------|-----|-------------|
| **Prometheus** | http://localhost:9090 | None |
| **Grafana** | http://localhost:3002 | admin/admin |
| **Alertmanager** | http://localhost:9093 | None |
| **Node Exporter** | http://localhost:9100/metrics | None |
| **cAdvisor** | http://localhost:8081 | None |

---

## 📈 Using Grafana

### First-Time Setup

1. **Login**: http://localhost:3002
   - Username: `admin`
   - Password: `admin`
   - Change password when prompted

2. **Verify Datasource**:
   - Go to Configuration → Data Sources
   - Prometheus should be configured automatically
   - Test the connection

3. **Import Dashboards**:
   - Go to Dashboards → Import
   - Use these popular dashboard IDs:
     - **Node Exporter Full**: ID `1860`
     - **Docker Container**: ID `193`
     - **Prometheus Stats**: ID `3662`

### Creating Custom Dashboards

```promql
# Example Queries

# CPU Usage
rate(process_cpu_seconds_total[5m])

# Memory Usage
(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100

# Disk Usage
100 - ((node_filesystem_avail_bytes * 100) / node_filesystem_size_bytes)

# Container Memory
container_memory_usage_bytes{name=~"food-delivery.*"}

# HTTP Request Rate (when metrics added)
rate(http_requests_total[5m])
```

---

## ⚙️ Configuration Files

### 📁 File Structure
```
monitoring/
├── prometheus.yml          # Prometheus configuration
├── alerts.yml             # Alert rules
├── alertmanager.yml       # Alertmanager configuration
└── grafana/
    ├── provisioning/
    │   ├── datasources/   # Auto-configured datasources
    │   └── dashboards/    # Dashboard provisioning
    └── dashboards/        # Dashboard JSON files
```

### Key Configuration Points

#### Prometheus (`monitoring/prometheus.yml`)
- **Scrape Interval**: 15 seconds
- **Evaluation Interval**: 15 seconds
- **Targets**: All application services

#### Alerts (`monitoring/alerts.yml`)
- **Application Alerts**: CPU, memory, service availability
- **Container Alerts**: Container restarts, resource limits
- **Database Alerts**: MongoDB connection issues
- **Disk Alerts**: Disk space warnings

#### Alertmanager (`monitoring/alertmanager.yml`)
- **Receivers**: Email, Slack, webhooks
- **Routing**: Critical vs warning alerts
- **Grouping**: By alertname, service
- **Inhibition**: Suppress warning if critical firing

---

## 🔧 Customization

### Add Email Alerts

Edit `monitoring/alertmanager.yml`:
```yaml
email_configs:
  - to: 'your-email@example.com'
    from: 'alertmanager@fooddelivery.com'
    smarthost: 'smtp.gmail.com:587'
    auth_username: 'your-email@gmail.com'
    auth_password: 'your-app-password'
```

### Add Slack Alerts

1. Create a Slack webhook
2. Update `monitoring/alertmanager.yml`:
```yaml
slack_configs:
  - api_url: 'YOUR_SLACK_WEBHOOK_URL'
    channel: '#alerts'
```

### Adjust Alert Thresholds

Edit `monitoring/alerts.yml`:
```yaml
# Example: Change CPU threshold from 80% to 90%
- alert: HighCPUUsage
  expr: rate(process_cpu_seconds_total[5m]) > 0.9  # Changed from 0.8
  for: 5m
```

---

## 📊 Next Steps: Add Application Metrics

### Install Prometheus Client in Backend

```bash
cd backend
npm install prom-client
```

### Add Metrics Endpoint ([backend/server.js](../backend/server.js))

```javascript
const promClient = require('prom-client');

// Create a Registry
const register = new promClient.Registry();

// Add default metrics
promClient.collectDefaultMetrics({ register });

// Custom metrics
const httpRequestDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  registers: [register]
});

const httpRequestTotal = new promClient.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code'],
  registers: [register]
});

// Middleware to track metrics
app.use((req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    httpRequestDuration.labels(req.method, req.route?.path || req.path, res.statusCode).observe(duration);
    httpRequestTotal.labels(req.method, req.route?.path || req.path, res.statusCode).inc();
  });
  
  next();
});

// Metrics endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});
```

---

## 🔍 Troubleshooting

### Prometheus Not Scraping Targets

**Check target status**: http://localhost:9090/targets

**Common issues**:
- Network connectivity: All services must be on `food-delivery-network`
- Service not exposing metrics: Check if `/metrics` endpoint exists
- Firewall blocking: Check Docker network settings

### Grafana Can't Connect to Prometheus

1. Check Prometheus is running: `docker ps | grep prometheus`
2. Test connection: `docker exec grafana curl http://prometheus:9090/api/v1/status/config`
3. Verify datasource configuration in Grafana UI

### Alerts Not Firing

1. Check alert rules: http://localhost:9090/alerts
2. Verify Alertmanager: http://localhost:9093
3. Check logs: `docker logs alertmanager`
4. Test alert manually:
   ```bash
   curl -H "Content-Type: application/json" -d '[{"labels":{"alertname":"test"}}]' \
     http://localhost:9093/api/v1/alerts
   ```

### Container Metrics Not Available

**cAdvisor issues**:
- Check cAdvisor logs: `docker logs cadvisor`
- Verify privileged mode is enabled
- Check Docker socket mounting

---

## 📚 Resources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Alertmanager Documentation](https://prometheus.io/docs/alerting/latest/alertmanager/)
- [PromQL Tutorial](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- [Grafana Dashboard Gallery](https://grafana.com/grafana/dashboards/)

---

## ✅ Task 11 Summary

### Completed:
- ✅ Prometheus metrics collection setup
- ✅ Grafana visualization platform
- ✅ Alertmanager for alert routing
- ✅ Node Exporter for system metrics
- ✅ cAdvisor for container metrics
- ✅ Alert rules for critical issues
- ✅ Automated startup scripts
- ✅ Comprehensive documentation

### To Do:
- 🔄 Add application-specific metrics to backend
- 🔄 Create custom Grafana dashboards
- 🔄 Configure email/Slack notifications
- 🔄 Add MongoDB metrics exporter
- 🔄 Set up log aggregation (optional)

---

**🎉 Monitoring stack is operational and ready to use!**

Access Grafana now: http://localhost:3002 (admin/admin)
