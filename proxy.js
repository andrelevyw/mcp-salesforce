// Thin Node.js proxy that spawns the Python MCP server
// and pipes stdin/stdout between Claude Code and Python.
const { spawn } = require("child_process");
const path = require("path");

const pythonCmd = process.platform === "win32" ? "python" : "python3";

const py = spawn(pythonCmd, [path.join(__dirname, "server.py")], {
  stdio: ["pipe", "pipe", "inherit"],
  env: { ...process.env },
});

process.stdin.pipe(py.stdin);
py.stdout.pipe(process.stdout);

py.on("exit", (code) => process.exit(code ?? 1));
process.on("SIGTERM", () => py.kill());
