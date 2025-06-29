.PHONY: claude-query
claude-query:
	@echo '{"event_type": "claude-query", "client_payload": {"query": "このリポジトリのREADME.mdからサマリを作成してください", "system_prompt": "あなたは最高のエンジニアです。"}}' \
		| gh api --method POST --header "Accept: application/vnd.github.v3+json" \
		/repos/Yoshida24/claude-code-for-repository-talk/dispatches --input -
