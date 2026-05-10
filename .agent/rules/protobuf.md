---
description: Protobufスキーマ共通ガイドライン
applyTo: proto/**/*.proto
globs: proto/**/*.proto
paths: proto/**/*.proto
---

# Protobufスキーマ共通ガイドライン

## コア原則

1. **Buf Protobuf Style Guideの遵守**:
   - **ファイル/パッケージ命名**: ファイルとパッケージには `lower_snake_case` を使用する。パッケージ名はバージョン (`v1`、`v1alpha` など) で終わる**必要があり**、ディレクトリ構造を反映**しなければならない** (例: `package acme.product.feature.v1;` は `proto/acme/product/feature/v1/` にあるべき)。
   - **型命名**: Message、Enum、Service、RPC には `PascalCase` を使用。フィールドと oneof には `lower_snake_case` を使用。Enum 値には `UPPER_SNAKE_CASE` を使用。
   - **Enum 規約**: Enum 値には `UPPER_SNAKE_CASE` の Enum 名をプレフィックスとして付ける**必要がある** (例: `FOO_BAR_VALUE`)。ゼロ値は `ENUM_NAME_UNSPECIFIED = 0;` という名前である**必要がある**。`allow_alias` は使用しない。
   - **Service/RPC 命名**: Service 名は `Service` で終わる**必要がある** (例: `MyFeatureService`)。RPC のリクエスト/レスポンスメッセージは `RpcNameRequest`/`RpcNameResponse` または `ServiceNameRpcNameRequest`/`ServiceNameRpcNameResponse` という名前である**必要があり**、スキーマ全体で一意であるべき。リクエスト/レスポンスに `google.protobuf.Empty` を使用しない。必要であれば、代わりにカスタムの空のメッセージを定義する。
   - **インポート**: `public` または `weak` インポートは使用しない。インポートパスが常にモジュールルートからの相対パスであることを確認する。
   - **ファイルオプション**: 同じパッケージ内のすべてのファイルで、ファイルオプション (`go_package`、`java_package` など) が一貫していることを確認する。`java_outer_classname` を使用する。
   - 新しいフィールドやメッセージを追加する際は、明確なドキュメントコメント (`//`) を含める。

2. **`v1+` での破壊的な変更の回避**:
   - `v1` またはそれ以上のパッケージで、メッセージ、enum、フィールド、サービス、または RPC を削除したり名前を変更したり**しない**。
   - **ただし、本プロジェクトはまだリリース前で開発中のため、破壊的な変更は一時的に許容する。**
   - フィールドタグ番号または enum 値番号を再利用**しない**。削除されたタグ/番号/名前をマークするには `reserved` を使用する。
   - 既存のフィールドの型を変更**しない** ( `int32` -> `int64` のような、文書化された互換性のある変更を除く)。
   - フィールドの `repeated` ラベルを変更**しない** (例: スカラーから repeated、またはその逆。ただし、proto2 スカラー -> `[packed=false]` repeated は安全)。
   - `required` フィールドを追加**しない** (そもそも proto3 はサポートしていない)。_optional_ フィールドの追加は一般的に安全であり、破壊的な変更では**ない**。
   - 新しい機能は、新しい _optional_ フィールド、新しい RPC、または新しいサービスを追加することで導入する。
   - 破壊的な変更を必要とする重要な変更の場合は、`v1alpha` -> `v1` ワークフローを使用するか、新しいメジャーバージョン (`v2` など) を導入する。
   - 既存messageにOptionalなフィールドを追加するのは、破壊的変更にはあたらない。スキーマを利用するクライアントの実装があとからのOptionalなフィールドの追加を正常に処理できなかったら、それは実装側の問題である。

3. **一般的な Protobuf ベストプラクティス**:
   - **共通/Well-Known タイプの使用**: カスタムプリミティブ型（`int32 timestamp_seconds_since_epoch` や `int64 timeout_millis` など）の代わりに、以下の共通型を使用することを強く推奨する：
     - `google.protobuf.Duration`: 署名付き、固定長の時間スパン（例：`42s`）
     - `google.protobuf.Timestamp`: タイムゾーンやカレンダーに依存しない絶対的な日時（例：`2017-01-15T01:30:15.01Z`）
     - `google.type.Interval`: タイムゾーンやカレンダーに依存しない時間間隔（例：`2017-01-15T01:30:15.01Z - 2017-01-16T02:30:15.01Z`）
     - `google.type.Date`: カレンダー日付全体（例：`2005-09-19`）
     - `google.type.Month`: 年の月（例：`April`）
     - `google.type.DayOfWeek`: 曜日（例：`Monday`）
     - `google.type.TimeOfDay`: 時刻（例：`10:42:23`）
     - `google.type.Money`: 金額と通貨タイプ（例：`100 JPY`）
     - `google.protobuf.FieldMask`: 部分更新のフィールドマスク
   - **ファイルの分離**: 密接に関連している場合 (例: リクエスト/レスポンス) を除き、実際には各メッセージ、enum、またはサービスを独自のファイルで定義する。
   - **大きなメッセージを避ける**: 1つのメッセージのフィールド数を妥当な範囲に保つ。
   - **言語キーワードを避ける**: フィールド、メッセージ、または enum の名前として、言語キーワード (`NULL`、`domain`、`type` など) を使用しない。
   - **Emptyの使用を避ける**: RPCにたまたまリクエストまたはレスポンスデータがまだない場合でも、`Empty` をインポートして使用すべきではない。代わりに、RPCごとにカスタムの空のリクエストおよび/またはレスポンスメッセージを定義すべき。そうすれば、リクエストまたはレスポンスメッセージに最終的にフィールドが含まれるようになったときに、破壊的変更を恐れることなくフィールドを追加できる。
   - **すべての単数の基本型フィールドにoptionalを明示的に付ける**: proto3では単数の基本型フィールド(int32, uint32, string, bool, enum, etc.)はデフォルトでoptional扱いになるが、明示的に `optional` キーワードを付ける。これにより、フィールドに値が未設定の状態とデフォルト値(ゼロ値)が設定されている状態を将来的に区別できるようにする。

4. **Protobuf API ベストプラクティスの遵守**:
   - **リソース指向設計**: APIはリソース指向で設計する。操作ではなくリソースを中心にサービスやメッセージを定義し、標準的なメソッド（Get, List, Create, Update, Delete）でリソースを操作する構造にする。
   - **GET/LISTにおけるリソースの一貫性**: 同じリソース名でアクセスされるリソースは、GetとListで同一の値を返す。GetとListで異なる表現やフィールドセットを返す必要がある場合、それらは別のリソースとして名前を分けて定義する。
   - **Wire/Storage Protobuf の分離**: API リクエスト/レスポンスと内部ストレージ表現のための個別のメッセージタイプを設計する。ただし、サービスがストレージレイヤーである場合や、非常にパフォーマンスが重要な場合はこの限りではない。
   - **更新メソッド**: `google.protobuf.FieldMask` を使用した部分更新、または特定のきめ細かいミューテーション RPC (例: リソース全体を含む一般的な `UpdateEmployee` ではなく `PromoteEmployee`) を優先する。更新でリソース全体を置き換えることは避ける。
   - **プリミティブ型のラップ**: プリミティブ型 (string、int32、bool など) をトップレベルのリクエストまたはレスポンスメッセージとして直接使用しない。将来の拡張性のためにメッセージ型でラップする。
   - **文字列ID**: 一意の識別子には、整数型よりも `string` を優先する。構造化された内部 ID を、内部 protobuf でサポートされるウェブセーフな Base64 文字列としてエンコードすることを検討する。
   - **構造化データ**: リスト、マップ、またはその他の構造化データを文字列フィールド内にエンコードしない。`repeated` フィールドと `map` 型を使用する。
   - **ページネーション**: オフセットまたはタイムスタンプの代わりに、不透明な `string next_page_token` フィールド (内部 protobuf でサポート) をページネーションに使用する。
   - **明確さ**: フィールドとメッセージを明確かつ簡潔に文書化し、制約、目的、例を説明する。コメントには `//` を使用する。

5. **Protovalidate を使用した防御的プログラミング**:
   - `protovalidate` を使用して、id、email、name などのリクエストメッセージフィールドに適切な制約を追加 (例: 文字列と repeated フィールドの最小/最大長、email や UUID のようなフォーマットバリデーション、数値の最小/最大値)。
   - `protovalidate` の標準ルールのうち主要なものの使用例は https://protovalidate.com/schemas/standard-rules/ を参照。

6. **共通型(Common Types)の設計原則**:
   - **共通型には厳格なバリデーション制約を設定する**: 共通型を定義する際は、すべてのフィールドに `protovalidate` 制約を設定し、利用側でフィールドのrequired/non-requiredを選択できない設計とする。これにより、利用側でバリデーションがバラバラになることを防ぐ。
   - **UNSPECIFIEDの禁止を共通型に含める**: Enumを含む共通型では、`not_in: [0]` を使用してUNSPECIFIED値を禁止する制約を共通型自体に設定する。
   - **RPC固有の要件がある場合は共通型を使い回さない**: 特定のRPCで「一部フィールドが未設定」を許容する必要がある場合、共通型の使い回しを避け、RPC専用のレスポンス型を定義する。共通型の使い回しにより、クライアント側でデフォルト値(ゼロ値)が「実際にありえない状態」を表現してしまう問題を回避する。
   - **共通型はRPC間で一貫したセマンティクスを持つ場合のみ使用する**: すべてのフィールドがすべての利用箇所で同じ意味・必須条件を持つ場合のみ、共通型として定義する。

   ```protobuf
   // ❌ 悪い例: バリデーション制約のない共通型
   message EmploymentTypeDetail {
     optional string employment_type_id = 1;  // バリデーションなし
     optional string employment_type_name = 2;  // バリデーションなし
   }

   // ✅ 良い例: 厳格なバリデーション制約を持つ共通型
   message EmploymentType {
     optional string employment_type_id = 1 [
       (buf.validate.field).required = true,
       (buf.validate.field).string.uuid = true
     ];
     optional string employment_type_name = 2 [
       (buf.validate.field).required = true,
       (buf.validate.field).string.min_len = 1
     ];
   }

   // ✅ RPCごとにフィールド要件が異なる場合は専用型を定義
   // GetEmployeeのレスポンス専用
   message GetEmployeeResponse {
     EmployeeEmploymentInfo employment_info = 1;
   }
   message EmployeeEmploymentInfo {
     optional string employment_type_id = 1 [
       (buf.validate.field).required = true,
       (buf.validate.field).string.uuid = true
     ];
     // このRPCでは名前は不要なので含めない
   }
   ```

7. **サービス固有のコーディング規約の遵守**

   各サービス固有のProtobufコーディング規約が必要な場合は、以下のパスに追加する：
   - `.agent/rules/protobuf-{service}.md` (例: `protobuf-portfolio.md`)

8. **チェックとフォーマット**:
   - **必ず** `make lintfix` を実行して、スタイルとベストプラクティスの違反をチェックする。
   - **必ず** `make fmt` を実行して、適切にフォーマットされていることを確認する。

## Buf Protobuf Style Guide

### 必須事項

#### ファイルとパッケージ

- すべてのファイルにはパッケージが定義されていなければならない。
- 同じパッケージのすべてのファイルは、同じディレクトリになければならない。すべてのファイルは、そのパッケージ名と一致するディレクトリになければならない。
- パッケージは `lower_snake_case` 形式でなければならない。
- パッケージの最後のコンポーネントはバージョンでなければならない。
- ファイル名は `lower_snake_case.proto` 形式でなければならない。
- ファイルオプション(`go_package` 等)は、同じパッケージを持つすべてのファイルで同じ値を持つか、すべて未設定でなければならない。

#### インポート

- インポートを `public` または `weak` として宣言してはならない。

#### Enum (列挙型)

- Enumは `allow_alias` オプションを設定してはならない。
- Enum名は `PascalCase` でなければならない。
- Enum値の名前は `UPPER_SNAKE_CASE` でなければならない。
- Enum値の名前には、Enum名の `UPPER_SNAKE_CASE` を接頭辞として付けなければならない。 例えば、Enum `FooBar` が与えられた場合、すべてのEnum値の名前に `FOO_BAR_` を接頭辞として付ける。
- すべてのEnumのゼロ値には `_UNSPECIFIED` を接尾辞として付けなければならない。例えば、Enum `FooBar` が与えられた場合、ゼロ値は `FOO_BAR_UNSPECIFIED = 0;` でなければならない。

#### Message (メッセージ)

- Message名は `PascalCase` でなければならない。
- フィールド名は `lower_snake_case` でなければならない。
- Oneof名は `lower_snake_case` でなければならない。

#### Service (サービス)

- Service名は `PascalCase` でなければならない。
- Service名には `Service` を接尾辞として付けなければならない。
- RPC名は `PascalCase` でなければならない。
- すべてのRPCリクエストおよびレスポンスメッセージは、Protobufスキーマ全体で一意でなければならない。
- すべてのRPCリクエストおよびレスポンスメッセージには、RPCの後に名前を付け、`MethodNameRequest`, `MethodNameResponse` または `ServiceNameMethodNameRequest`, `ServiceNameMethodNameResponse` のいずれかの形式で命名しなければならない。

### 推奨事項

- コメントには完全な文を使用する。ドキュメントはインラインではなく、型の上に記述する。
- すべての型、特にパッケージには、広く使用されているキーワードを避ける。例えば、パッケージ名が foo.internal.bar の場合、internal コンポーネントはGoの他のパッケージで生成されたスタブのインポートをブロックする。
- ファイルは以下の順序でレイアウトする
  - ファイルの概要
  - syntax
  - package
  - import（ソート済み）
  - ファイルオプション
  - その他すべて

- repeated フィールドには複数形の名前を使用する
- 可能な限り、フィールドはその型にちなんで命名する。例えば、メッセージ型 FooBar のフィールドの場合、特別な理由がない限り、フィールド名を foo_bar とする。
- ネストされたEnumやネストされたメッセージの使用を避ける。現時点ではそう思わなくても、将来的にコンテキストメッセージの外で使用したくなる可能性がある。

## Protovalidate のフィールド制約の設定例

```protobuf
syntax = "proto3";

package acme.product.feature.v1;

import "buf/validate/validate.proto";

message ApprovalRequest {
  // フィールドレベルの制約
  uint32 amount = 1 [(buf.validate.field).uint32 = {
    lte: 1000000
  }];
  string note = 2 [(buf.validate.field).string = {
    min_len: 1,
    max_len: 100
  }];
  string applicant_user_id = 3 [
    (buf.validate.field).string.uuid = true
  ];
  string approver_user_id = 4 [
    (buf.validate.field).string.uuid = true
  ];
  repeated string tags = 5 [
    (buf.validate.field).repeated.min_items = 1,
    (buf.validate.field).repeated.max_items = 5,
    (buf.validate.field).repeated.unique = true
  ];

  // メッセージレベルの制約
  option (buf.validate.message).cel = {
    id: "approver_user_id.not.applicant_user_id"
    message: "approver_user_id and applicant_user_id should not be the same value"
    expression: "this.approver_user_id != this.applicant_user_id"
  };
}
```
