#!/usr/bin/env node

/**
 * GitHub Actions Claude Query 統合スクリプト
 * ログ表示なし、純粋な処理のみ
 * 環境変数から設定を取得
 */

const { spawn } = require('node:child_process');
const process = require('node:process');

// 環境変数から設定を取得
const query = process.env.CLAUDE_QUERY;
const systemPrompt = process.env.CLAUDE_SYSTEM_PROMPT || 'あなたは最高のエンジニアです。';
const repoOwner = process.env.GITHUB_REPO_OWNER;
const repoName = process.env.GITHUB_REPO_NAME;

// 必須パラメータのチェック
if (!query || !repoOwner || !repoName) {
  console.error('ERROR: Missing required environment variables');
  process.exit(1);
}

const repo = `${repoOwner}/${repoName}`;

// メイン処理
main();

async function main() {
  try {
    // 1. Dispatch
    await dispatch();
    
    // 2. Get Run ID
    const runId = await getLatestRunId();
    
    // 3. Poll until completion
    const result = await pollUntilComplete(runId);
    
    // 4. Extract Claude output
    const claudeOutput = await extractClaudeOutput(runId);
    
    // 結果を標準出力に出力（Makefileが受け取る）
    console.log(JSON.stringify({
      success: true,
      runId: runId,
      status: result.status,
      conclusion: result.conclusion,
      url: result.url,
      claudeOutput: claudeOutput
    }));
    
  } catch (error) {
    console.error(JSON.stringify({
      success: false,
      error: error.message
    }));
    process.exit(1);
  }
}

function dispatch() {
  return new Promise((resolve, reject) => {
    const payload = JSON.stringify({
      event_type: 'claude-query',
      client_payload: {
        query: query,
        system_prompt: systemPrompt
      }
    });

    const ghProcess = spawn('gh', [
      'api',
      '--method', 'POST',
      '--header', 'Accept: application/vnd.github.v3+json',
      `/repos/${repo}/dispatches`,
      '--input', '-'
    ], {
      stdio: ['pipe', 'pipe', 'pipe']
    });

    let stderr = '';

    ghProcess.stderr.on('data', (data) => {
      stderr += data.toString();
    });

    ghProcess.on('close', (code) => {
      if (code === 0) {
        resolve();
      } else {
        reject(new Error(`Dispatch failed: ${stderr}`));
      }
    });

    ghProcess.stdin.write(payload);
    ghProcess.stdin.end();
  });
}

function getLatestRunId() {
  return new Promise((resolve, reject) => {
    // 5秒待機してからRun IDを取得
    setTimeout(() => {
      const runListProcess = spawn('gh', [
        'run', 'list', 
        '--repo', repo,
        '--workflow', 'claude-code.yml',
        '--limit', '1',
        '--json', 'databaseId'
      ]);

      let runData = '';
      let stderr = '';
      
      runListProcess.stdout.on('data', (data) => {
        runData += data.toString();
      });

      runListProcess.stderr.on('data', (data) => {
        stderr += data.toString();
      });

      runListProcess.on('close', (code) => {
        if (code === 0) {
          try {
            const runs = JSON.parse(runData);
            if (runs.length > 0) {
              resolve(runs[0].databaseId);
            } else {
              reject(new Error('No workflow runs found'));
            }
          } catch (error) {
            reject(new Error(`Failed to parse run data: ${error.message}`));
          }
        } else {
          reject(new Error(`Failed to get workflow run: ${stderr}`));
        }
      });
    }, 5000);
  });
}

function pollUntilComplete(runId) {
  return new Promise((resolve, reject) => {
    const poll = () => {
      const viewProcess = spawn('gh', [
        'run', 'view', runId,
        '--repo', repo,
        '--json', 'status,conclusion,url'
      ]);

      let statusData = '';
      let stderr = '';

      viewProcess.stdout.on('data', (data) => {
        statusData += data.toString();
      });

      viewProcess.stderr.on('data', (data) => {
        stderr += data.toString();
      });

      viewProcess.on('close', (code) => {
        if (code === 0) {
          try {
            const runInfo = JSON.parse(statusData);
            
            if (runInfo.status === 'completed') {
              resolve(runInfo);
            } else {
              // 5秒後に再ポーリング
              setTimeout(poll, 5000);
            }
          } catch (error) {
            reject(new Error(`Failed to parse status data: ${error.message}`));
          }
        } else {
          reject(new Error(`Failed to get workflow status: ${stderr}`));
        }
      });
    };
    
    poll();
  });
}

function extractClaudeOutput(runId) {
  return new Promise((resolve, reject) => {
    const logProcess = spawn('gh', [
      'run', 'view', runId,
      '--repo', repo,
      '--log'
    ]);

    let logData = '';
    let stderr = '';

    logProcess.stdout.on('data', (data) => {
      logData += data.toString();
    });

    logProcess.stderr.on('data', (data) => {
      stderr += data.toString();
    });

    logProcess.on('close', (code) => {
      if (code === 0) {
        // Claude出力を抽出
        const lines = logData.split('\n');
        let inResult = false;
        let claudeOutput = [];

        for (const line of lines) {
          if (line.includes('### CLAUDE_RESULT_START ###')) {
            inResult = true;
            continue;
          }
          if (line.includes('### CLAUDE_RESULT_END ###')) {
            inResult = false;
            continue;
          }
          if (inResult) {
            // タイムスタンプを除去
            const cleanLine = line.replace(/^.*\d{2}:\d{2}:\d{2}\.\d+Z\s*/, '');
            claudeOutput.push(cleanLine);
          }
        }

        resolve(claudeOutput.join('\n'));
      } else {
        reject(new Error(`Failed to get workflow logs: ${stderr}`));
      }
    });
  });
} 