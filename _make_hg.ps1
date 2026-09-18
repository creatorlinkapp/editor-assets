# 260918 — 나선형 갤러리 2(helixgal) 견본 영상 12편
# 원본을 _src\hg\ 에 받고(.gitignore 처리됨) hg\ 에 H.264 mp4 두 벌로 인코딩한다.
#   hg-NN-sd.mp4  960×540   나선 카드용
#   hg-NN-hd.mp4  1920×1080 확대보기용(클릭할 때만 받는다)
# 세 번째 시도. 첫 벌(hg-NN.mp4 · crf 30 · 900k 상한)은 화질이 부족해 버림 —
# jsDelivr @main 캐시 때문에 같은 이름으로 덮지 않고 새 이름으로 간다. 옛 hg-NN.mp4 12편은 저장소에서 지운다.
# 저장소 루트(editor-assets\)에서 실행:  .\_make_hg.ps1
# 필요: ffmpeg  (없으면  winget install Gyan.FFmpeg  후 터미널 재시작)

$ErrorActionPreference = 'Stop'
$ProgressPreference    = 'SilentlyContinue'   # Invoke-WebRequest 진행바가 큰 파일에서 느리다

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$src  = Join-Path $root '_src\hg'
$out  = Join-Path $root 'hg'
New-Item -ItemType Directory -Force $src, $out | Out-Null

if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) { throw 'ffmpeg 없음 — winget install Gyan.FFmpeg' }

# 원본(1080p). fps 는 60fps 원본만 30 으로 낮춘다 — 나머지는 원본 fps 유지
$vids = @(
  @{ n='01'; u='https://videos.pexels.com/video-files/31540264/13442342_1920_1080_30fps.mp4' }                 # Milan Kiro · 18s
  @{ n='02'; u='https://videos.pexels.com/video-files/28551470/12417619_1920_1080_30fps.mp4' }                 # Sai Sankar Shanmugavelu · 클럽 · 33s
  @{ n='03'; u='https://videos.pexels.com/video-files/31540263/13442363_1920_1080_30fps.mp4' }                 # Milan Kiro · 27s
  @{ n='04'; u='https://videos.pexels.com/video-files/12719510/12719510-hd_1920_1080_60fps.mp4'; fps=30 }      # Gilmer Diaz Estela · 스마트폰 든 관객 · 9s
  @{ n='05'; u='https://videos.pexels.com/video-files/13082773/13082773-hd_1920_1080_60fps.mp4'; fps=30 }      # Gilmer Diaz Estela · 환호하는 관객 · 25s
  @{ n='06'; u='https://videos.pexels.com/video-files/31540267/13442340_1920_1080_30fps.mp4' }                 # Milan Kiro · 11s
  @{ n='07'; u='https://videos.pexels.com/video-files/30805503/13175480_1920_1080_25fps.mp4' }                 # Pietro Henricky · 붉은 조명 · 16s
  @{ n='08'; u='https://videos.pexels.com/video-files/6174198/6174198-hd_1920_1080_30fps.mp4' }                # RDNE Stock project · 관객 · 15s
  @{ n='09'; u='https://videos.pexels.com/video-files/26620363/11976368_1920_1080_30fps.mp4' }                 # Gabrielli Pereira · 록 밴드 · 20s
  @{ n='10'; u='https://videos.pexels.com/video-files/30815459/13179751_1920_1080_25fps.mp4' }                 # Pietro Henricky · 보컬+기타 · 16s
  @{ n='11'; u='https://videos.pexels.com/video-files/31342504/13377149_1920_1080_30fps.mp4' }                 # WeStarMoney Rec · 나이트클럽 · 7s
  @{ n='12'; u='https://videos.pexels.com/video-files/6174235/6174235-hd_1920_1080_30fps.mp4' }                # RDNE Stock project · 록 밴드 · 10s
)

# 인코딩 결정
#   -t 8            루프 배경이라 8초면 충분. 두 벌 모두 같은 구간이라 확대해도 같은 장면이 이어진다
#   -an             muted 재생이므로 오디오 제거
#   sd  540p crf 23 콘서트 영상(조명·군중)은 비트가 많이 든다. 상한을 걸면 뭉개져서 crf 만으로 간다 → 편당 1.5~2.5MB
#   hd 1080p crf 22 확대 칸이 최대 1400px(레티나 2800px)라 1080p 가 필요. jsDelivr 파일당 20MB 제한 안에 두려고 상한 14M
#   +faststart      moov 를 앞으로 — 첫 프레임이 빨리 뜬다 (예열의 전제)
#   profile main/high  sd 는 구형 기기까지, hd 는 high 로 효율 우선
foreach ($v in $vids) {
  $raw = Join-Path $src "hg-$($v.n).mp4"
  $sd  = Join-Path $out "hg-$($v.n)-sd.mp4"
  $hd  = Join-Path $out "hg-$($v.n)-hd.mp4"
  if (-not (Test-Path $raw)) {
    Write-Host "받는 중  hg-$($v.n)"
    Invoke-WebRequest -Uri $v.u -OutFile $raw
  }
  $fps = if ($v.fps) { ",fps=$($v.fps)" } else { '' }
  Write-Host "인코딩   hg-$($v.n)-sd"
  & ffmpeg -y -hide_banner -loglevel error -i $raw -t 8 -an `
    -vf "scale=-2:540$fps" -c:v libx264 -profile:v main -preset slow -crf 23 -pix_fmt yuv420p `
    -movflags +faststart $sd
  Write-Host "인코딩   hg-$($v.n)-hd"
  & ffmpeg -y -hide_banner -loglevel error -i $raw -t 8 -an `
    -vf "scale=-2:1080$fps" -c:v libx264 -profile:v high -preset slow -crf 22 -maxrate 14M -bufsize 28M -pix_fmt yuv420p `
    -movflags +faststart $hd
}

Write-Host ''
$made = Get-ChildItem $out -Filter 'hg-*-?d.mp4' | Sort-Object Name
$made | Select-Object Name, @{ n='KB'; e={ [math]::Round($_.Length / 1KB) } } | Format-Table -AutoSize
Write-Host ("sd 합계 {0} KB" -f [math]::Round((($made | Where-Object Name -like '*-sd.mp4' | Measure-Object Length -Sum).Sum) / 1KB))
Write-Host ("hd 합계 {0} KB" -f [math]::Round((($made | Where-Object Name -like '*-hd.mp4' | Measure-Object Length -Sum).Sum) / 1KB))
$big = $made | Where-Object Length -gt 20MB
if ($big) { Write-Warning ("20MB 초과(jsDelivr 가 안 내보냄): " + ($big.Name -join ', ')) }
