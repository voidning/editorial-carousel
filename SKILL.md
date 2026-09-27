---
name: editorial-carousel
description: 把一篇文章、一份拆解、一段资料做成「人文编辑风」的小红书图文组图——HTML/CSS 排版 + 本机无头 Chrome 逐页出图，并配一份可直接粘贴的纯文本发布文案。当用户说「做成小红书图文笔记」「把这篇文章排成一组图」「杂志内页感 / 编辑风 / 人文感」「拆解做成组图」，或给一个已经有自己视觉语言的网页要求转成组图时使用。视频需求改用 html-animation-to-video；纯图形、清单、机制示意类改用 minimal-content-kit。
agent_created: true
---

# editorial-carousel（编辑风小红书组图）

用 HTML/CSS 排好版，再用无头 Chrome 逐页截图成 1080×1440 的组图。
视觉语言是杂志内页式的：羊皮纸底、衬线标题、细规线、图注、栏头、页码、大留白。
适合文字量偏多的内容——长文拆解、资料整理、设计分析；不适合纯图形示意。

## 每期流程

1. **定结论与页序**。先写出一句话结论（能直接当封面副标题），
   再按 [页型库](references/layout-rules.md) 排出页序与每页一句话。页数 8–12 张。
2. **落版**。复制 [base.html](assets/base.html) 到工作目录，删掉不用的页型，填内容与图片。
   图片一律先压到 1080–1600 宽再放进 `assets/`。
3. **出图**。`bash <skill 目录>/assets/render.sh 版式.html ./out 页数`。
   改单页后只重出受影响页：`PAGES=3,9 bash ... render.sh 版式.html ./out 10`。
4. **自检**。按下面的命令生成缩略图逐页看，重点查溢出、裁切、断行、中部空洞。
5. **文案**。按 [发布规范](references/publishing.md) 出纯文本标题与正文。

```bash
# 自检缩略图（读图不要读原图，10 张一起看也不炸 context）
for f in out/*.png; do sips -s format jpeg -s formatOptions 74 --resampleWidth 620 "$f" \
  --out "/tmp/preview-$(basename "$f" .png).jpg"; done
```

## 硬规则（都踩过）

- **无头截图必须加 `--no-sandbox`**。不加时 Chrome 自己的 GPU/网络子进程被外层拦掉，
  **截图静默不生成**（退出码 0、输出目录空），极易误判成路径写错。`render.sh` 已带上。
- **正文不要低于 26 px**（1080 宽基准）。20 px 在手机上只剩 7 pt 左右。
  字号一加大必然溢出，必须逐页重看并相应减字或拆页——不要靠缩字把内容塞进一页。
  完整字号基准见 references/layout-rules.md。
- **含中文的元素不能设 mono**。`SF Mono` 一类没有 CJK 字形，中文要靠字体栈回退；
  中文标签统一加 `.zh` 类切回 sans。
- **有原始比例的图别设固定高度**，会裁掉内容。用 `.media` 包裹让它在剩余空间里居中。
- **页面不要出现"中部空洞"**：文字在上、图片用 `margin-top:auto` 顶到底，中间会空 250 px 以上。
  图片页用 `.media`（`flex:1` + `justify-content:center`），文字页用 `.note` 贴底收束。
- **正文纯文本**：小红书不解析 markdown，交付文案里不要出现 `**`、`>`、`-`。
- **不要手动给出图文件改名**。`render.sh` 输出的是 `0X.png`，改了名之后下次重出会生成新的
  `0X.png`，与改名后的旧文件同时存在 —— 很容易把旧图当新图交付（首期就踩过：封面那批改过名，
  重出后交付的仍是旧文件）。要语义化命名就改脚本里的 `printf` 格式，
  或者统一在最终交付前批量改一次，并确认目录里没有重复的 `0X.png`。
- 交付顺序：先出图给用户看，再给文案；不要先写文案。

## 资源

- [assets/base.html](assets/base.html) —— 可直接改的版式骨架，含全部 CSS 与 9 种页型示例
- [assets/render.sh](assets/render.sh) —— 批量出图（支持只重出指定页）
- [references/layout-rules.md](references/layout-rules.md) —— 字号基准、页型库、留白与断行处理
- [references/publishing.md](references/publishing.md) —— 图片规格、文案规范、合集与发布后修改的边界
