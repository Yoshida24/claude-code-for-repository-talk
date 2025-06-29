.PHONY: run
run:
	@uvx fastmcp run src/main.py

.PHONY: dev
dev:
	@uvx fastmcp dev src/main.py

.PHONY: fmt
fmt:
	@uvx ruff format
	@uvx ruff check --fix --extend-select I

.PHONY: test
test:
	@uvx pytest

# リポジトリに対する AI query を実行するクライアント側のラッパー。
# ex. make ai "your query"
# query.js を呼び出しやすくするために作ったもの。色々書いてあるが、要はテストしやすい環境変数を定義して、かつログを出しているだけで、真面目に読む必要はない。
# デフォルトではコマンドは `Yoshida24/claude-code-for-repository-talk` に対して実行されるようにした。
.PHONY: ai
ai:
	@echo "🚀 Starting Claude AI Query..."
	@QUERY="$(wordlist 2,999,$(MAKECMDGOALS))"; \
	SYSTEM_PROMPT="$${SYSTEM_PROMPT:-あなたは最高のエンジニアです。}"; \
	REPO_OWNER="$${GITHUB_REPO_OWNER:-Yoshida24}"; \
	REPO_NAME="$${GITHUB_REPO_NAME:-claude-code-for-repository-talk}"; \
	echo "💭 System Prompt: $$SYSTEM_PROMPT Query: $$QUERY"; \
	echo "📁 Repository: $$REPO_OWNER/$$REPO_NAME"; \
	echo "🔗 Actions: https://github.com/$$REPO_OWNER/$$REPO_NAME/actions"; \
	echo ""; \
	echo "📤 Dispatching to GitHub Actions. Please wait a few minutes..."; \
	RESULT=$$(CLAUDE_QUERY="$$QUERY" \
		CLAUDE_SYSTEM_PROMPT="$$SYSTEM_PROMPT" \
		GITHUB_REPO_OWNER="$$REPO_OWNER" \
		GITHUB_REPO_NAME="$$REPO_NAME" \
		node scripts/query.js 2>&1); \
	if echo "$$RESULT" | grep -q '"success":true'; then \
		echo "✅ Query execution completed successfully!"; \
		echo ""; \
		echo "🤖 Claude AI Response:"; \
		echo "======================="; \
		echo "$$RESULT" | jq -r '.claudeOutput' 2>/dev/null || echo "$$RESULT"; \
		echo ""; \
		RUN_URL=$$(echo "$$RESULT" | jq -r '.url' 2>/dev/null); \
		if [ "$$RUN_URL" != "null" ] && [ -n "$$RUN_URL" ]; then \
			echo "🔗 View full logs: $$RUN_URL"; \
		fi; \
	else \
		echo "❌ Query execution failed:"; \
		echo "$$RESULT" | jq -r '.error' 2>/dev/null || echo "$$RESULT"; \
		exit 1; \
	fi

# Prevent Make from treating arguments as targets
%:
	@:
