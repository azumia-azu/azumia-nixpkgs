# my-nixpkgs

AzumiA personal nixpkgs-like package source.

## Home Manager 使用

这个 flake 提供了 `ghosttyfetch`、`toofan` 等 package、overlay，以及 Home Manager / NixOS module。

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
