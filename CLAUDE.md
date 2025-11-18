# CLAUDE.md - AI Assistant Guide for terraform-aws-r53-gsuite

This document provides comprehensive guidance for AI assistants working on the `terraform-aws-r53-gsuite` repository.

## Repository Overview

### Purpose

This Terraform module manages AWS Route53 DNS records for Google Workspace (GSuite) email hosting. It automates the creation of MX records and optional verification/DNS records for domain configuration.

### Key Features

- **MX Records**: Automatically creates the 5 required Google Workspace MX records with proper priority
- **Domain Verification**: Optional TXT records for Google domain verification
- **GitHub Pages Verification**: Optional TXT records for GitHub Pages domain verification
- **DNS Records**: Optional A records for apex, www, and wildcard subdomains
- **Tagging**: Common tags for AWS resource organization (Customer, Application, Environment)

### Future Roadmap

- DKIM implementation
- DMARC records
- SPF records

## Codebase Structure

```
terraform-aws-r53-gsuite/
├── main.tf                   # Primary Terraform configuration
├── variables.tf              # Input variable definitions
├── outputs.tf                # Output definitions (NOTE: Contains SNS references not in main.tf)
├── README.md                 # User-facing documentation
├── Makefile                  # Build automation (contributor updates)
├── CODEOWNERS                # Code ownership (@jon-the-dev)
├── .pre-commit-config.yaml   # Pre-commit hooks configuration
├── .gitignore                # Python-focused gitignore
└── .github/
    ├── workflows/            # CI/CD automation
    │   ├── review-bot.yml    # PR quality checks
    │   ├── docs-build.yml    # MkDocs documentation deployment
    │   ├── cron-update-pre-commit.yml  # Weekly pre-commit updates
    │   ├── dependabot-auto-merge.yml   # Automated dependency updates
    │   ├── openai.yml        # AI integration
    │   └── stale.yml         # Stale issue management
    ├── ISSUE_TEMPLATE/       # Issue templates
    └── PULL_REQUEST_TEMPLATE.md  # PR template
```

## Terraform Module Architecture

### Resources (main.tf:18-71)

1. **MX Records** (`aws_route53_record.mx_records`)
   - Creates 5 separate MX records for Google Workspace
   - Uses count-based iteration over `local.google_mx_records`
   - Fixed TTL of 300 seconds
   - Priorities: 1, 5, 5, 10, 10

2. **Google Verification TXT** (`aws_route53_record.google_verification`)
   - Conditional resource (`enable_google_verification`)
   - User-provided verification value

3. **GitHub Pages Verification TXT** (`aws_route53_record.github_verification`)
   - Conditional resource (`enable_github_pages_verification`)
   - User-provided verification value

4. **Wildcard A Record** (`aws_route53_record.wildcard_record`)
   - Conditional resource (`enable_wildcard_record`)
   - Pattern: `*.${var.domain_name}`

5. **Apex A Record** (`aws_route53_record.apex_record`)
   - Conditional resource (`enable_apex_record`)
   - Points to user-specified IP

6. **WWW A Record** (`aws_route53_record.www_record`)
   - Conditional resource (`enable_www_record`)
   - Pattern: `www.${var.domain_name}`

### Variables (variables.tf:1-94)

**Required Variables:**

- `cust` - Customer identifier for tagging
- `app` - Application identifier for tagging
- `env` - Environment name (dev, test, production)
- `domain_name` - Domain for DNS records
- `zone_id` - Route53 hosted zone ID

**Unused Variables (Legacy/Mismatch):**

- `topic_name` - SNS topic name (not used in main.tf)
- `service_identifiers` - SNS service list (not used in main.tf)

**Optional Variables:**

- `enable_google_verification` (default: false)
- `google_verification_value` (default: "")
- `enable_github_pages_verification` (default: false)
- `github_verification_value` (default: "")
- `enable_wildcard_record` (default: false)
- `wildcard_target` (default: "")
- `enable_apex_record` (default: false)
- `apex_target` (default: "")
- `enable_www_record` (default: false)
- `www_target` (default: "")

### Outputs (outputs.tf:1-4)

**⚠️ KNOWN ISSUE:** The output references `aws_sns_topic.sns_topic.arn` which does not exist in main.tf. This appears to be legacy code or from a different module.

### Data Sources (main.tf:1)

- `aws_region.current` - Gets current AWS region (unused in current implementation)

### Local Values (main.tf:3-16)

- `common_tags` - Standardized tagging map
- `google_mx_records` - Static list of 5 Google MX servers with priorities

## Development Workflow

### Pre-commit Hooks (.pre-commit-config.yaml)

All commits must pass these automated checks:

**Formatting:**

- **Prettier** (v2.7.1) - Code formatting
- **markdownlint** (v0.33.0) - Markdown linting with auto-fix

**Security & Quality:**

- **detect-private-key** - Prevents committing secrets
- **check-added-large-files** - Prevents large file commits
- **check-merge-conflict** - Detects merge conflict markers
- **check-yaml** - YAML syntax validation

**Terraform-Specific:**

- **terraform_fmt** - Code formatting with `-recursive` flag
- **terraform_docs** - Auto-generates documentation in README.md
- **terraform_validate** - Validates Terraform syntax
- **terraform_tflint** - Linting for best practices
- **tfsec** (v1.28.1) - Security scanning

**Additional Checks:**

- **shellcheck** (v0.8.0.3) - Shell script linting
- **pylint** (v2.6.0) - Python linting (max line length: 80)
- **check-github-actions** - GitHub Actions workflow validation

### CI/CD Workflows

#### Pull Request Checks (review-bot.yml)

Runs on every PR:

- **markdownlint** - Markdown quality (excludes MD013, MD007, MD033, etc.)
- **detect-secrets** - Secret scanning with reviewdog
- **yamllint** - YAML linting on `src/` directory
- **trivy** - Filesystem security scanning (fails on errors)
- **terraform_validate** - Terraform validation with warning level
- **shellcheck** - Shell script validation

All use `reviewdog` for inline PR comments.

#### Documentation (docs-build.yml)

Runs on push to `master`/`main`:

- Builds and deploys MkDocs Material documentation to GitHub Pages
- Uses weekly cache for faster builds
- Auto-commits as `github-actions[bot]`

#### Dependency Management

- **dependabot.yml** - Automated dependency updates
- **cron-update-pre-commit.yml** - Weekly pre-commit hook updates (Tuesdays at 15:00 UTC)
  - Creates automated PRs with `[robot]` prefix
  - Targets `master` branch

### Git Workflow

- **Main Branch**: `master` (legacy naming)
- **Code Owner**: @jon-the-dev
- **PR Template**: Requires "What is changing?", "Why this is needed?", and "References" sections

### Contributors Management

Use `make update-contributors` to regenerate the CONTRIBUTORS file from git history.

## Coding Conventions

### Terraform Standards

1. **Formatting**: Use `terraform fmt -recursive` before committing
2. **Resource Naming**: Use snake_case (e.g., `mx_records`, `google_verification`)
3. **Conditional Resources**: Use `count` with boolean flags (e.g., `count = var.enable_feature ? 1 : 0`)
4. **TTL Standard**: All DNS records use 300 seconds (5 minutes)
5. **Tagging**: Always include `common_tags` local for AWS resources
6. **Variable Ordering**: Required variables first, optional variables with defaults after

### Documentation

- **Auto-generated**: terraform-docs updates README.md automatically via pre-commit
- **Manual Updates**: Edit README.md header/footer sections outside terraform-docs markers
- **Line Length**: Keep markdown lines reasonable (MD013 disabled in CI)

### Security

- **No Secrets**: Never commit credentials, API keys, or private keys
- **tfsec Compliance**: All code must pass tfsec security scanning
- **Secret Detection**: Pre-commit and CI detect-secrets hooks active

## Common Tasks for AI Assistants

### Adding a New DNS Record Type

1. Add variable in `variables.tf`:

   ```hcl
   variable "enable_<record_type>" {
     description = "Whether to enable <record_type> record."
     type        = bool
     default     = false
   }

   variable "<record_type>_value" {
     description = "The value for <record_type> record."
     type        = string
     default     = ""
   }
   ```

2. Add resource in `main.tf`:

   ```hcl
   resource "aws_route53_record" "<record_type>" {
     count   = var.enable_<record_type> ? 1 : 0
     zone_id = var.zone_id
     name    = var.domain_name
     type    = "<TYPE>"
     ttl     = 300
     records = [var.<record_type>_value]
   }
   ```

3. Run `terraform fmt -recursive`
4. Commit - pre-commit hooks will auto-generate docs

### Fixing the outputs.tf Issue

The current `outputs.tf` references a non-existent SNS topic. Options:

1. **Remove the output** - If SNS is not part of this module
2. **Add SNS resource** - If SNS notifications are intended
3. **Replace with relevant output** - E.g., MX record FQDNs

Consult with the code owner (@jon-the-dev) before making changes.

### Testing Changes

1. **Local Testing**:

   ```bash
   terraform fmt -recursive
   terraform validate
   tflint
   tfsec .
   ```

2. **Pre-commit**: `pre-commit run --all-files`

3. **Integration**: Create test Terraform configuration that uses this module

### Updating Dependencies

- **Manual**: Edit `.pre-commit-config.yaml` rev versions
- **Automated**: Wait for weekly cron job to create PR
- **Terraform Providers**: No version constraints in this module (inherits from root module)

## Known Issues & Quirks

1. **outputs.tf Mismatch**: References SNS resources not present in main.tf
2. **Unused Variables**: `topic_name` and `service_identifiers` in variables.tf
3. **Python .gitignore**: Extensive Python ignores despite being a Terraform module
4. **Unused Data Source**: `aws_region.current` is fetched but never used
5. **Master Branch**: Uses legacy `master` naming instead of `main`
6. **Common Tags Unused**: `common_tags` local defined but never applied to resources

## Best Practices for AI Assistants

### When Making Changes

1. **Read First**: Always read the file before editing
2. **Format**: Run `terraform fmt` on modified .tf files
3. **Validate**: Ensure `terraform validate` passes
4. **Security**: Run `tfsec` to catch security issues
5. **Consistent Style**: Match existing patterns (e.g., conditional count resources)
6. **Update Tests**: If test configurations exist, update them

### When Answering Questions

1. **Reference Line Numbers**: Use `file.tf:line` format (e.g., `main.tf:18-25`)
2. **Explain Context**: Reference the Google MX requirements when discussing MX records
3. **Note Limitations**: Mention the TODO items (DKIM, DMARC, SPF)
4. **Check Versions**: Note that pre-commit hooks may update tool versions

### When Creating PRs

Follow the PR template:

- **What is changing?** - Bullet points in plain English
- **Why this is needed?** - Justification and problem-solving explanation
- **References** - Link to issues, use `closes #123` for issue closure

### Communication Style

- Be concise and technical
- Reference specific files and line numbers
- Highlight security implications
- Note breaking changes clearly
- Suggest testing approaches

## Resources & References

- **Terraform AWS Provider**: [Route53 Record Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record)
- **Google Workspace MX Records**: [Google Support](https://support.google.com/a/answer/140034)
- **Pre-commit Framework**: [pre-commit.com](https://pre-commit.com/)
- **terraform-docs**: [github.com/terraform-docs/terraform-docs](https://github.com/terraform-docs/terraform-docs)
- **tfsec**: [github.com/aquasecurity/tfsec](https://github.com/aquasecurity/tfsec)

## Contact & Ownership

- **Primary Owner**: @jon-the-dev (per CODEOWNERS)
- **Issues**: Use GitHub issue templates
- **Contributions**: Must pass all pre-commit and CI checks

---

**Last Updated**: 2025-11-18
**Repository**: terraform-aws-r53-gsuite
**Terraform Version**: No constraints (inherits from parent)
**AWS Provider Version**: No constraints (inherits from parent)
