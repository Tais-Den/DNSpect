# DNSpect 🕵️‍♂️
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
````

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

## 🔁 CI/CD: GitHub Actions Workflow

Below is a `.github/workflows/build-and-publish.yml` to automatically build and push images to registry on `main` branch or versioned tags:

```yaml
name: Build and Publish DNSpect Image

on:
  push:
    branches: [main]
    tags: ['v*']
  workflow_dispatch:

jobs:
  build_and_push:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
      id-token: write

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Login to registry (GHCR / DockerHub)
        uses: docker/login-action@v2
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Build and Push image
        uses: docker/build-push-action@v3
        with:
          context: .
          push: true
          tags: |
            ghcr.io/${{ github.repository_owner }}/dnspect:latest
            ghcr.io/${{ github.repository_owner }}/dnspect:${{ github.ref_name }}
          labels: |
            org.opencontainers.image.source=${{ github.repository }}
            org.opencontainers.image.version=${{ github.ref_name }}

```

* **Tagging and workflow triggers**: pushes on `main` and releases tagged `v1.0`, etc.
* **Uses official GitHub token** for secure GHCR login and seamless linking with the repo
* **Build-push-action** handles building, tagging, and pushing, with metadata from the repo

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
* Tags like `v1.0`, `v1.1` trigger versioned builds.
* `latest` always references the most recent build on `main`.

## 🤝 Contributing & Support
Please open issues or PRs for new tool support, bug fixes, or enhancements.
For help running DNSpect or integrating into CI pipelines, feel free to raise an issue.
