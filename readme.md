# 🎮 DRDA GENERATOR - 三角符文对话动画生成器

**轻松创建《DELTARUNE》风格的对话动画！**

![drda_generator](https://socialify.git.ci/PastelPigeon/drda_generator/image?language=1&logo=data%3Aimage%2Fpng%3Bbase64%2CiVBORw0KGgoAAAANSUhEUgAAACYAAAAsCAYAAAAJpsrIAAAAAXNSR0IArs4c6QAAAplJREFUWIXtmLtq40AUhn8HddPkEVI6TfYB3Lpxsw9gMOqMcRM1xkUIyRZbiDR2s4R0JpAHSKMUhkCI2S5h3cSlYV8gLEytLcTxjqS5HFkjAkt%2BCNie0ZlP5zYzAf5HCdFJm7J9UBeCfm8S0iobQBNQrSpQVSTlimXbJOfDPrwh5aolRCetAmud6DtEXsCaSmYunHZS0xXGgdu1iw8rd4NKfYwLGEaxfxpFO5e6gAhkMZvmvquiMZu4Ocbq%2FEUIk7fCKPbmyaBqbjUdQlILsIcxjGKIy2O2wR%2BHX41jVfqYM5S%2BoEp2HZt%2FQB9o29AtNn6%2Fdy5Mc0xSvSVEJ11uEkyG8%2FTq5hTddq%2B0XQXFh3SABOda3CbVZhjFmAzn1vm5tyBATkGoRWBqE8X8lJdvGIxOAAC312sAwPrlEc%2FJeSn3djlmgpJy1aIxagdb2cdiNtUCLTcJlpskB6PTYHSC9csjrm5OtY5gV4kQnTSMYnz7%2Fiv3%2B5G4K4F12z2EUYzFbFpqzLq5QLli2QfFrewbxy%2FOvjgXJtBiEZhaSG0w8piaT2ouqeq2e363JCDzShHoSNwhjGKM3%2B%2Bt%2Fe72eo3JcJ7BM3ca1tFa9ZbqIdumrRaAClgMpxcw8pBNtDB5hgAnwzlenx7YoQxsg0UoVbocysDySd1t91Ig8%2FDr0wOHCQDjMrKVfW1L0IlCReJWoE7O5C9CAVl1Uec2QRGMDpKj2tc3tVfZ5A2sicuJ11D6VJWX3fteaXr7Os%2FWAuOGwwXoslPpXlklR%2Br%2BtycHRkdeXXffZ6G6cDmwn7%2F%2F7P7GZ89p3erU2eTYPaCH6SBI0jXMfaCKNoF%2Fh0YbXEDhM6luONQ9lT4PRokKqd2qtFc2X2DcNPCWi5%2F6VAX9BUskp5l8scTEAAAAAElFTkSuQmCC&name=1&owner=1&stargazers=1&theme=Auto)  

## 🔍 这是什么？

`drda_generator` (全称：**D**elta**R**une **D**ialogues **A**nimation Generator，三角符文对话动画生成器) 是一款使用 **Godot 引擎**开发的辅助软件。它能帮助你快速制作出类似《DELTARUNE》游戏中的对话动画效果，**大幅提升动画制作效率**！

你可以通过两种方式使用它：
1.  **命令行** 🖥️ (适合高级用户或批量操作)
2.  **图形界面 (UI)** 🖱️ (推荐大多数用户)

## 🖌️ 认识图形界面 (UI)

软件界面主要分为两部分：

1.  **编辑器** (主工作区):
	*   **左侧：对话管理器** - 方便地添加、删除、选择和排序你的对话段落。
	*   **右侧：对话编辑器** - 在这里编写具体对话内容（使用 `BBcode` 语法，下面会详细介绍）。
	*   **下方：预览区** - 实时查看当前对话的动画效果！
	*   **编辑器上方按钮**:
		*   `fz`：快速插入**中文字体样式标签**。
		*   `fe`：快速插入**英文字体样式标签**。
		*   `wsd`：快速插入**暗世界对话框样式标签**。善用这些按钮能更快完成动画！

2.  **选项管理器** ⚙️:
	*   在这里配置生成动画的各种设置：
		*   **帧率 (FPS)**：动画流畅度（默认24）。
		*   **背景颜色**：动画的背景色。
		*   **生成模式**：将所有对话合并成一个视频，还是拆分成多个单独视频？
		*   **输出路径**：生成的动画文件保存在哪里？
		*   **生成格式**：选择视频格式 (MP4, MOV) 或动图 (GIF)。
		*   **启用透明背景**：是否让背景透明？（注意：MP4格式不支持透明）。

## 📖 必学：BBCODE 语法

`BBcode` 是一种用方括号 `[ ]` 标记文本的简单语言（类似HTML），它能让你在对话里添加各种炫酷效果！在 `drda_generator` 中，主要使用两种标签：

1.  **包裹型标签** (最常见):
	*   格式：`[标签名=参数]你的文本[/标签名]` 或 `[标签名=参数]你的文本[/]` (简便写法)。
	*   **作用**：改变被包裹文本的样式或添加动画。
	*   **效果可以叠加**！例如：
		```bbcode
		[shake level=20][rainbow]酷炫文字！[/][/shake]
		```
		*这段文字会同时抖动和显示彩虹效果。*
	*   **重要提示**：
		*   标签必须正确嵌套，不能交叉！像 `[b]粗体[i]粗斜体[/b]斜体[/i]` 是**错误**的。
		*   简便写法 `[/]` 虽然省事，但用多了会让文本难以阅读，建议只在简单标签时使用。

2.  **自闭合型标签**:
	*   格式：`[标签名=参数/]`
	*   **作用**：本身像一个特殊指令，不包裹文本，常用于添加停顿。
	*   例如：`[wait=2/]` 会让对话停顿 2 秒再继续。

### ✨ 支持的 BBCode 特效标签

以下是 `drda_generator` 支持的常用特效标签，让你的对话活起来：

| 效果名称 | 标签示例                                       | 作用与参数说明                                                                                                                               | 小贴士                                                                 |
| :------- | :--------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------- | :--------------------------------------------------------------------- |
| **脉冲**   | `[pulse freq=1.0 color=#ffffff40]闪烁[/pulse]` | 让文字忽明忽暗地闪烁。<br>`freq`：闪烁快慢（越大越快）。<br>`color`：闪烁时的目标颜色（带透明度）。<br>`ease`：动画平滑度（默认-2.0）。      | 适合强调关键台词！                                                     |
| **波浪**   | `[wave amp=50.0 freq=5.0]波浪[/wave]`          | 让文字像波浪一样上下起伏。<br>`amp`：波浪高度。<br>`freq`：波动速度。<br>`connected=1`：字符连在一起动；`0`：字符分开动。                     | `freq=0` 时效果消失。                                                  |
| **旋风**   | `[tornado radius=10.0 freq=1.0]旋转[/tornado]` | 让文字绕圈旋转。<br>`radius`：旋转半径。<br>`freq`：旋转速度（正数顺转，负数逆转，0暂停）。<br>`connected`：同上。                            | 营造混乱或俏皮的感觉。                                                 |
| **抖动**   | `[shake rate=20.0 level=5]发抖[/shake]`        | 让文字快速抖动。<br>`rate`：抖动频率（越快越晃）。<br>`level`：抖动幅度（越大越晃）。<br>`connected`：同上。                                  | 表现愤怒、恐惧或寒冷。                                                 |
| **渐隐**   | `[fade start=4 length=14]淡入[/fade]`          | 让文字逐渐出现（淡入效果）。<br>`start`：从第几个字符开始淡入。<br>`length`：总共多少个字符完成淡入。                                          | 主要用于整段文字的渐进显示。                                           |
| **彩虹**   | `[rainbow freq=1.0]彩虹[/rainbow]`             | 让文字颜色像彩虹一样循环变化。<br>`freq`：颜色变化的速度（字符数/周期）。<br>`sat`/`val`：颜色鲜艳度和亮度。<br>`speed`：每秒颜色循环次数。 | **注意**：会覆盖文字原有颜色，字体轮廓色不变。                         |
| **颜色**   | `[color=green]绿色[/color]` 或 `[color=#00ff00]绿色[/]` | 改变文字颜色。<br>参数可以是颜色名（如`red`, `blue`）或HEX值（如`#ffff00`代表黄色）。                                                        | 基础但重要！                                                           |
| **脸图**   | `[face=spr_face_susie_alt_0]说话[/face]`                       | 指定这段文字出现时显示的角色头像。<br>参数是头像文件名（不加路径和后缀）。<br>（素材包在 `assets/character_faces/` 或 [下载链接](https://wwjo.lanzouu.com/ixce832j25sf)） | **核心功能！** 设置对话时使用的脸图                                      |
| **音效**   | `[sound=susie]吼叫[/sound]`                    | 指定这段文字出现时播放的角色语音音效。<br>参数是角色英文名（如`susie`, `ralsei`）。<br>**默认**使用基础对话音效。                               | 赋予角色声音！                                                         |
| **静音**   | `[disable_sound]无声[/disable_sound]`          | 这段文字出现时**不播放**任何音效。                                                                                                           | 用于旁白、内心独白或需要安静的场合。                                   |
| **文本延时** | `[delay=0.5]慢点出现[/delay]`                  | 控制这段文字**逐字出现**的速度。<br>参数是每个字出现前的等待时间（秒）。                                                                      | 调整对话节奏，营造悬念或强调。                                         |
| **对话框样式** | `[world_state=dark]暗世界[/world_state]`       | 设置这段对话使用的对话框样式。<br>`light`：光世界样式 (默认)。<br>`dark`：暗世界样式。<br>**建议**：一句话内保持样式统一。                     | 区分不同世界或场景氛围。                                               |
| **等待**   | `[wait=1.5/]`                                  | 在**当前位置**插入一个停顿。<br>参数是等待时间（秒）。<br>**提示**：通常放在一句话的结尾或需要强调的地方。<br>**注意**：当前版本建议放在需要等待的位置的**前一个字符处**。 | **非常重要！** 控制对话节奏，避免文字瞬间显示完。                      |
| **小对话框（画外音）**   | `[off_screen face=example text=example/]`                                  | 在**当前位置**插入一个小对话框。<br>face属性需填写脸图id，text属性填写对话文本（不支持bbcode标签）</br>**注意**：当前版本建议放在需要出现小对话框的位置的**前一个字符处**。 | 小对话框可以表示其他角色的反应                      |
| **选项对话框**   | `[options options=<option1, option2> actions=<1\|1, 2\|-2>/]`                                  | 插入一个选项对话框，<br>`options`: 选项列表， 定义选项文本，采用`<>`包裹，`,`分割<br>`actions`: 动作列表，定义选择或确定等动作，采用`<>`包裹，`,`分割，动作项采用`\|`分割，格式`动作延时\|选中选项`（当选中选项为-2时，意为确认选择） | 建议将`options`自闭合标签放在单独对话中                      |

## ⚙️ 配置选项说明

选项让你能精细控制生成动画的方式：

*   **`--fps` (帧率)**:
	*   **作用**：决定动画每秒播放多少帧，影响流畅度。
	*   **默认**：`24` (电影常用帧率)。
	*   **建议**：一般 `24` 或 `30` 帧率就足够流畅，过高的帧率可能引起问题。
*   **`--background` (背景颜色)**:
	*   **作用**：设置生成动画的背景颜色。
	*   **注意**：如果你打算在剪辑软件里抠掉背景（换场景），选一个**不会**和文字颜色冲突的背景色（比如亮绿或亮蓝），方便后期抠像。
*   **`--recording_mode` (生成/录制模式)**:
	*   **作用**：控制如何输出对话。
		*   将所有对话**合并**成一个长视频。
		*   将每个对话**拆分**成单独的短视频。
*   **`--recordings_output_dir` (输出路径)**:
	*   **作用**：生成的动画文件保存到哪个文件夹。
	*   **默认**：首次启动时通常是你的系统“视频”文件夹。
*   **`--recording_format` (生成内容格式)**:
	*   **作用**：选择生成的动画文件格式。
	*   **对比**：
		| 格式 | 文件大小 | 支持透明背景? | 支持对话音效? | 适用场景                     |
		| :--- | :------- | :------------- | :------------- | :--------------------------- |
		| MP4  | 小       | ❌ 不支持       | ✔️ 支持        | 标准视频，带声音，文件小     |
		| MOV  | 大       | ✔️ 支持        | ✔️ 支持        | 需要透明背景+声音的高质量视频 |
		| GIF  | 小       | ✔️ 支持        | ❌ 不支持      | 网页动图、表情包，无声音     |
*   **`--recording_enable_transparent` (启用透明背景)**:
	*   **作用**：开启后，生成的动画背景将是透明的（方便叠加到其他画面上）。
	*   **重要限制**：此选项**仅对 MOV 和 GIF 格式有效**。选择 MP4 格式时无法启用透明背景。

---

**开始创作你的《DELTARUNE》风格动画吧！** 🎬✨
