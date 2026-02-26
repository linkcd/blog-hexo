---
title: Tibber Streaming Anomaly Detector
date: 2026-02-19 14:14:47
tags:
- AWS
- IoT
- Data Analytics
- Tibber
- Machine Learning
- Streaming
- Apache Flink
---

Ever wondered what's really happening with your home's energy consumption at night? Or why your electricity bill suddenly spiked last month?

<!-- more -->

Your smart meter knows everything—every watt, every spike, every pattern. But that data is locked away in vendor apps, making it nearly impossible to analyze, detect anomalies, or build custom alerts.

I built a real-time streaming platform to solve this. It continuously ingests energy data from [Tibber Pulse](https://tibber.com/no/store/produkt/pulse), uses machine learning to detect unusual patterns, and stores everything for long-term analysis.

**Anomaly Detection Dashboard - EV Charging Session**
{% asset_img "dashboard_anomaly.png" "Real-time anomaly detection in action" %}

The dashboard above shows an EV charging session (5:00 AM to 6:00 AM) detected in real-time:
- **Green line**: Real-time power consumption
- **Red line**: Anomaly score calculated by Random Cut Forest algorithm
- When charging starts, power consumption spikes and anomaly score rises above the threshold
- The system automatically flags this unusual pattern

## Architecture Overview

**System Architecture**
{% asset_img "architecture.jpg" "Architecture Diagram" %}


| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Tibber-Connector** | ECS Fargate Task (Python) | Ingest data from Tibber WebSocket API |
| **MSK Serverless** | Kafka | Message streaming backbone |
| **Managed Flink Anomaly Detection** | Managed Flink (Java) | Real-time ML anomaly detection with Random Cut Forest (RCF) |
| **Anomaly-Storage** | ECS Fargate Task + Timestream DB | Time-series storage for anomaly scores |
| **Firehose** | Kinesis Firehose | Transform JSON → Parquet, save to s3 Datalake |
| **S3 Datalake** | S3 + Glue Data Catalog + Athena | Long-term storage, SQL analytics |

## How It Works

Here's the end-to-end data flow:

1. **Data Ingestion**: Tibber-Connector establishes a WebSocket connection to Tibber API and continuously receives real-time energy data from your Tibber Pulse device
2. **Message Streaming**: Raw data is published to MSK Serverless (Kafka) for reliable message streaming
3. **Dual Processing Path**:
   - **Anomaly Detection**: Managed Flink consumes messages from Kafka, applies Random Cut Forest algorithm to detect anomalies, and publishes anomaly scores back to Kafka
   - **Raw Data Storage**: Kinesis Firehose transforms JSON messages to Parquet format and stores them in S3 Datalake for long-term analytics
4. **Anomaly Storage**: Anomaly-Storage service consumes anomaly scores from Kafka and writes them to Timestream DB for fast time-series queries
5. **Visualization**: Grafana queries both Timestream DB (for anomaly scores) and Athena (for historical analysis) to create real-time dashboards

### Normal vs Anomaly Detection

**Normal Household Power Consumption**
{% asset_img "dashboard_normal.png" "Normal household power consumption" %}

During normal operation, anomaly scores remain low.

**Anomaly Detected - EV Charging Session**
{% asset_img "dashboard_anomaly.png" "EV charging session with elevated anomaly scores" %}

When unusual patterns occur (like EV charging sessions), the system automatically detects and flags them with elevated anomaly scores.

### Multi-Metric Analysis

**Comprehensive Dashboard with Multiple Metrics**
{% asset_img "dashboard_all.png" "Comprehensive dashboard with voltage and current metrics" %}

Beyond power consumption, the platform tracks voltage and current to provide deeper context for detected anomalies.

## Key Features

### Real-Time Streaming
- WebSocket connection to Tibber API
- Automatic reconnection with exponential backoff
- Data timeout watchdog for silent failures
- UTC timestamp normalization

### Anomaly Detection (Managed Flink + Random Cut Forest)
- **Random Cut Forest** algorithm for unsupervised anomaly detection
- Tumbling windows for aggregation
- Detects: EV charging, appliance failures, unusual patterns
- Tunable parameters for sensitivity adjustment

### Data Storage
- **S3 Datalake**: Parquet files, partitioned by time, queryable via Athena
- **Timestream DB**: Time-series database for fast anomaly queries
- Lifecycle policies for cost optimization

## Source Code

All source code is available on GitHub: [tibber-streaming-anomaly-detector](https://github.com/linkcd/tibber-streaming-anomaly-detector)

The repository includes:
- Complete Infrastructure-as-Code (AWS CDK)
- Python and Java source code
- Local development setup with Docker Compose
- Comprehensive documentation and deployment guides

## References

- **Tibber API**: [developer.tibber.com](https://developer.tibber.com/)
- **Random Cut Forest**: [AWS RCF Paper](https://proceedings.mlr.press/v48/guha16.pdf)
- **Apache Flink**: [flink.apache.org](https://flink.apache.org/)
