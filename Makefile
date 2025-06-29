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
	@echo '{"event_type": "claude-query", "client_payload": {"query": "このリポジトリのREADME.mdからサマリを作成してください", "system_prompt": "あなたは最高のエンジニアです。"}}' \
		| gh api --method POST --header "Accept: application/vnd.github.v3+json" \
		/repos/Yoshida24/claude-code-for-repository-talk/dispatches --input -
	@echo See Actions: https://github.com/Yoshida24/claude-code-for-repository-talk/actions
	@echo See Issues: https://github.com/Yoshida24/claude-code-for-repository-talk/issues
