# my-nixpkgs

AzumiA personal nixpkgs-like package source.

## Home Manager 使用

这个 flake 提供了 `ghosttyfetch`、`pdmaner`、`sqlmux`、`toofan` package 和 overlay，以及 Home Manager / NixOS module。

### 1. 添加 flake input

在你的系统或 Home Manager flake 里加入这个仓库：

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";

    azumia-nixpkgs.url = "github:azumia-azu/azumia-nixpkgs";
  };
}
```

本地开发时也可以用路径：

```nix
azumia-nixpkgs.url = "path:/Users/azumia/Src/azumia-nixpkgs";
```

### 2. 导入 Home Manager module

如果你使用 standalone Home Manager：

```nix
{
  inputs,
  ...
}:
{
  homeConfigurations.azumia = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {
      system = "aarch64-darwin";
      overlays = [
        inputs.azumia-nixpkgs.overlays.default
      ];
    };

    modules = [
      inputs.azumia-nixpkgs.homeManagerModules.ghosttyfetch
      inputs.azumia-nixpkgs.homeManagerModules.toofan
      ./home.nix
    ];
  };
}
```

如果你在 NixOS / nix-darwin 里集成 Home Manager，也要确保 Home Manager 使用的 `pkgs` 带上 overlay。常见写法是在系统配置里加：

```nix
{
  nixpkgs.overlays = [
    inputs.azumia-nixpkgs.overlays.default
  ];

  home-manager.sharedModules = [
    inputs.azumia-nixpkgs.homeManagerModules.ghosttyfetch
    inputs.azumia-nixpkgs.homeManagerModules.toofan
  ];
}
```

也可以在 NixOS 配置里直接导入 NixOS module：

```nix
{
  imports = [
    inputs.azumia-nixpkgs.nixosModules.toofan
  ];

  nixpkgs.overlays = [
    inputs.azumia-nixpkgs.overlays.default
  ];
}
```

### 3. 启用 ghosttyfetch

在你的 `home.nix` 里：

```nix
{
  programs.ghosttyfetch.enable = true;
}
```

启用后会安装 `ghosttyfetch`，并生成：

- `~/.config/ghosttyfetch/config.json`
- `~/.config/ghosttyfetch/animation.json`

默认的 `animation.json` 来自 package 自带文件。

### 4. 自定义 config.json

`programs.ghosttyfetch.settings` 会生成 `config.json`：

```nix
{
  programs.ghosttyfetch = {
    enable = true;

    settings = {
      fps = 20.0;
      color = "#ffffff";
      force_color = true;
      no_color = false;

      sysinfo = {
        enabled = true;
        modules = [
          "OS"
          "Kernel"
          "Shell"
          "CPU"
          "Memory"
          "Terminal"
        ];
      };
    };
  };
}
```

### 5. 自定义 animation.json

`programs.ghosttyfetch.animation` 为 `null` 时会使用 package 自带动画。设置为 attrset 时，会生成新的 `animation.json`：

```nix
{
  programs.ghosttyfetch = {
    enable = true;

    animation = {
      frame_count = 1;
      lines_per_frame = 1;
      max_width = 5;
      frames = [
        "hello"
      ];
    };
  };
}
```

### 6. 修改生成目录

默认写到 `~/.config/ghosttyfetch`。可以用 `targetDirectory` 改成 home 目录下的其它位置：

```nix
{
  programs.ghosttyfetch = {
    enable = true;
    targetDirectory = ".local/share/ghosttyfetch";
  };
}
```

## Toofan 使用

`toofan` 是终端里的波斯语、阿拉伯语、乌尔都语打字练习工具。

### 1. 直接构建或运行

```sh
nix build github:azumia-azu/azumia-nixpkgs#toofan
nix run github:azumia-azu/azumia-nixpkgs#toofan
```

### 2. Home Manager 启用

```nix
{
  programs.toofan.enable = true;
}
```

启用后会安装 `toofan`。程序运行时会在 `~/.config/toofan` 下维护配置、练习结果和个人最佳成绩。

### 3. NixOS 启用

```nix
{
  programs.toofan.enable = true;
}
```

启用后会把 `toofan` 加入 `environment.systemPackages`。

## PDManer 使用

`pdmaner` 打包自 Gitee 上游 `robergroup/pdmaner`，当前版本为 `4.9.3`。

```sh
nix build github:azumia-azu/azumia-nixpkgs#pdmaner
nix run github:azumia-azu/azumia-nixpkgs#pdmaner
```

上游发布源码不包含 `package-lock.json`，仓库内的 `overlays/pdmaner-package-lock.json` 用于固定 npm 依赖，更新 `pdmaner` 时需要同步重新生成。

## sqlmux 使用

`sqlmux` 是支持会话、分屏和表格编辑的终端数据库客户端，当前版本为 `0.10.0`。

源码来自上游 `release/v0.10.0` 分支，固定在提交 `3def4157573fb37cae0bd1b15ffd40b5117ef680`。上游的 `v0.10.0` tag 指向另一个提交。构建时会应用仓库内的 `overlays/sqlmux/changes.patch`，加入 GaussDB / openGauss 支持；该文件是指定 `changes.patch` 的原样副本。

### 1. 直接构建或运行

```sh
nix build github:azumia-azu/azumia-nixpkgs#sqlmux
nix run github:azumia-azu/azumia-nixpkgs#sqlmux -- --version
```

### 2. Home Manager 启用

按前面的说明添加 overlay，并导入 `inputs.azumia-nixpkgs.homeManagerModules.sqlmux`：

```nix
{
  programs.sqlmux.enable = true;
}
```

启用后会将 `sqlmux` 加入 `home.packages`。

### 3. NixOS 启用

添加 overlay，并导入 `inputs.azumia-nixpkgs.nixosModules.sqlmux`：

```nix
{
  programs.sqlmux.enable = true;
}
```

启用后会将 `sqlmux` 加入 `environment.systemPackages`。两个模块都提供 `programs.sqlmux.package` 选项，可覆盖默认的 `pkgs.sqlmux`。

模块只安装程序，连接和运行时配置由 sqlmux 在 `~/.config/sqlmux` 下维护。GaussDB / openGauss 连接使用 `engine = "gaussdb"`，或直接传入 `gaussdb://` / `opengauss://` URL。
