# 미리보기 영상 녹화용 글꼴을 _src\fonts\ 에 모읍니다 (커밋되지 않음).
#  · 구글 폰트 8종 + Creatorlink Sans KR : CSS 를 받아 안의 woff2 를 전부 내려받고, CSS 의 주소를 상대경로로 고쳐 저장
#  · Windows 의 Arial / Arial Bold / Arial Black : 실제 블럭이 윈도우 크롬에서 쓰는 글꼴 (weight 800 → Arial Black)
$ErrorActionPreference = 'Continue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$dir = Join-Path $PSScriptRoot '_src\fonts'
New-Item -ItemType Directory -Force -Path $dir | Out-Null
$UA = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36'

$sheets = @{
  'google'      = 'https://fonts.googleapis.com/css2?family=Instrument+Serif:ital@0;1&family=Playfair+Display:wght@500;700&family=Cormorant+Garamond:wght@400;500;600;700&family=Bebas+Neue&family=JetBrains+Mono:wght@400;500;600&family=Gowun+Batang:wght@400;700&family=Noto+Serif+KR:wght@400;500;600;700&family=Noto+Sans+KR:wght@300;400;500;600;700;800;900&display=swap'
  'creatorlink' = 'https://cdn.jsdelivr.net/gh/creatorlinkapp/fonts@c8576c2c1edb3e042fd6c48649e9d0b61eeb947f/creatorlink-sans-kr.css'
}
$n = 0; $fail = 0
foreach ($k in $sheets.Keys) {
  try { $css = (Invoke-WebRequest -Uri $sheets[$k] -UserAgent $UA -UseBasicParsing -TimeoutSec 60).Content }
  catch { Write-Host "FAIL css $k"; $fail++; continue }
  $base = $sheets[$k].Substring(0, $sheets[$k].LastIndexOf('/') + 1)
  $urls = [regex]::Matches($css, 'url\((["'']?)([^"''\)]+)\1\)') | ForEach-Object { $_.Groups[2].Value } | Select-Object -Unique
  foreach ($u in $urls) {
    $abs = $u; if ($abs -notmatch '^https?://') { $abs = $base + $abs.TrimStart('./') }
    $name = ($abs -split '/')[-1] -replace '\?.*$', ''
    $out = Join-Path $dir $name
    if (-not (Test-Path $out)) {
      try { Invoke-WebRequest -Uri $abs -UserAgent $UA -OutFile $out -UseBasicParsing -TimeoutSec 120; $n++; Write-Host "ok $name" }
      catch { $fail++; Write-Host "FAIL $abs" }
    }
    $css = $css.Replace($u, $name)
  }
  Set-Content -Path (Join-Path $dir "$k.css") -Value $css -Encoding UTF8
}
foreach ($f in 'arial.ttf','arialbd.ttf','ariblk.ttf') {
  $src = Join-Path $env:WINDIR "Fonts\$f"
  if (Test-Path $src) { Copy-Item $src (Join-Path $dir $f) -Force; Write-Host "ok $f (Windows)" } else { Write-Host "없음: $src"; $fail++ }
}
Write-Host "완료: 새로 받은 파일 $n 개, 실패 $fail 개. 이 창을 닫아도 됩니다."
Read-Host '엔터를 누르면 닫힙니다'
