# MaaAssistantArknights Homebrew Tap

这是一个用于安装 MaaAssistantArknights (MAA) 相关软件的 Homebrew Tap。

This is a Homebrew Tap for installing MaaAssistantArknights (MAA) related software.

## 如何安装包 (How do I install these formulae and casks?)

```bash
brew install MaaAssistantArknights/tap/<formula>`
```

or

```bash
brew tap MaaAssistantArknights/tap
brew install <formula>
```

## 可用软件 (Available software)

### Formulae

- `maa-cli`: MAA 命令行工具 (MAA CLI tool)。
- `maa-core`: MAA 核心库 `libMaaCore.(so|dylib)` (MAA Core)。
- `maa-core-beta`: MAA 核心库的测试版本（Beta version for MAA Core)。

**注意**：由于 GitHub 没有提供 `arm` 架构的免费 runner，因此不提供相应的预编译 bottle。如果你在 `arm64` 架构的 macOS 或者 Linux 上使用 `brew`，`brew` 会自动从源码编译。macOS 用户也可以使用 `maa-cli-bin` 这个 cask 来安装 `maa-cli` 的通用二进制版本。

**Note**: Due to the absence of a free runner for the `arm` architecture in Github Action, the prebuilt `arm` bottle is currently unavailable. If you're using `brew` to install formulae on an `arm` architecture macOS or Linux, `brew` will automatically compile it from the source. For macOS users, the `maa-cli-bin` cask provides an alternative, allowing the installation of the universal binary version of `maa-cli`.

### Casks (only for macOS)

- `maa-cli-bin`: `maa-cli` 的二进制版本 (Binary version of `maa-cli`)；
- `maa-gui`: MAA macOS 图形界面 (MAA macOS GUI)；
- `maa-gui-beta`: MAA macOS 图形界面的测试版本 (Test version of MAA macOS GUI)。

## 开发者指引 (Developer guide)

CI 提供了自动化的构建和发布功能，当你添加或者更新了一个 Formula 或者 Cask 时，提交 PR 后 CI 会自动测试并构建对应的 bottle。当构建成功后，你可以向 PR 添加 `pr-pull` 标签，CI 会自动将该 PR 合并到 `main` 分支并将 bottle 发布到 GitHub Release 同时更新 Formula 内 bottle 的内容。注意，对于 Formula，你必须在 PR 中添加 `pr-pull` 标签才能使 CI 自动合并并上传 bottle，否则你需要手动上传 bottle 并更新 Formula 内 bottle 的内容。
