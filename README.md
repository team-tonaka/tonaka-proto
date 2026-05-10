# tonaka-proto

team-tonaka 서비스의 gRPC / Connect 통신을 위한 Protocol Buffers 정의 및 코드 생성 관리.

`.proto` 파일이 main에 머지되면 CI가 자동으로 각 언어별 생성 코드를 커밋한다.

## 디렉토리 구조

```
tonaka-proto/
├── proto/                              # Protocol Buffers 정의
│   └── {product}/
│       └── {service}/
│           └── v1/
│               └── *.proto
├── gen/
│   ├── go/{product}/                   # Go 생성 코드
│   └── typescript/{product}/           # TypeScript 생성 코드
├── profiles/                           # 플러그인 버전 번들
│   ├── go/a_1.yaml
│   └── typescript/a_1.yaml
├── buf.yaml                            # lint / breaking change 설정
└── buf.gen.yaml                        # 코드 생성 설정
```

## 서비스 목록

| 서비스 | 패키지 | RPC |
|--------|--------|-----|
| PortfolioService | `portfolio.portfolio_service.v1` | GetProfile, ListProjects, ListExperiences, ListSkills |

## 프로필

| 언어 | 프로필 | 구성 요소 |
|------|--------|-----------|
| Go | `a_1` | `buf.build/protocolbuffers/go:v1.36.11`, `buf.build/grpc/go:v1.6.1`, `buf.build/connectrpc/go:v1.19.1` |
| TypeScript | `a_1` | `buf.build/bufbuild/es:v2.11.0` |

## 개발 플로우

1. `proto/` 아래 `.proto` 파일 수정
2. PR 생성 → CI: lint / format / breaking change 검사
3. main 머지 → CI: `buf generate` → `gen/` 자동 커밋

## 로컬 작업

```bash
make lint      # buf lint
make fmt       # buf format -w
make breaking  # breaking change 검사 (main 대비)
make generate  # buf generate
```

## Go 생성 코드 사용

```bash
go get github.com/team-tonaka/tonaka-proto/gen/go/portfolio@latest
```

```go
import (
    portfoliov1 "github.com/team-tonaka/tonaka-proto/gen/go/portfolio/portfolio_service/v1"
    "github.com/team-tonaka/tonaka-proto/gen/go/portfolio/portfolio_service/v1/portfolio_service_v1connect"
)
```

## TypeScript 생성 코드 사용

```ts
import { PortfolioService } from "@team-tonaka/tonaka-proto/gen/typescript/portfolio/portfolio_service/v1/portfolio_service_pb";
```

## 参考

- [Buf Docs](https://buf.build/docs/)
- [Connect RPC](https://connectrpc.com/docs/)
- [API Design Guide](https://cloud.google.com/apis/design)
