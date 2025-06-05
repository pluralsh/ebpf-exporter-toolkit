# eBPF Collector Toolkit
A comprehensive collection of eBPF programs with ready-to-use configurations packaged for the ebpf_exporter. This repository provides pre-configured monitoring solutions for Linux kernel and application observability, focusing on network monitoring.

The toolkit includes:
- Modular eBPF programs targeting specific subsystems (TCP/IP, UDP, ICMP)
- Configuration files compatible with Cloudflare's ebpf_exporter
- Docker container build scripts for easy deployment
- Documentation on metrics exposed and use cases
- Kubernetes deployment examples via Helm
- Designed to work seamlessly with Prometheus and OpenTelemetry observability stacks for monitoring Linux-based systems without code instrumentation.

Parts of the code are taken from the [ebpf_exporter](https://github.com/cloudflare/ebpf_exporter) project, which is licensed under Apache License 2.0. The code in this repository is licensed under the same license.