# Docker Host Hardening Guide

This document provides practical hardening recommendations for Docker hosts running on VPS environments.

---

## Goals

- Reduce attack surface
- Improve container isolation
- Protect host resources
- Improve operational security

---

## Docker Socket

### Recommended

Avoid exposing:

`/var/run/docker.sock`

to containers unless absolutely necessary.

### Risk

Access to the Docker socket can effectively provide root-level control over the host.

---

## Container Privileges

### Recommended

Run containers with the least privileges required.

Avoid:

- privileged containers
- unnecessary capabilities
- host networking

---

## Images

### Recommended

- Use trusted base images
- Keep images updated
- Remove unused images
- Scan images regularly

---

## Networking

### Recommended

- Expose only required ports
- Use reverse proxies when possible
- Separate services using Docker networks

---

## Logging

### Recommended

Enable log rotation.

Example:

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

---

## Resource Limits

### Recommended

Configure:

- CPU limits
- Memory limits

Example:

```yaml
services:
  app:
    mem_limit: 512m
    cpus: "1.0"
```

---

## Updates

### Recommended

- Keep Docker Engine updated
- Remove unused containers
- Remove unused networks
- Review running containers regularly

---

## Security Review Checklist

- [ ] Docker socket not exposed
- [ ] No privileged containers
- [ ] Resource limits configured
- [ ] Log rotation enabled
- [ ] Images updated
- [ ] Unused containers removed