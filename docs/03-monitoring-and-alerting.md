# Task 3: Strategi Monitoring & Alerting

## 1. Arsitektur Observabilitas

Sistem monitoring memakai OpenTelemetry (OTel) Collector Gateway sebagai agregator log, metrik, dan trace sebelum diekspor ke Grafana Cloud (Loki, Mimir, Tempo, dan continuous profiling Pyroscope). Untuk analisis beban query database, monitoring dikombinasikan dengan AWS RDS Performance Insights.

```mermaid
flowchart LR
    subgraph Sources ["Telemetry Producers"]
        direction TB
        BE["Laravel API<br/>(OTel Auto-Instrumentation)"]
        FE["Vue.js SPA<br/>(OTel Web SDK)"]
        OS["Linux EC2 OS<br/>(OTel Hostmetrics Receiver)"]
        RDS_PI["RDS MySQL 8.0<br/>(AWS Performance Insights)"]
        DB["RDS MySQL 8.0<br/>(OTel MySQL Receiver)"]
        Cache["ElastiCache Redis<br/>(OTel Redis Receiver)"]
    end

    subgraph Collector ["Central OTel Collector Gateway"]
        direction TB
        Pipe["Ingest (OTLP / Receivers)<br/>-> Processors (Batch, Filter, Scrub PII)<br/>-> Connectors (Spanmetrics)<br/>-> Exporter (OTLP gRPC)"]
    end

    subgraph Storage ["Observability Backend (Grafana Cloud & AWS)"]
        direction TB
        Loki[("Loki (Logs)")]
        Mimir[("Mimir / Prometheus (Metrics)")]
        Tempo[("Tempo (Traces)")]
        Pyroscope[("Pyroscope (Continuous Profiling)")]
        AWS_PI["AWS CloudWatch / RDS Console<br/>(Performance Insights Dashboard)"]
        Grafana["Grafana Unified Dashboard & Alerting"]
    end

    subgraph Channels ["Notification Channels"]
        Teams Channel["Teams Channel (#alerts-critical, #alerts-warning)"]
        PD["PagerDuty / SMS Call"]
        Email["Email Distribution List"]
    end

    BE & FE & OS -->|OTLP| Collector
    DB & Cache -.->|Scrape| Collector
    RDS_PI --> AWS_PI

    Collector -->|Logs| Loki
    Collector -->|Metrics| Mimir
    Collector -->|Traces| Tempo
    Collector -->|Profiles| Pyroscope

    Loki & Mimir & Tempo & Pyroscope --> Grafana
    AWS_PI -.->|CloudWatch Metric Stream| Mimir
    Grafana -->|P1 Alert| PD & Teams Channel
    Grafana -->|P2 Alert| Teams Channel & Email
```

---

## 2. Monitoring Aplikasi

1. **Structured Logging (Laravel)**:
   - Output log ditulis ke `stdout` dalam format JSON (`Monolog\Formatter\JsonFormatter`).
   - Log handler menyematkan `trace_id` dan `span_id` otomatis agar log error di Loki bisa langsung di-trace ke span request terkait.

2. **Tracing & Error Tracking (Laravel OTel Auto-Instrumentation)**:
   - Menggunakan extension `ext-opentelemetry` dan package `open-telemetry/opentelemetry-auto-laravel`.
   - Menangkap siklus HTTP request, query Eloquent, panggilan HTTP eksternal, dan antrean queue Redis tanpa modifikasi kode.
   - HTTP response 5xx otomatis ditandai status `Error` beserta stack trace exception.

3. **Continuous Profiling (Pyroscope)**:
   - Integrasi Pyroscope agent pada PHP-FPM untuk merekam CPU flamegraph dan memory allocation di level fungsi/method.
   - Berguna untuk mendeteksi bottleneck kode aplikasi saat CPU spike tanpa overhead tracing penuh.

4. **Frontend Real User Monitoring (Vue.js)**:
   - Menggunakan `@opentelemetry/auto-instrumentations-web`.
   - Mengukur Core Web Vitals (LCP, FID, CLS) dan unhandled Javascript error di browser klien.
   - Mengirim header `traceparent` pada request `/api/*` untuk distributed tracing end-to-end dari frontend ke backend.

---

## 3. Monitoring Infrastruktur

1. **Host EC2 (`hostmetricsreceiver`)**:
   - CPU: `system.cpu.utilization`, load average 1m.
   - Memori: `system.memory.utilization`, usage bytes.
   - Disk: Utilisasi partisi `/` dan `/var/lib/docker`.
   - Network: In/out throughput dan packet drops.

2. **Database RDS MySQL**:
   - **RDS Performance Insights**: Analisis Average Active Sessions (AAS), wait events, dan profiling SQL query terberat langsung di engine database.
   - **OTel MySQL Receiver**: Scraping metrik berkala via `performance_schema` (koneksi aktif vs max connection, slow queries counter, InnoDB buffer pool hit ratio).

3. **Cache ElastiCache Redis (`redisreceiver`)**:
   - Memori terpakai (`used_memory`), hit/miss ratio, eviction count, dan jumlah client connection aktif.

---

## 4. Alerting Matrix & Mitigasi

| Alert | Rule / Ambang Batas | Severity | Kanal Notifikasi | Aksi Mitigasi |
|---|---|---|---|---|
| **App Down (Blackbox)** | Healthcheck `/api/health` gagal 3x berturut-turut | P1 | PagerDuty, Teams `#alerts-critical` | ASG Instance Refresh / cek status ALB target group |
| **Database Connection Failure** | Error `SQLSTATE[2002]` > 1% dalam 2 menit | P1 | PagerDuty, Teams `#alerts-critical` | Cek status RDS Multi-AZ, restart connection pool |
| **Latensi P99 Spike** | P99 latency > 2500ms selama 5 menit | P1 | PagerDuty, Teams `#alerts-critical` | Investigasi slow queries, aktifkan kill switch via AppConfig |
| **High CPU EC2** | CPU utilization > 75% selama 5 menit | P2 | Teams `#alerts-warning`, Email | Auto-scaling scale-out instance baru |
| **Slow Query Spike** | Slow queries bertambah > 20/menit | P2 | Teams `#alerts-warning` | Cek query bottleneck di RDS Performance Insights |
| **Disk Capacity Low** | Disk usage > 80% | P2 | Teams `#alerts-warning` | Cleanup log lama dan Docker cache via SSM script |

### Circuit Breaker / Kill Switch (AWS AppConfig)
Untuk mencegah database overload saat ada lonjakan trafik di endpoint berat (misalnya ekspor laporan):
- Alert latency P1 memicu Lambda untuk update flag di AWS AppConfig (`export_feature_enabled = false`).
- Backend Laravel membaca flag tersebut (di-cache di Redis) dan langsung merespons HTTP 503 tanpa menjalankan query berat ke database.
