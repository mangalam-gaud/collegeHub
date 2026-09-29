$ErrorActionPreference = 'Stop'
$base = 'http://localhost:8080/CollegeApp'
$s = New-Object Microsoft.PowerShell.Commands.WebRequestSession

# 1. GET login page -> extract CSRF token
$p = Invoke-WebRequest -Uri "$base/login" -WebSession $s -UseBasicParsing
$m = [regex]::Match($p.Content, 'name="csrf" value="([^"]+)"')
$tok = $m.Groups[1].Value
Write-Host "1. LOGIN PAGE OK (status $($p.StatusCode)), CSRF token found: $($tok.Length -gt 10)"

# 2. POST login with admin/admin123
$r = Invoke-WebRequest -Uri "$base/login" -Method Post -WebSession $s -UseBasicParsing -Body @{username='admin';password='admin123';csrf=$tok}
Write-Host "2. LOGIN POST OK -> landed on dashboard: $($r.Content.Contains('sidebar')) / has logout: $($r.Content.Contains('/logout'))"

# 3. Visit admin pages
foreach ($page in 'dashboard','users','courses','notices') {
    $resp = Invoke-WebRequest -Uri "$base/admin/$page" -WebSession $s -UseBasicParsing
    Write-Host "3. /admin/$page -> $($resp.StatusCode)"
}

# 4. RBAC: student URL as admin should still work (admin pass-all); check student dashboard
$resp = Invoke-WebRequest -Uri "$base/student/dashboard" -WebSession $s -UseBasicParsing
Write-Host "4. /student/dashboard as admin -> $($resp.StatusCode)"

# 5. CSRF protection: POST without token must be 403
try {
    Invoke-WebRequest -Uri "$base/admin/notice-post" -Method Post -WebSession $s -UseBasicParsing -Body @{title='x';body='y'} | Out-Null
    Write-Host "5. POST without CSRF: NOT BLOCKED (BAD)"
} catch {
    Write-Host "5. POST without CSRF blocked with: $($_.Exception.Response.StatusCode.value__)"
}

# 6. Unauthenticated access redirects to login
try {
    Invoke-WebRequest -Uri "$base/admin/users" -UseBasicParsing -MaximumRedirection 0 | Out-Null
    Write-Host "6. Unauth access: NOT redirected (BAD)"
} catch {
    Write-Host "6. Unauth access redirect status: $($_.Exception.Response.StatusCode.value__) (302 = OK)"
}

# 7. Wrong password shows error
$s2 = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$p2 = Invoke-WebRequest -Uri "$base/login" -WebSession $s2 -UseBasicParsing
$t2 = [regex]::Match($p2.Content, 'name="csrf" value="([^"]+)"').Groups[1].Value
$bad = Invoke-WebRequest -Uri "$base/login" -Method Post -WebSession $s2 -UseBasicParsing -Body @{username='admin';password='wrong';csrf=$t2}
Write-Host "7. Wrong password -> error shown: $($bad.Content.Contains('Invalid username'))"

Write-Host "ALL SMOKE TESTS DONE"
