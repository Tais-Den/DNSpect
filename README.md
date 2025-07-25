# DNSpect 🕵️‍♂️
[![Nightly Build](https://github.com/ajoeofalltrades/DNSpect/actions/workflows/build-and-publish.yml/badge.svg)](https://github.com/ajoeofalltrades/DNSpect/actions/workflows/build-and-publish.yml)

**DNSpect** is a containerized DNS audit toolkit built for comprehensive zone inspection, SPF/DMARC/DNSSEC validation, performance analysis, and formal reporting.

## 🧰 Tooling Stack
Our Docker-based audit environment includes the following tools:

- **dig** (`bind9-utils`) — Manual DNS lookups, AXFR & record analysis  
- **dnsrecon** — Domain and subdomain enumeration, brute force and zone transfer  
- **amass** — Active + passive subdomain discovery  
- **Zonemaster CLI** — Comprehensive DNSSEC validation and nameserver health checks  
- **dmarc‑cat** — CLI tool (Go‑based) to parse individual DMARC XML report files  
- **spf‑tools** shell scripts — `despf.sh`, `normalize.sh`, `simplify.sh`, `mkblocks.sh` for SPF expansion and flattening  
- **dnsviz** & **dnsdiag** — Visualizations and latency-based DNS diagnostics  
- **dnsperf** & **resperf** — DNS load testing and perf measurement  

All Python-based tools run inside a virtual environment (`venv`) to avoid global package conflicts.

## 💡 Why DNSpect?
* Combines popular DNS testers into one reproducible container
* Automates container publishing via GitHub Actions
* Safe Python isolation with `venv`, native shell tooling, and compiled Go binaries

## 🚀 Quickstart

```bash
docker run --rm -it dnspect:latest bash
```

Inside the container, typical usage might be:

```bash
dig example.com AXFR
dnsrecon -d example.com
amass enum -d example.com
dmarc-cat path/to/report.xml
despf.sh example.com | normalize.sh | simplify.sh | mkblocks.sh
zonemaster-cli example.com
dnsviz example.com
```

## 🐧 Building Locally

```bash
docker build -t dnspect:dev .
``` 

## 🧩 Example Directory Structure

```
/
├── Dockerfile
├── README.md
├── .github/workflows/build-and-publish.yml
├── scripts/
│   └── audit_example.sh
└── config/
    ├── amass_config.yml
    └── dns-spf-toolsrc
```

## ⚙️ Versioning & Tagging
* `latest` always references the most recent nightly build on `trunk`.

## 🤝 Contributing & Support
Please open issues or PRs for new tool support, bug fixes, or enhancements.
For help running DNSpect or integrating into CI pipelines, feel free to raise an issue.
