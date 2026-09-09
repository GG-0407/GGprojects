# Generate DesktopClock app icon app.ico (multi-size PNG-in-ICO)
Add-Type -AssemblyName System.Drawing

$accent  = [System.Drawing.Color]::FromArgb(232, 181, 109)
$hand    = [System.Drawing.Color]::FromArgb(245, 245, 245)
$sizes   = @(16, 32, 48, 64, 128, 256)

function New-ClockBitmap([int]$size) {
    $bmp = New-Object System.Drawing.Bitmap($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.Clear([System.Drawing.Color]::Transparent)

    $cx = $size / 2.0
    $cy = $size / 2.0
    $r  = $size * 0.46
    $ringW = [Math]::Max(1.2, $size * 0.075)

    $ringPen = New-Object System.Drawing.Pen($accent, $ringW)
    $g.DrawEllipse($ringPen, [float]($cx - $r), [float]($cy - $r), [float](2 * $r), [float](2 * $r))

    function Hand([float]$deg, [float]$len, [float]$w) {
        $rad = ($deg - 90) * [Math]::PI / 180.0
        $ex = $cx + $len * [Math]::Cos($rad)
        $ey = $cy + $len * [Math]::Sin($rad)
        $pen = New-Object System.Drawing.Pen($hand, [float]$w)
        $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
        $pen.EndCap   = [System.Drawing.Drawing2D.LineCap]::Round
        $g.DrawLine($pen, [float]$cx, [float]$cy, [float]$ex, [float]$ey)
        $pen.Dispose()
    }
    Hand 60  ($r * 0.58) ([Math]::Max(1.0, $size * 0.055))
    Hand -60 ($r * 0.40) ([Math]::Max(1.0, $size * 0.065))

    $dotR = [Math]::Max(0.9, $size * 0.06)
    $dotBrush = New-Object System.Drawing.SolidBrush($accent)
    $g.FillEllipse($dotBrush, [float]($cx - $dotR), [float]($cy - $dotR), [float](2 * $dotR), [float](2 * $dotR))

    $dotBrush.Dispose(); $ringPen.Dispose(); $g.Dispose()
    return $bmp
}

$pngs = @{}
foreach ($size in $sizes) {
    $bmp = New-ClockBitmap $size
    $ms = New-Object System.IO.MemoryStream
    $bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
    $pngs[$size] = $ms.ToArray()
    $ms.Dispose(); $bmp.Dispose()
}

$count = $sizes.Count
$out = New-Object System.IO.MemoryStream
$bw = New-Object System.IO.BinaryWriter($out)
$bw.Write([uint16]0)
$bw.Write([uint16]1)
$bw.Write([uint16]$count)

$offsets = @()
$offset = 6 + 16 * $count
foreach ($size in $sizes) {
    $offsets += $offset
    $dataLen = $pngs[$size].Length
    $offset += $dataLen
}

for ($i = 0; $i -lt $count; $i++) {
    $size = $sizes[$i]
    $w = if ($size -ge 256) { 0 } else { $size }
    $h = if ($size -ge 256) { 0 } else { $size }
    $bw.Write([byte]$w)
    $bw.Write([byte]$h)
    $bw.Write([byte]0)
    $bw.Write([byte]0)
    $bw.Write([uint16]1)
    $bw.Write([uint16]32)
    $bw.Write([uint32]$pngs[$size].Length)
    $bw.Write([uint32]$offsets[$i])
}
foreach ($size in $sizes) {
    $bw.Write($pngs[$size])
}
$bw.Flush()

$icoPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'app.ico'
[System.IO.File]::WriteAllBytes($icoPath, $out.ToArray())
$bw.Dispose(); $out.Dispose()

Write-Output ("Generated: {0}  ({1} bytes, {2} sizes)" -f $icoPath, (Get-Item $icoPath).Length, $count)
