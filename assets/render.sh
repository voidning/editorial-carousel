#!/usr/bin/env bash
# editorial-carousel / 批量出图
#
# 用法：
#   bash render.sh <版式.html> <输出目录> [页数] [页高] [页间距] [页宽]
#   PAGES=3,9 bash render.sh 版式.html ./out 10      # 只重出第 3、9 页
#
# 原理：所有页纵向排在同一个 HTML 里（每页高 H、页间距 GAP），
# 逐页注入 translateY(-i*(H+GAP)) 后按视口截图。临时文件必须与 HTML 同目录，
# 否则相对路径的图片会加载失败。
set -euo pipefail

CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
HTML="${1:?用法: bash render.sh <版式.html> <输出目录> [页数] [页高] [页间距] [页宽]}"
OUT="${2:?缺少输出目录}"
N="${3:-10}"
H="${4:-1440}"
GAP="${5:-40}"
W="${6:-1080}"
PAGES="${PAGES:-}"          # 例：PAGES=1,3,9 只重出这几页（1-based）

[ -x "$CHROME" ] || { echo "找不到 Chrome：$CHROME" >&2; exit 1; }
DIR="$(cd "$(dirname "$HTML")" && pwd)"
SRC="$(basename "$HTML")"
mkdir -p "$OUT"
OUTABS="$(cd "$OUT" && pwd)"
TMP="$DIR/_shot.html"
trap 'rm -f "$TMP"' EXIT

want() {
  if [ -z "$PAGES" ]; then return 0; fi
  case ",$PAGES," in *",$1,"*) return 0 ;; esac
  return 1
}

fail=0
for ((i=0; i<N; i++)); do
  idx=$((i+1))
  if ! want "$idx"; then continue; fi
  OFF=$((i*(H+GAP)))
  PNG="$OUTABS/$(printf %02d "$idx").png"

  python3 - "$DIR/$SRC" "$TMP" "$OFF" <<'PY'
import sys
src, dst, off = sys.argv[1], sys.argv[2], sys.argv[3]
s = open(src, encoding='utf-8').read()
if '</style>' not in s:
    sys.exit('HTML 里没有 </style>，无法注入位移')
s = s.replace('</style>', 'html{transform:translateY(-%spx);transform-origin:0 0;}\n</style>' % off, 1)
open(dst, 'w', encoding='utf-8').write(s)
PY

  "$CHROME" --headless=new --no-sandbox --disable-gpu --hide-scrollbars \
    --force-device-scale-factor=1 --window-size="$W,$H" \
    --screenshot="$PNG" --virtual-time-budget=3000 "file://$TMP" 2>/dev/null || true

  if [ ! -s "$PNG" ]; then
    echo "⚠️ 第 $idx 页没有生成（检查 Chrome 是否被沙箱拦下）" >&2
    fail=1
  fi
done

if [ "$fail" -ne 0 ]; then exit 1; fi
# 注意：变量后面紧跟中文（多字节）时一定要写 ${VAR}，否则 bash 会把多字节字符当成变量名的一部分
echo "完成：${OUTABS}（$(ls "$OUTABS"/*.png 2>/dev/null | wc -l | tr -d ' ') 张）"
