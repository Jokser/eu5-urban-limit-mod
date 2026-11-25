Add-Type -AssemblyName System.Drawing
$out = Join-Path (Split-Path -Parent $PSScriptRoot) '.metadata	humbnail.png'
$S = 512
$bmp = New-Object System.Drawing.Bitmap($S, $S)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = 'AntiAlias'; $g.TextRenderingHint = 'AntiAliasGridFit'; $g.InterpolationMode = 'HighQualityBicubic'

function C($a, $r, $gg, $b) { [System.Drawing.Color]::FromArgb($a, $r, $gg, $b) }
function P([double]$x, [double]$y) { [System.Drawing.PointF]::new([single]$x, [single]$y) }
$ink    = C 255 58 40 24
$inkSoft= C 140 58 40 24

# --- parchment background with radial vignette ---
$rect = New-Object System.Drawing.Rectangle(0, 0, $S, $S)
$bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, (C 255 238 222 182), (C 255 214 190 140), 60)
$g.FillRectangle($bg, $rect)
$path = New-Object System.Drawing.Drawing2D.GraphicsPath
$path.AddEllipse(-200, -200, $S + 400, $S + 400)
$vig = New-Object System.Drawing.Drawing2D.PathGradientBrush($path)
$vig.CenterColor = C 0 120 80 30
$vig.SurroundColors = @(C 150 110 70 30)
$g.FillRectangle($vig, $rect)
# paper speckle
$rnd = New-Object System.Random(1337)
for ($i = 0; $i -lt 2600; $i++) {
    $x = $rnd.Next(0, $S); $y = $rnd.Next(0, $S); $a = $rnd.Next(6, 26)
    $g.FillRectangle((New-Object System.Drawing.SolidBrush (C $a 90 60 25)), $x, $y, 2, 2)
}

# --- map area ---
$mx = 56; $my = 150; $mw = 400; $mh = 300
# fields (soft green patches)
$field = New-Object System.Drawing.SolidBrush (C 70 120 140 60)
foreach ($p in @(@(80,330,120,70), @(300,300,130,80), @(110,220,90,55), @(330,395,95,45), @(205,400,85,40))) {
    $g.FillEllipse($field, $p[0], $p[1], $p[2], $p[3])
}
# field furrows
$fpen = New-Object System.Drawing.Pen((C 90 95 110 50), 1.2)
for ($k = 0; $k -lt 6; $k++) { $g.DrawLine($fpen, 95 + $k*15, 345, 115 + $k*15, 390) }
for ($k = 0; $k -lt 6; $k++) { $g.DrawLine($fpen, 315 + $k*16, 318, 330 + $k*16, 368) }

# forest (small tree marks)
$tree = New-Object System.Drawing.SolidBrush (C 150 70 95 50)
foreach ($t in @(@(395,215),@(410,230),@(425,212),@(440,232),@(388,240),@(418,250),@(80,410),@(96,425),@(70,430))) {
    $pts = [System.Drawing.PointF[]]@((P ($t[0]) ($t[1]-12)), (P ($t[0]-7) ($t[1]+4)), (P ($t[0]+7) ($t[1]+4)))
    $g.FillPolygon($tree, $pts)
}

# mountains (left, stay empty)
$mpen = New-Object System.Drawing.Pen($ink, 2.2)
$mfill = New-Object System.Drawing.SolidBrush (C 60 120 90 50)
foreach ($m in @(@(70,280,38),@(108,272,46),@(150,286,34))) {
    $pts = [System.Drawing.PointF[]]@((P ($m[0]-$m[2]) ($m[1])), (P ($m[0]) ($m[1]-$m[2]*1.1)), (P ($m[0]+$m[2]) ($m[1])))
    $g.FillPolygon($mfill, $pts); $g.DrawLines($mpen, $pts)
    $g.DrawLine((New-Object System.Drawing.Pen($inkSoft, 1.2)), $m[0], $m[1]-$m[2]*1.1, $m[0]+$m[2]*0.35, $m[1]-$m[2]*0.2)
}

# river (blue curve through the valley)
$rpen = New-Object System.Drawing.Pen((C 200 70 110 150), 7); $rpen.StartCap = 'Round'; $rpen.EndCap = 'Round'
$river = [System.Drawing.PointF[]]@(
  (P (470) (190)), (P (400) (285)),
  (P (300) (290)), (P (250) (345)),
  (P (180) (380)), (P (120) (460)))
$g.DrawCurve($rpen, $river, 0.5)
$g.DrawCurve((New-Object System.Drawing.Pen((C 120 220 235 245), 2)), $river, 0.5)

# dashed province border
$bpen = New-Object System.Drawing.Pen($inkSoft, 2); $bpen.DashPattern = @(6, 4)
$g.DrawClosedCurve($bpen, [System.Drawing.PointF[]]@(
  (P (190) (200)), (P (330) (205)),
  (P (390) (300)), (P (330) (415)),
  (P (200) (420)), (P (165) (315))), 0.5, [System.Drawing.Drawing2D.FillMode]::Alternate)

# --- city (walled, towers) at the river ---
function Draw-City($cx, $cy, $sc) {
    $wall = New-Object System.Drawing.SolidBrush (C 255 196 160 110)
    $pen = New-Object System.Drawing.Pen($ink, 2.4 * $sc)
    $g.FillEllipse($wall, $cx - 44*$sc, $cy - 16*$sc, 88*$sc, 40*$sc)
    $g.DrawEllipse($pen, $cx - 44*$sc, $cy - 16*$sc, 88*$sc, 40*$sc)
    $roof = New-Object System.Drawing.SolidBrush (C 255 150 62 40)
    $body = New-Object System.Drawing.SolidBrush (C 255 226 205 160)
    foreach ($b in @(@(-30,-2,14,18),@(-14,-10,14,24),@(4,-22,14,36),@(20,-8,14,22))) {
        $bx = $cx + $b[0]*$sc; $by = $cy + $b[1]*$sc; $bw = $b[2]*$sc; $bh = $b[3]*$sc
        $g.FillRectangle($body, $bx, $by, $bw, $bh); $g.DrawRectangle($pen, $bx, $by, $bw, $bh)
        $pts = [System.Drawing.PointF[]]@((P ($bx - 2*$sc) ($by)), (P ($bx + $bw/2) ($by - 12*$sc)), (P ($bx + $bw + 2*$sc) ($by)))
        $g.FillPolygon($roof, $pts); $g.DrawPolygon($pen, $pts)
    }
    # banner on the tallest tower
    $g.DrawLine($pen, $cx + 11*$sc, $cy - 34*$sc, $cx + 11*$sc, $cy - 46*$sc)
    $g.FillPolygon($roof, [System.Drawing.PointF[]]@((P ($cx + 11*$sc) ($cy - 46*$sc)), (P ($cx + 22*$sc) ($cy - 42*$sc)), (P ($cx + 11*$sc) ($cy - 38*$sc))))
}
# --- town (two houses) ---
function Draw-Town($cx, $cy, $sc) {
    $pen = New-Object System.Drawing.Pen($ink, 2 * $sc)
    $roof = New-Object System.Drawing.SolidBrush (C 255 150 62 40)
    $body = New-Object System.Drawing.SolidBrush (C 255 226 205 160)
    foreach ($b in @(@(-14,0,13,13),@(2,-4,14,17))) {
        $bx = $cx + $b[0]*$sc; $by = $cy + $b[1]*$sc; $bw = $b[2]*$sc; $bh = $b[3]*$sc
        $g.FillRectangle($body, $bx, $by, $bw, $bh); $g.DrawRectangle($pen, $bx, $by, $bw, $bh)
        $pts = [System.Drawing.PointF[]]@((P ($bx - 2*$sc) ($by)), (P ($bx + $bw/2) ($by - 9*$sc)), (P ($bx + $bw + 2*$sc) ($by)))
        $g.FillPolygon($roof, $pts); $g.DrawPolygon($pen, $pts)
    }
}
Draw-City 268 312 1.25
Draw-Town 205 395 1.1
Draw-Town 352 250 1.0

# --- compass rose (bottom right) ---
$cxr = 438; $cyr = 418
$cp = New-Object System.Drawing.Pen($ink, 1.6)
$g.DrawEllipse($cp, $cxr - 26, $cyr - 26, 52, 52)
$dark = New-Object System.Drawing.SolidBrush $ink
$light = New-Object System.Drawing.SolidBrush (C 255 226 205 160)
foreach ($d in @(@(0,-1),@(1,0),@(0,1),@(-1,0))) {
    $tip = P ($cxr + $d[0]*34) ($cyr + $d[1]*34)
    $l = P ($cxr - $d[1]*6) ($cyr + $d[0]*6)
    $r = P ($cxr + $d[1]*6) ($cyr - $d[0]*6)
    $c0 = P ($cxr) ($cyr)
    $g.FillPolygon($dark, [System.Drawing.PointF[]]@($tip, $l, $c0)); $g.FillPolygon($light, [System.Drawing.PointF[]]@($tip, $r, $c0))
    $g.DrawPolygon($cp, [System.Drawing.PointF[]]@($tip, $l, $c0, $r))
}

# --- frame: double border ---
$g.DrawRectangle((New-Object System.Drawing.Pen($ink, 6)), 14, 14, $S - 28, $S - 28)
$g.DrawRectangle((New-Object System.Drawing.Pen($ink, 1.5)), 26, 26, $S - 52, $S - 52)

# --- title ---
$fam = 'Book Antiqua'
try { $null = New-Object System.Drawing.FontFamily($fam) } catch { $fam = 'Georgia' }
$sf = New-Object System.Drawing.StringFormat; $sf.Alignment = 'Center'
$f1 = New-Object System.Drawing.Font($fam, 50, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$f2 = New-Object System.Drawing.Font($fam, 30, [System.Drawing.FontStyle]::Italic, [System.Drawing.GraphicsUnit]::Pixel)
$shadow = New-Object System.Drawing.SolidBrush (C 90 255 245 220)
$g.DrawString('Urban Limit', $f1, $shadow, (New-Object System.Drawing.RectangleF(2, 44, $S, 60)), $sf)
$g.DrawString('Urban Limit', $f1, $dark, (New-Object System.Drawing.RectangleF(0, 42, $S, 60)), $sf)
$g.DrawString('Reworked', $f2, (New-Object System.Drawing.SolidBrush (C 255 150 62 40)), (New-Object System.Drawing.RectangleF(0, 100, $S, 40)), $sf)
# ornament line under the title
$g.DrawLine((New-Object System.Drawing.Pen($ink, 1.5)), 150, 142, 362, 142)
$g.FillEllipse($dark, 252, 138, 8, 8)

$g.Dispose()
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Host "saved $out"
