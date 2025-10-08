# 🎮 DRDA GENERATOR - DELTARUNE-style Dialogue Animation Generator

[中文](README.md)|English

**CREATE YOUR OWN DELTARUNE-STYLE DIALOGUE ANIMATION EFFORTLESSLY!**

![drda_generator](https://socialify.git.ci/PastelPigeon/drda_generator/image?language=1&logo=data%3Aimage%2Fpng%3Bbase64%2CiVBORw0KGgoAAAANSUhEUgAAACYAAAAsCAYAAAAJpsrIAAAAAXNSR0IArs4c6QAAAplJREFUWIXtmLtq40AUhn8HddPkEVI6TfYB3Lpxsw9gMOqMcRM1xkUIyRZbiDR2s4R0JpAHSKMUhkCI2S5h3cSlYV8gLEytLcTxjqS5HFkjAkt%2BCNie0ZlP5zYzAf5HCdFJm7J9UBeCfm8S0iobQBNQrSpQVSTlimXbJOfDPrwh5aolRCetAmud6DtEXsCaSmYunHZS0xXGgdu1iw8rd4NKfYwLGEaxfxpFO5e6gAhkMZvmvquiMZu4Ocbq%2FEUIk7fCKPbmyaBqbjUdQlILsIcxjGKIy2O2wR%2BHX41jVfqYM5S%2BoEp2HZt%2FQB9o29AtNn6%2Fdy5Mc0xSvSVEJ11uEkyG8%2FTq5hTddq%2B0XQXFh3SABOda3CbVZhjFmAzn1vm5tyBATkGoRWBqE8X8lJdvGIxOAAC312sAwPrlEc%2FJeSn3djlmgpJy1aIxagdb2cdiNtUCLTcJlpskB6PTYHSC9csjrm5OtY5gV4kQnTSMYnz7%2Fiv3%2B5G4K4F12z2EUYzFbFpqzLq5QLli2QfFrewbxy%2FOvjgXJtBiEZhaSG0w8piaT2ouqeq2e363JCDzShHoSNwhjGKM3%2B%2Bt%2Fe72eo3JcJ7BM3ca1tFa9ZbqIdumrRaAClgMpxcw8pBNtDB5hgAnwzlenx7YoQxsg0UoVbocysDySd1t91Ig8%2FDr0wOHCQDjMrKVfW1L0IlCReJWoE7O5C9CAVl1Uec2QRGMDpKj2tc3tVfZ5A2sicuJ11D6VJWX3fteaXr7Os%2FWAuOGwwXoslPpXlklR%2Br%2BtycHRkdeXXffZ6G6cDmwn7%2F%2F7P7GZ89p3erU2eTYPaCH6SBI0jXMfaCKNoF%2Fh0YbXEDhM6luONQ9lT4PRokKqd2qtFc2X2DcNPCWi5%2F6VAX9BUskp5l8scTEAAAAAElFTkSuQmCC&name=1&owner=1&stargazers=1&theme=Auto)  

## 🔍 What is it?

`drda_generator` (Shorthand for **D**elta**R**une **D**ialogues **A**nimation Generator) is a utility developed in **Godot**. It helps you make dialogue animations looks like in the game DELTARUNE quickly and easily, greatly improves the efficiency of creating DELTARUNE fan animations.

It can be used through:
1.  **Command Line** 🖥️ (Suitable for advanced users or batch operation)
2.  **Graphical Interface** 🖱️ (Recommended for most users)

## 🖌️ Graphic Interface Introduction

The graphical interface has two main parts:

1.  **Editor** (Main Workspace):
	*   **Left: Dialogue Manager** - Add, delete, select and sort your dialogues.
	*   **Right: Dialogue Editor** - Write your dialogue using `BBcode` syntax.
	*   **Top: Preview** - Preview the animation!
	*   **Toolbar**:
		*   `fz`: Insert **Chinese font style tag**
		*   `fe`: Insert **English font style tag**
		*   `wsd`: Insert **Dark world dialogue style tag**. Improve your efficiency with the buttons!

2.  **Settings** ⚙️:
	*   Configure the animation generation process.
		*   **FPS**: Frame per second (defaults to 24).
		*   **Background Color**: Background color of the animation.
		*   **Generation Mode**: Merge all dialogues into one video, or generate multiple videos corresponding to each dialogue?
		*   **Output Path**: Location to store the generated files.
		*   **Output Format**: Generated file format (MP4, MOV or GIF).
		*   **Transparent Background**: Control if the background is transparent (MP4 not supported)

## 📖 BBCode Syntax

`BBCode` is a simple markup langauge that uses tags enclosed in brackets `[ ]` (similar to HTML). It allows you to make special effects and control text style in the animation!

1.  **Normal Tags** (Most Common):
	*   **Format**: `[tagname=parameter]Your text[/tagname]` or `[tagname=parameter][/]` (Shorthand)。
	*   **Effect**: Change the style of text enclosed in the tag or add special animations.
	*   **Tag can be nested**! e.g.:
		```bbcode
		[shake level=20][rainbow]Cool Text! [/][/shake]
		```
		*The text will shake and display in rainbow color at the same time.*
	*   **Important Notes**：
		*   Tags must be properly nested. Things like `[b]粗体[i]粗斜体[/b]斜体[/i]` are not allowed.
		*   Abusing `[/]` might make text unreadable. Only using the syntax in simple tags is recommended.

2.  **Self-closing Tags**:
	*   **Format**: `[tagname=parameter]`
	*   **Effect**: Tag that closes itself immediately, without having any text inside.
	*   Example: `[wait=2/]` will make the dialogue pause for 2 seconds and then continue.

### ✨ BBCode Tags Supported

Here is a table of BBCode tags supported by `drda_generator`.

| Effect Name | tag example                                       | Description                                                                                                                               | Tips                                                                 |
| :------- | :--------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------- | :--------------------------------------------------------------------- |
| **Pulse**   | `[pulse freq=1.0 color=#ffffff40]Blinking[/pulse]` | Make text blink. <br>`freq`: The frequency of blinking. <br>`color`: The target color of blinking (in `#RRGGBBAA` format)<br>`ease`: Smoothness of the animation (defaults to -2.0)     | Suitable for important text!                                                     |
| **Wave**   | `[wave amp=50.0 freq=5.0]Waving[/wave]`          | Make text wave。<br>`amp`: The amplitude of the wave. <br>`freq`: The frequency of the wave. <br>`connected=1`: Characters are animated together. `0`: Characters are animated individually.                     | Won't do anything if `freq=0`.                                                  |
| **Tornado**   | `[tornado radius=10.0 freq=1.0]Spinning[/tornado]` | Make text spin. <br>`radius`: The radius of spinning. <br>`freq`: The speed of spinning *(Don't know why author is still using the word `freq` here because it obviously doesn't make sense)*. <br>`connected`: The same as in `[wave]`.                            | Making a chaos or humorous vibe.                                                 |
| **Shake**   | `[shake rate=20.0 level=5]Shaking[/shake]`        | Make text shake. <br>`rate`: The rate of shaking. *(Finally the author stopped using `freq`. Thanks to the god!)*<br>`level`: The strength of shaking. <br>`connected`: Still the same as in `[wave]`                                  | Express anger, fear or coldness.                                                 |
| **Fade**   | `[fade start=4 length=14]Fade in[/fade]`          | Make text fade in. <br>`start`: Starting from which character<br>`length`: Complete fading in when this amount of characters are shown. *(I guess.)*                                          | Fades in the text. *(Why the author keeps making useless tips like that?)*                                           |
| **Rainbow**   | `[rainbow freq=1.0]Rainbow[/rainbow]`             | Make text appear in a dynamic rainbow color. <br>`freq`: Frequency of color change. <br>`sat`/`val`: Saturation and brightness of the color, respectively. <br>`speed`: Amount of color changes repeated in one second *(Then whats the point of `freq`? Haha. I don't know. Go and ask PastelPigeon. )* | **Attention**: The original text color will be ignored. Doesn't affect outline color though.                         |
| **Color**   | `[color=green]Green[/color]` or `[color=#00ff00]Green[/]` | Change text color. <br>Parameter can be color names (e.g. `red`, `blue` etc.) or hex color code.                                                        | Fundamental but important!                                                           |
| **Face Sprite**   | `[face=spr_face_susie_alt_0]Speaking[/face]`                       | Set the face sprite when the text appear. <br>The parameter is the name of the image file, without any suffix.<br>(Assets are in `assets/character_faces/` or [Download link](https://wwjo.lanzouu.com/ixce832j25sf) *Weird chinese website but I will upload to maybe google drive later, if anyone is using the tool outside of China and doesn't trust any weird Chinese sites.* ) | **Core Functionality!** Set the face sprite when speaking. *(Yes, another useless tip. I'm starting getting used to it.)* |
| **SFX**   | `[sound=susie]Roaring[/sound]`                    | The typewriter sound effect used when the text appear. <br>Parameter is the name of the sprite, e.g. `susie` or `ralsei`. <br>Use basic typewriter sound **by default**                               | Give sprite sounds!                                                         |
| **Mute**   | `[disable_sound]Ah, muted[/disable_sound]`          | Doesn't play any sound effect when the text appears.                                                                                                           | For narration, thoughts or other situations that needs no sound.                                   |
| **Text Delay** | `[delay=0.5]Make it slower[/delay]`                  | Set the delay of each character. <br>Parameter is how long to wait before each character appears, in seconds.                                                                      | Adjust the feel of dialogue, making emphasis or suspense                                        |
| **Dialogue Box Style** | `[world_state=dark]DARK WORLD[/world_state]`       | Set the style of the dialogue box. <br>`light`: Light world style (default). (As you may know it's an UNDERTALE-like dialogue box. ) <br>`dark`: Dark world style. <br>**Suggestion**: Keep the same style in a dialogue. *(Shouldn't it be a tip??)*                     | Distinguish between worlds.                                               |
| **Waiting**   | `[wait=1.5/]`                                  | Insert a pause in **current position**. <br>Parameter is the length of the pause, in seconds.<br>**Tips**: Usually put at end of the sentence or somewhere you want to emphasis.  *(I see, the author just doesn't distinguish between the description and the tips column.)* <br>**Warning**: Put at the character that is before where you want to insert a pause. | **SUPER IMPORTANT!** Control the rhythm of the dialogue, preventing text from being displayed at once.                      |
| **Small Dialogue**   | `[off_screen face=example text=example/]`                                  | Insert a small dialogue in 8*current position**. <br>`face` needs to the id of the face sprite you want to use, and `text` is the text of the dialogue. (BBCode not supported) </br>**Warning**: Put at the character that is before where you want to insert the dialogue in the current version. | Can be used to display reactions from other characters.                      |
| **Option**   | `[options options=<option1, option2> actions=<1\|1, 2\|-2>/]`                                  | Insert an option dialogue. <br>`options`: List of options, enclosed in `<>` and seperated by `,`. <br>`actions`: List of actions, enclosed in `<>`, seperated by `<>`, in the format of `delay\|option` (confirm the selection by setting option to -2) | Putting it into a single dialogue is recommended.                      |

## ⚙️ Command Line Options

*   **`--fps` (FPS)**:
	*   **Description**: Set the frame count per second.
	*   **Default Value**: `24` (Frequently used  by movies).
	*   **Suggestion**: Usually `24` or `30` would be enough. A high value could cause problems.
*   **`--background` (Background Color)**:
	*   **Description**: Set the background color of the generated video.
	*   **Attention**: If you want to remove the background in external video editors, choose a background color that **doesn't** conflict with the text color (like highly saturated green or blue) is highly recommended.
	*   **`--recording_mode` (Recording Mode)**:
	*   **Description**: How to output the generated video.
		*   **Merge** all dialogues into a long video.
		*   Create **individual** videos for each dialogue.
*   **`--recordings_output_dir` (Output Path)**:
	*   **Description**: Where to put the generated files.
	*   **Default Value**: Usually be your `Videos` directory in your home directory.
*   **`--recording_format` (Generated file format)**:
	*   **Description**: The file format of output files.
	*   **Supported Formats**：
		| Format | File Size | Transparent Background Supported? | Sound supported? | Suitable Situations                     |
		| :--- | :------- | :------------- | :------------- | :--------------------------- |
		| MP4  | Small       | ❌ Not Supported       | ✔️ Supported        | Standard video file format with sounds and small file size     |
		| MOV  | Big       | ✔️ Supported        | ✔️ Supported        | Videos that needs sound and transparent background |
		| GIF  | Small       | ✔️ Supported        | ❌ Supported      | Stickers, no sound. |
*   **`--recording_enable_transparent` (Transparent Background)**:
	*   **Description**: Whether the background is transparent or not.
	*   **Limitation**: The option is **only applicable for MOV and GIF**. It will be ignored when MP4 is chosen.
---

## ⚠️ Tips for Linux users.

Currently we don't provide Linux artifacts, but the project has been ported to Linux (and perhaps macOS but not tested), and can be built by yourself.

You may need to install FFMpeg using your system package manager in order to export animations to files, or you can put a working FFMpeg binary under `external` directory. In most cases, make sure the directory containing `ffmpeg` can be find in your `PATH`.

**START CREATING YOUR DELTARUNE_STYLE ANIMATIONS RIGHT NOW** 🎬✨

