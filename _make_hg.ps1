# 260918 — 나선형 갤러리 2(helixgal) 견본 영상 12편
# 원본을 _src\hg\ 에 받고(.gitignore 처리됨) hg\ 에 540p H.264 mp4 로 인코딩한다.
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
#   -t 8            루프 배경이라 8초면 충분. 용량을 가장 크게 좌우한다(7초짜리 11번은 그대로)
#   -an             muted 재생이므로 오디오 제거
#   scale=-2:540    960×540. 카드가 블럭 폭의 35% 로 보여 이 이상은 낭비
#   crf 30 + 900k   첫 시도 crf 27 은 콘서트 영상(조명·군중)이라 편당 2MB 까지 나왔다(합계 14MB).
#                   상한 900k 를 걸어 편당 1MB 아래로. 카드 크기(블럭 폭 35%)에서는 차이가 안 보인다
#   +faststart      moov 를 앞으로 — 첫 프레임이 빨리 뜬다 (예열의 전제)
#   profile main    구형 기기까지 재생
foreach ($v in $vids) {
  $raw = Join-Path $src "hg-$($v.n).mp4"
  $dst = Join-Path $out "hg-$($v.n).mp4"
  if (-not (Test-Path $raw)) {
    Write-Host "받는 중  hg-$($v.n)"
    Invoke-WebRequest -Uri $v.u -OutFile $raw
  }
  $vf = 'scale=-2:540'
  if ($v.fps) { $vf += ",fps=$($v.fps)" }
  Write-Host "인코딩   hg-$($v.n)"
  & ffmpeg -y -hide_banner -loglevel error -i $raw -t 8 -an `
    -vf $vf -c:v libx264 -profile:v main -preset slow -crf 30 -maxrate 900k -bufsize 1800k -pix_fmt yuv420p `
    -movflags +faststart $dst
}

Write-Host ''
Get-ChildItem $out -Filter 'hg-*.mp4' | Sort-Object Name |
  Select-Object Name, @{ n='KB'; e={ [math]::Round($_.Length / 1KB) } } | Format-Table -AutoSize
Write-Host ("합계 {0} KB" -f [math]::Round(((Get-ChildItem $out -Filter 'hg-*.mp4' | Measure-Object Length -Sum).Sum) / 1KB))
