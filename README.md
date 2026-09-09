# GGprojects — 个人项目仓库

个人的小项目大本营，每个项目一个子文件夹，统一用 git 管理。

## 项目列表

### 🕐 桌面时钟（DesktopClock）

一个简洁大气的**桌面时钟挂件**，显示公历、农历、星期、节日、节气、天气。

- **运行**：双击 `DesktopClock.exe` 即可（基于系统自带 .NET Framework 4.x，无需安装环境）
- **特点**：内存占用小（约 24MB 私有内存）；左键拖动、右键菜单、托盘图标；字体/字号/颜色/位置/天气全可调，实时预览
- **技术**：C# / WinForms，农历用经典查表法（1900–2100），节气用天文近似公式
- **构建**：`DesktopClock/scripts/build.bat`

> 详见子项目说明：[`DesktopClock/README.md`](DesktopClock/README.md)
