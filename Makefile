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

.PHONY: claude-query
claude-query:
	@echo "=== Triggering Claude Query Action ==="
	@echo '{"event_type": "claude-query", "client_payload": {"query": "このリポジトリのREADME.mdからサマリを作成してください", "system_prompt": "あなたは最高のエンジニアです。"}}' \
		| gh api --method POST --header "Accept: application/vnd.github.v3+json" \
		/repos/Yoshida24/claude-code-for-repository-talk/dispatches --input -
	@echo ""
	@echo "=== Waiting for Action to start ==="
	@sleep 5
	@echo "=== Getting latest workflow run ==="
	@RUN_URL=$$(gh run list --repo Yoshida24/claude-code-for-repository-talk --workflow=claude-code.yml --limit=1 --json url --jq '.[0].url'); \
	echo "Action started: $$RUN_URL"; \
	RUN_ID=$$(gh run list --repo Yoshida24/claude-code-for-repository-talk --workflow=claude-code.yml --limit=1 --json databaseId --jq '.[0].databaseId'); \
	echo "Run ID: $$RUN_ID"; \
	echo ""; \
	echo "=== Monitoring workflow status ==="; \
	while true; do \
		STATUS=$$(gh run view $$RUN_ID --repo Yoshida24/claude-code-for-repository-talk --json status --jq '.status'); \
		CONCLUSION=$$(gh run view $$RUN_ID --repo Yoshida24/claude-code-for-repository-talk --json conclusion --jq '.conclusion'); \
		echo "Status: $$STATUS, Conclusion: $$CONCLUSION"; \
		if [ "$$STATUS" = "completed" ]; then \
			echo ""; \
			echo "=== Workflow completed! ==="; \
			break; \
		fi; \
		echo "Waiting 5 seconds..."; \
		sleep 5; \
	done; \
	echo ""; \
	echo "=== Getting latest issue (result) ==="; \
	LATEST_ISSUE=$$(gh issue list --repo Yoshida24/claude-code-for-repository-talk --label claude-query --limit 1 --json number --jq '.[0].number'); \
	echo "Latest issue number: $$LATEST_ISSUE"; \
	echo ""; \
	echo "=== Claude Query Result ==="; \
	gh issue view $$LATEST_ISSUE --repo Yoshida24/claude-code-for-repository-talk
