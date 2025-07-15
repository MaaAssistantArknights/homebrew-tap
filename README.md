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
            <td>macOS 15 (Sequoia)</td>
            <td>aarch64 (Apple Silicon)</td>
        </tr>
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
- `playcover-maa`: 用于 MAA 的 PlayCover 分支（MAA Fork of PlayCover）。

## 开发者指引 (Developer guide)

CI 提供了自动化的构建和发布功能，当你添加或者更新了一个 Formula 并提交 PR 后 CI 会自动测试并构建对应的 bottle。
当构建成功后，你可以向 PR 添加 `Automerge` 标签，CI 会自动将 PR 合并到 `main` 分支，发布 bottle 到 GitHub Release 并更新 Formula 内 bottle 的内容。
注意，请不要直接通过 Github 的 Merge 按钮合并 PR，否则 CI 无法自动发布 bottle。

对于 Cask，由于不需要构建，请直接通过 Merge 按钮合并 PR。对于 Cask 推荐使用 Squash and Merge 功能以减少历史记录。
