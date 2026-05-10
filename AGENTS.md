# tonaka-proto

This file provides guidance to coding agents (Claude Code, Codex, Cursor, Copilot) when working in this repository.

## Repository Type

**tonaka-proto** is a centralized Protocol Buffers schema repository for the tonaka platform. It:

- Manages gRPC/Connect API definitions for tonaka services (portfolio, system_admin)
- Generates client/server code for Go and TypeScript
- Distributes generated code via Git branches and GitHub Packages (npm, planned)
- Uses a profile system to manage plugin version combinations per language

**Important**: Generated code in `gen/` is derived from proto sources. Never edit generated code directly.

## Essential Commands

```bash
make lint       # buf lint (style compliance)
make fmt        # buf format -w
make breaking   # buf breaking --against '.git#branch=main'
make generate   # buf generate (uses buf.gen.yaml)

# Profile-based generation
buf generate --template profiles/go/a_1.yaml
buf generate --template profiles/typescript/a_1.yaml
```

## Directory Structure

```
proto/
  portfolio/portfolio_service/v1/   # Portfolio read API
  system_admin/system_admin_service/v1/  # Admin CRUD API

gen/
  go/         # Generated Go code (committed to main)
  typescript/ # Generated TypeScript code (committed to main)

profiles/
  go/a_1.yaml         # Go plugin version bundle (buf.gen.yaml format)
  typescript/a_1.yaml # TypeScript plugin version bundle

buf.yaml        # Lint / breaking change config (module root: proto/)
buf.gen.yaml    # Default generation config (Go + TypeScript)
```

## Profile System

Each language has versioned profiles (`profiles/{lang}/{profile}.yaml`). Each profile is a self-contained `buf.gen.yaml` usable as a template:

```bash
buf generate --template profiles/go/a_1.yaml
```

Profiles use Renovate annotations for automated plugin version updates:
```yaml
- remote: buf.build/protocolbuffers/go:v1.36.11 # renovate: ...
```

## Protobuf Coding Guidelines

Follow the guidelines in `.agent/rules/protobuf.md` (and `.claude/rules/protobuf.md`), which covers:

- Buf Style Guide compliance (naming, packages, enums, services)
- Breaking change avoidance in v1+ packages
- `optional` on all singular primitive fields
- Protovalidate usage for field validation
- Well-Known Types (Timestamp, Duration, etc.)

## Development Workflow

1. Edit `.proto` files in `proto/{service}/{service_name}/v1/`
2. Run `make fmt && make lint && make breaking`
3. Run `make generate` to update `gen/`
4. Commit both proto sources and generated code
5. Open PR for review
