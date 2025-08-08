# GitHub Actions: Build → ECR → Snyk Scan (Minimal)

このリポジトリは、最小の静的アプリを Docker ビルドし、Amazon ECR にプッシュして、Snyk でコンテナイメージをスキャンする GitHub Actions のデモです。

## 構成

- `app/index.html`: 最小の静的ページ
- `Dockerfile`: Python の簡易HTTPサーバで静的配信
- `.dockerignore`: 不要なファイルをビルドコンテキストから除外
- `.github/workflows/build-ecr-snyk.yml`: ビルド→ECR Push→Snykスキャン

## 事前準備

1. Snyk のアカウントを用意し、ユーザー設定から API トークンを取得
2. GitHub リポジトリの `Settings > Secrets and variables > Actions` に以下を登録
   - `SNYK_TOKEN`: Snyk の API トークン
   - `AWS_ROLE_TO_ASSUME`: GitHub OIDC で委任する IAM ロールの ARN（例: `arn:aws:iam::<ACCOUNT_ID>:role/<ROLE_NAME>`）
3. IAM ロール設定（推奨: OIDC）
   - プロバイダ: GitHub Actions OIDC (`token.actions.githubusercontent.com`)
   - トラストポリシーの `aud` は `sts.amazonaws.com`
   - `sub` は対象のリポジトリに制限（例: `repo:<owner>/<repo>:ref:refs/heads/main` など）
   - 権限ポリシー: 少なくとも `ecr:*` (Push/Pull/Describe/Create) と `sts:AssumeRole`
4. ECR リポジトリ
   - ワークフロー内で `Ensure ECR repository exists` ステップが自動作成します（名前は `ECR_REPOSITORY` 参照）。

## ワークフローの動き

- トリガー: `push`(main) と `workflow_dispatch`(手動)
- 手順:
  1) OIDC で AWS 認証
  2) ECR リポジトリの存在確認/作成
  3) Docker ビルド → ECR に Push
  4) Snyk でコンテナイメージをスキャン（SARIF をアップロード）

## 変数の変更

- `.github/workflows/build-ecr-snyk.yml` の `env` で変更:
  - `ECR_REPOSITORY`: ECR のリポジトリ名（例: `sample-app`）
  - `AWS_REGION`: リージョン（例: `ap-northeast-1`）

## 実行

- `main` ブランチへ push する、または GitHub の `Actions` タブから手動実行

## メモ

- Snyk ステップはデモのため `continue-on-error: true`。失敗でパイプラインを止めたい場合は削除してください。
