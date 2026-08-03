const path = require("path");
const vscode = require("vscode");
const { LanguageClient, TransportKind } = require("vscode-languageclient/node");

let client;
let terminal;

function repoRootFor(context) {
  return path.resolve(context.extensionPath, "..", "..", "..");
}

function powershellScriptCommand(script, args) {
  const quotedScript = `"${script.replace(/"/g, '\\"')}"`;
  const quotedArgs = args.map((arg) => `"${String(arg).replace(/"/g, '\\"')}"`).join(" ");
  return `powershell.exe -NoProfile -ExecutionPolicy Bypass -File ${quotedScript} ${quotedArgs}`;
}

function currentSevenFile() {
  const editor = vscode.window.activeTextEditor;
  if (!editor || editor.document.languageId !== "seven") {
    vscode.window.showWarningMessage("Open a Seven .sv file first.");
    return undefined;
  }
  return editor.document.uri.fsPath;
}

function runSevenDev(context, command, args = []) {
  const file = currentSevenFile();
  if (!file) {
    return;
  }

  const configured = vscode.workspace.getConfiguration("seven").get("devCommand");
  const devScript = configured || path.join(repoRootFor(context), "tools", "seven-dev.ps1");
  if (!terminal) {
    terminal = vscode.window.createTerminal("Seven");
  }
  terminal.show();
  terminal.sendText(powershellScriptCommand(devScript, [command, file, ...args]));
}

function activate(context) {
  const configured = vscode.workspace.getConfiguration("seven").get("languageServer.command");
  const workspaceFolder = vscode.workspace.workspaceFolders && vscode.workspace.workspaceFolders[0]
    ? vscode.workspace.workspaceFolders[0].uri.fsPath
    : context.extensionPath;
  const repoRoot = repoRootFor(context);
  const serverScript = configured || path.join(repoRoot, "tools", "seven-lsp.ps1");

  const serverOptions = {
    command: "powershell.exe",
    args: ["-NoProfile", "-ExecutionPolicy", "Bypass", "-File", serverScript],
    transport: TransportKind.stdio
  };

  const clientOptions = {
    documentSelector: [{ scheme: "file", language: "seven" }],
    synchronize: {
      fileEvents: vscode.workspace.createFileSystemWatcher("**/*.sv")
    },
    workspaceFolder
  };

  client = new LanguageClient("sevenLanguageServer", "Seven Language Server", serverOptions, clientOptions);
  context.subscriptions.push(client.start());
  context.subscriptions.push(vscode.commands.registerCommand("seven.checkFile", () => runSevenDev(context, "check")));
  context.subscriptions.push(vscode.commands.registerCommand("seven.runFile", () => runSevenDev(context, "run")));
  context.subscriptions.push(vscode.commands.registerCommand("seven.debugFile", () => runSevenDev(context, "debug", ["--locals"])));
}

function deactivate() {
  if (!client) {
    return undefined;
  }
  return client.stop();
}

module.exports = {
  activate,
  deactivate
};
