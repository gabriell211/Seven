# Seven Windows installer

Seven's professional Windows installer is authored with WiX Toolset.

The MSI installs per machine into:

```text
%ProgramFiles%\Seven
```

It provides:

- embedded payload cabinet;
- UAC/elevated installation flow;
- Apps & Features registration;
- clean uninstall;
- Start Menu shortcut;
- `.sev` file association;
- machine `PATH` entry for `seven.exe`;
- official Seven icon metadata;
- future-ready signing path via Windows SDK `signtool`.

The release workflow installs WiX through the checked-in .NET SDK available on
GitHub-hosted Windows runners and builds the MSI from `seven-product.wxs`.

Local build shape:

```text
wix build -acceptEula wix7 -arch x64 packaging/windows/wix/seven-product.wxs -d SevenVersion=0.2.1 -d PayloadRoot=<payload> -d SevenIcon=brand/seven.ico -out build/seven-0.2.1-windows-x64.msi
wix msi validate -acceptEula wix7 build/seven-0.2.1-windows-x64.msi
```
