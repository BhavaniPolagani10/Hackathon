# GitHub Actions Workflows - Quick Reference Guide
## Heavy Machinery Dealer Management System

---

## Quick Links

- [Complete Design Document](WORKFLOW_AND_AGENTS_DESIGN.md)
- [Visual Diagrams](WORKFLOW_VISUAL_DIAGRAMS.md)

---

## 📋 Workflow Summary Table

| # | Workflow Name | Purpose | Trigger | Duration | Priority |
|---|--------------|---------|---------|----------|----------|
| 1 | Frontend CI/CD | Build & deploy frontend | Push, PR | ~15-20 min | Critical |
| 2 | Backend CI/CD | Build & deploy backend services | Push, PR | ~20-30 min | Critical |
| 3 | Code Quality | Linting, formatting, complexity | PR | ~5-10 min | High |
| 4 | Security Scan | Vulnerability & compliance checks | Push, PR, Daily | ~10-15 min | Critical |
| 5 | Database Migration | Schema changes | Migration files | ~5-10 min | High |
| 6 | E2E Testing | End-to-end test suite | Post-deploy | ~15-20 min | High |
| 7 | Performance Testing | Load, stress, frontend perf | Push to main, Nightly | ~20-30 min | Medium |
| 8 | Dependency Management | Update dependencies | Weekly | ~10-15 min | Medium |
| 9 | Release Management | Create & deploy releases | Tag | ~30-45 min | High |
| 10 | Documentation | Generate & deploy docs | Push to docs/ | ~5-10 min | Low |
| 11 | Infrastructure | IaC validation & deployment | Infrastructure changes | ~10-20 min | High |
| 12 | Monitoring | Deploy monitoring configs | Push to monitoring/ | ~5 min | Medium |

---

## 🎯 Agent Summary Table

| # | Agent Name | Responsibilities | Technologies | Auto-Merge |
|---|-----------|------------------|--------------|------------|
| 1 | frontend-ci-agent | Frontend build, test, deploy | Node.js, React, TypeScript | No |
| 2 | backend-ci-agent | Backend services build & test | Multi-language, Docker, K8s | No |
| 3 | security-scan-agent | Security scanning & compliance | CodeQL, Trivy, Snyk | No |
| 4 | database-migration-agent | DB schema management | Flyway, PostgreSQL, MongoDB | No |
| 5 | performance-testing-agent | Performance & load testing | k6, Lighthouse, JMeter | No |
| 6 | e2e-testing-agent | End-to-end testing | Playwright, Cypress | No |
| 7 | release-management-agent | Release automation | Semantic versioning, Changelog | No |
| 8 | documentation-agent | Doc generation & deployment | TypeDoc, MkDocs, GitHub Pages | No |
| 9 | dependency-management-agent | Dependency updates | Dependabot, npm, pip | Patch only |
| 10 | infrastructure-agent | IaC deployment | Terraform, Kubernetes, Helm | No |

---

## 🚀 Common Workflows

### Starting a New Feature

```bash
# 1. Create feature branch
git checkout -b feature/your-feature-name

# 2. Make changes and commit
git add .
git commit -m "feat: your feature description"

# 3. Push and create PR
git push origin feature/your-feature-name

# Triggers: Code Quality, Testing, Security Scan workflows
```

### Deploying to Staging

```bash
# 1. Merge PR to main
# Automatically triggers: Frontend CI/CD, Backend CI/CD

# 2. Wait for staging deployment
# Automatically runs: E2E Tests, Performance Tests

# 3. Check deployment status
# View in GitHub Actions tab
```

### Deploying to Production

```bash
# 1. Create release tag
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# Triggers: Release Management workflow
# Requires: Manual approval for production deployment

# 2. Approve production deployment
# Via GitHub Actions UI or API

# 3. Monitor deployment
# Check monitoring dashboards
```

---

## 🔧 Workflow Triggers Reference

### Automatic Triggers

| Event | Workflows Triggered |
|-------|-------------------|
| **Push to main** | Frontend CI/CD, Backend CI/CD, Documentation, Security Scan (if configured) |
| **Pull Request** | Code Quality, Frontend CI/CD, Backend CI/CD, Security Scan |
| **Push to feature branch** | Code Quality (optional) |
| **Tag creation (v*.*.*)** | Release Management |
| **Schedule (Daily 2 AM)** | Security Scan, Monitoring validation |
| **Schedule (Weekly)** | Dependency Management |
| **Schedule (Nightly)** | E2E Testing, Performance Testing |

### Manual Triggers

All workflows support manual dispatch via:
- GitHub Actions UI → "Run workflow" button
- GitHub CLI: `gh workflow run workflow-name.yml`
- GitHub API

---

## 🎨 Agent Configuration Examples

### Frontend CI Agent

```yaml
# Minimal configuration
agent: frontend-ci-agent
node_version: 18
package_manager: npm
build_command: npm run build
test_command: npm test
```

### Backend CI Agent

```yaml
# Service matrix configuration
agent: backend-ci-agent
services:
  - name: email-service
    language: node
    test_coverage: 85
  - name: quote-service
    language: python
    test_coverage: 90
```

### Security Scan Agent

```yaml
# Security configuration
agent: security-scan-agent
scans: [dependency, sast, container]
fail_on: CRITICAL
report_on: [HIGH, MEDIUM]
```

---

## 📊 Metrics & Thresholds

### Quality Gates

| Metric | Threshold | Blocking |
|--------|-----------|----------|
| **Test Coverage (Frontend)** | ≥ 80% | Yes |
| **Test Coverage (Backend)** | ≥ 85% | Yes |
| **Bundle Size (Frontend)** | < 2 MB | Yes |
| **Build Time (Frontend)** | < 5 min | No |
| **Build Time (Backend)** | < 10 min | No |
| **Security Vulnerabilities** | 0 Critical | Yes |
| **Lighthouse Score** | ≥ 90 | No |
| **API Response Time** | < 500ms | No |

### SLA Targets

| Workflow | Target Duration | SLA |
|----------|----------------|-----|
| Code Quality | 5 min | 95% |
| Testing | 10 min | 90% |
| Security Scan | 15 min | 95% |
| Deploy Staging | 10 min | 95% |
| E2E Tests | 20 min | 90% |
| Deploy Production | 15 min | 99% |

---

## 🔐 Security Requirements

### Required Secrets

| Secret Name | Purpose | Used By |
|-------------|---------|---------|
| `NPM_TOKEN` | npm registry authentication | Frontend CI |
| `DOCKER_HUB_TOKEN` | Docker Hub access | Backend CI |
| `AWS_ACCESS_KEY_ID` | AWS deployment | Frontend/Backend CD |
| `AWS_SECRET_ACCESS_KEY` | AWS deployment | Frontend/Backend CD |
| `K8S_CLUSTER_TOKEN` | Kubernetes access | Backend CD |
| `SLACK_WEBHOOK_URL` | Notifications | All workflows |
| `SNYK_TOKEN` | Security scanning | Security Scan |

### Branch Protection Rules

**Main Branch:**
- ✅ Require pull request reviews (2 reviewers)
- ✅ Require status checks to pass
- ✅ Require branches to be up to date
- ✅ Require conversation resolution
- ✅ Include administrators
- ✅ Restrict force pushes

**Required Status Checks:**
- Code Quality
- Unit Tests
- Integration Tests
- Security Scan
- Build Success

---

## 🐛 Troubleshooting Guide

### Workflow Fails on Timeout

**Problem:** Workflow exceeds time limit

**Solutions:**
1. Increase timeout in workflow file: `timeout-minutes: 30`
2. Optimize slow tests
3. Use caching more effectively
4. Split large jobs into parallel jobs

### Cache Not Working

**Problem:** Dependencies reinstalled every time

**Solutions:**
1. Check cache key matches: `${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}`
2. Verify cache action version is latest
3. Check cache size limits (10GB max)
4. Consider using multiple cache keys

### Secrets Not Available

**Problem:** Workflow can't access secrets

**Solutions:**
1. Add secret in repository/organization settings
2. Check secret name matches exactly (case-sensitive)
3. Verify workflow has permission to access secrets
4. For organization secrets, check repository access

### Deployment Fails

**Problem:** Deployment step fails

**Solutions:**
1. Check credentials are valid
2. Verify target environment is accessible
3. Check for resource conflicts
4. Review deployment logs for specific errors
5. Validate deployment configuration

### Tests Flaky

**Problem:** Tests pass/fail inconsistently

**Solutions:**
1. Add retry logic: `with: max-attempts: 3`
2. Increase timeouts for async operations
3. Fix race conditions in tests
4. Use proper test isolation
5. Consider parallelization issues

---

## 📞 Support & Escalation

### Workflow Issues

| Issue Type | Contact | Response Time |
|------------|---------|---------------|
| Critical failure blocking production | DevOps on-call | Immediate |
| Workflow not running | DevOps team Slack | 1 hour |
| Performance issues | DevOps team | 4 hours |
| Feature requests | GitHub issue | 1-2 days |

### Contact Information

- **DevOps Team Slack:** #devops-support
- **On-Call PagerDuty:** devops-oncall
- **Email:** devops@example.com
- **Documentation:** See [WORKFLOW_AND_AGENTS_DESIGN.md](WORKFLOW_AND_AGENTS_DESIGN.md)

---

## 🎓 Best Practices Checklist

### For Developers

- [ ] Run linters locally before pushing
- [ ] Write tests for new features
- [ ] Keep commits small and focused
- [ ] Use conventional commit messages
- [ ] Review workflow results before merging
- [ ] Update documentation with code changes

### For Reviewers

- [ ] Check workflow status before approving
- [ ] Verify test coverage hasn't decreased
- [ ] Review security scan results
- [ ] Validate deployment preview (if available)
- [ ] Confirm documentation is updated

### For Deployers

- [ ] Verify staging is healthy
- [ ] Check all tests passed
- [ ] Review performance metrics
- [ ] Plan rollback strategy
- [ ] Notify stakeholders
- [ ] Monitor post-deployment

---

## 📈 Monitoring Dashboards

### GitHub Actions Metrics

Access at: `https://github.com/[org]/[repo]/actions`

**Key Metrics:**
- Workflow run history
- Success/failure rate
- Average duration
- Queue time
- Runner usage

### Application Metrics

**Staging Dashboard:** `https://grafana.staging.example.com`
**Production Dashboard:** `https://grafana.prod.example.com`

**Key Metrics:**
- API response times
- Error rates
- Resource utilization
- Database performance
- Cache hit rates

---

## 🔄 Common Commands

### GitHub CLI Commands

```bash
# List workflow runs
gh run list --workflow=frontend-ci-cd.yml

# View workflow run
gh run view [run-id]

# Re-run workflow
gh run rerun [run-id]

# Cancel workflow run
gh run cancel [run-id]

# Download artifacts
gh run download [run-id]

# Trigger workflow manually
gh workflow run frontend-ci-cd.yml

# List workflows
gh workflow list
```

### Useful Git Commands

```bash
# View recent tags
git tag --sort=-v:refname | head -10

# Create annotated tag
git tag -a v1.0.0 -m "Release v1.0.0"

# Push tag
git push origin v1.0.0

# Delete remote tag (careful!)
git push --delete origin v1.0.0

# View commit history since last tag
git log $(git describe --tags --abbrev=0)..HEAD --oneline
```

---

## 📚 Learning Resources

### Official Documentation

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Workflow Syntax Reference](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions)
- [GitHub Actions Marketplace](https://github.com/marketplace?type=actions)

### Internal Documentation

- [Complete Workflow Design](WORKFLOW_AND_AGENTS_DESIGN.md)
- [Visual Workflow Diagrams](WORKFLOW_VISUAL_DIAGRAMS.md)
- [System Architecture Documentation](README.md)

### Training Materials

- **Onboarding Guide:** Internal wiki → CI/CD section
- **Video Tutorials:** Internal learning platform
- **Office Hours:** Weekly DevOps office hours (Wednesdays 3-4 PM)

---

## 📝 Workflow Status Badge

Add to your README.md:

```markdown
![CI/CD Status](https://github.com/[org]/[repo]/workflows/Frontend%20CI%2FCD/badge.svg)
![Security Scan](https://github.com/[org]/[repo]/workflows/Security%20Scan/badge.svg)
![Test Coverage](https://img.shields.io/codecov/c/github/[org]/[repo])
```

---

## 🗓️ Maintenance Schedule

| Task | Frequency | Owner |
|------|-----------|-------|
| Update action versions | Monthly | DevOps |
| Review workflow performance | Weekly | DevOps |
| Clean up old artifacts | Monthly | Automated |
| Security audit | Quarterly | Security Team |
| Cost optimization review | Monthly | DevOps Lead |
| Documentation update | As needed | All |

---

## Document Control

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | December 2025 | DevOps Team | Initial quick reference |

**Status:** Final  
**Last Updated:** December 2025

---

**End of Quick Reference Guide**
