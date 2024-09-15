# MaaAssistantArknights Homebrew Tap

这是一个用于安装 MaaAssistantArknights (MAA) 相关软件的 Homebrew Tap。

This is a Homebrew Tap for installing MaaAssistantArknights (MAA) related software.

## 如何安装包 (How do I install these formulae and casks?)

```bash
brew install MaaAssistantArknights/tap/<formula>
```

or

```bash
brew tap MaaAssistantArknights/tap
brew install <formula>
```

## 可用软件 (Available software)

### Formulae

- `maa-cli`: MAA 命令行工具 (MAA CLI tool)。
- `maa-cli-beta`: MAA 命令行工具的测试版本 (Beta version for MAA CLI tool)。
- `maa-core`: MAA 核心库 `libMaaCore.(so|dylib)` (MAA Core)。
- `maa-core-beta`: MAA 核心库的测试版本（Beta version for MAA Core)。

#### 预编译 bottle (Prebuilt bottle)

由于 Homebrew 不支持交叉编译，且由于 GitHub Action runner 支持有限，目前只提供部份平台的预编译 bottle。

Due to the limitation of Homebrew and GitHub Action runner, we only provide prebuilt bottle for some platforms.

<table>
    <thead>
        <tr>
            <th>操作系统 (OS) </th>
            <th>处理器架构 (Architecture)</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>macOS 14 (Sonoma)</td>
            <td>aarch64 (Apple Silicon)</td>
        </tr>
        <tr>
            <td>macOS 13 (Ventura)</td>
            <td>x86_64</td>
        </tr>
        <tr>
            <td>Linux</td>
            <td>x86_64</td>
        </tr>
    </tbody>
</table>

### Casks (only for macOS)

- `maa-cli-bin`: `maa-cli` 的二进制版本 (Binary version of `maa-cli`)；
- `maa-gui`: MAA macOS 图形界面 (MAA macOS GUI)；
- `maa-gui-beta`: MAA macOS 图形界面的测试版本 (Beta version of MAA macOS GUI)。

## 开发者指引 (Developer guide)

CI 提供了自动化的构建和发布功能，当你添加或者更新了一个 Formula 或者 Cask 时，提交 PR 后 CI 会自动测试并构建对应的 bottle。当构建成功后，你可以向 PR 添加 `pr-pull` 标签，CI 会自动将该 PR 合并到 `main` 分支并将 bottle 发布到 GitHub Release 同时更新 Formula 内 bottle 的内容。注意，对于 Formula，你必须在 PR 中添加 `pr-pull` 标签才能使 CI 自动合并并上传 bottle，否则你需要手动上传 bottle 并更新 Formula 内 bottle 的内容。
