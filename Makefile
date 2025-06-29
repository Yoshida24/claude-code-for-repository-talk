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

# AI query execution with arguments support
# Usage: make ai "your query here" [--system_prompt "custom system prompt"]
.PHONY: ai
ai:
	@if [ -z "$(filter-out ai,$(MAKECMDGOALS))" ]; then \
		echo "❌ Usage: make ai \"your query here\""; \
		echo "💡 Set SYSTEM_PROMPT environment variable to customize the system prompt"; \
		echo "📝 Example: make ai \"このリポジトリの概要を教えて\""; \
		echo "📝 Example: SYSTEM_PROMPT=\"あなたは優秀なコードレビュアーです\" make ai \"コードを解析して\""; \
		exit 1; \
	fi
	@echo "🚀 Starting Claude AI Query..."
	@echo "================================"
	@QUERY="$(wordlist 2,999,$(MAKECMDGOALS))"; \
	SYSTEM_PROMPT="$${SYSTEM_PROMPT:-あなたは最高のエンジニアです。}"; \
	echo "💭 Query: $$QUERY"; \
	echo "🧠 System Prompt: $$SYSTEM_PROMPT"; \
	echo ""; \
	echo "📤 Dispatching to GitHub Actions..."; \
	DISPATCH_PAYLOAD=$$(printf '{"event_type": "claude-query", "client_payload": {"query": "%s", "system_prompt": "%s"}}' "$$QUERY" "$$SYSTEM_PROMPT"); \
	DISPATCH_RESULT=$$(echo "$$DISPATCH_PAYLOAD" | gh api --method POST --header "Accept: application/vnd.github.v3+json" /repos/Yoshida24/claude-code-for-repository-talk/dispatches --input - 2>&1); \
	if [ $$? -eq 0 ]; then \
		echo "✅ Successfully dispatched to GitHub Actions"; \
	else \
		echo "❌ Failed to dispatch: $$DISPATCH_RESULT"; \
		exit 1; \
	fi; \
	echo ""; \
	echo "⏳ Waiting for Action to start..."; \
	sleep 5; \
	echo "🔍 Getting workflow run information..."; \
	RUN_DATA=$$(gh run list --repo Yoshida24/claude-code-for-repository-talk --workflow=claude-code.yml --limit=1 --json databaseId,url,status,conclusion); \
	RUN_ID=$$(echo "$$RUN_DATA" | jq -r '.[0].databaseId'); \
	RUN_URL=$$(echo "$$RUN_DATA" | jq -r '.[0].url'); \
	echo "🔗 Action URL: $$RUN_URL"; \
	echo "🆔 Run ID: $$RUN_ID"; \
	echo ""; \
	echo "📊 Monitoring execution progress..."; \
	while true; do \
		RUN_INFO=$$(gh run view $$RUN_ID --repo Yoshida24/claude-code-for-repository-talk --json status,conclusion); \
		STATUS=$$(echo "$$RUN_INFO" | jq -r '.status'); \
		CONCLUSION=$$(echo "$$RUN_INFO" | jq -r '.conclusion'); \
		printf "\r🔄 Status: $$STATUS"; \
		if [ "$$CONCLUSION" != "null" ]; then \
			printf " | Result: $$CONCLUSION"; \
		fi; \
		if [ "$$STATUS" = "completed" ]; then \
			echo ""; \
			if [ "$$CONCLUSION" = "success" ]; then \
				echo "✅ Workflow completed successfully!"; \
			else \
				echo "❌ Workflow failed with conclusion: $$CONCLUSION"; \
				exit 1; \
			fi; \
			break; \
		fi; \
		sleep 5; \
	done; \
	echo ""; \
	echo "🤖 Claude AI Response:"; \
	echo "======================="; \
	gh run view $$RUN_ID --repo Yoshida24/claude-code-for-repository-talk --log 2>/dev/null | \
		awk '/### CLAUDE_RESULT_START ###/{flag=1; next} /### CLAUDE_RESULT_END ###/{flag=0} flag' | \
		sed 's/^.*[0-9][0-9]:[0-9][0-9]:[0-9][0-9]\.[0-9]*Z[[:space:]]*//g'; \
	echo ""; \
	echo "🎉 Query execution completed!"; \
	echo "🔗 View full logs: $$RUN_URL"

# Prevent Make from treating arguments as targets
%:
	@:
