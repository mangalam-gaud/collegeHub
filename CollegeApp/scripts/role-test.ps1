$ErrorActionPreference = 'Stop'
$base = 'http://localhost:8080/CollegeApp'
$s = New-Object Microsoft.PowerShell.Commands.WebRequestSession

# login as admin
$p = Invoke-WebRequest -Uri "$base/login" -WebSession $s -UseBasicParsing
$tok = [regex]::Match($p.Content, 'name="csrf" value="([^"]+)"').Groups[1].Value
Invoke-WebRequest -Uri "$base/login" -Method Post -WebSession $s -UseBasicParsing -Body @{username='admin';password='admin123';csrf=$tok} | Out-Null

# create teacher1
$p2 = Invoke-WebRequest -Uri "$base/admin/user-form?role=TEACHER" -WebSession $s -UseBasicParsing
$tok2 = [regex]::Match($p2.Content, 'name="csrf" value="([^"]+)"').Groups[1].Value
Invoke-WebRequest -Uri "$base/admin/user-save" -Method Post -WebSession $s -UseBasicParsing -Body @{
    role='TEACHER'; username='teacher1'; fullName='Demo Teacher'; email='teacher1@college.edu';
    password='teach123'; phone='1234567890'; gender='Male'; dob='1990-01-01'; address='Campus'; csrf=$tok2} | Out-Null

# create student1
Invoke-WebRequest -Uri "$base/admin/user-save" -Method Post -WebSession $s -UseBasicParsing -Body @{
    role='STUDENT'; username='student1'; fullName='Demo Student'; email='student1@college.edu';
    password='stud123'; phone='0987654321'; gender='Female'; dob='2003-05-05'; address='Hostel'; csrf=$tok2} | Out-Null

Write-Host "Created demo users."

    $s = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $p = Invoke-WebRequest -Uri "$base/login" -WebSession $s -UseBasicParsing
    $tok = [regex]::Match($p.Content, 'name="csrf" value="([^"]+)"').Groups[1].Value
    $r = Invoke-WebRequest -Uri "$base/login" -Method Post -WebSession $s -UseBasicParsing -Body @{username=$user;password=$pass;csrf=$tok}
    $roleChip = if ($r.Content -match 'class="role">([A-Z]+)<') { $Matches[1] } else { 'NONE' }
    $sidebarAdmin = $r.Content.Contains('/admin/dashboard')
    $sidebarTeacher = $r.Content.Contains('/teacher/courses')
    $sidebarStudent = $r.Content.Contains('/student/attendance')
    Write-Host "$user -> role-chip=$roleChip adminNav=$sidebarAdmin teacherNav=$sidebarTeacher studentNav=$sidebarStudent"
}

Test-Login 'admin' 'admin123'
Test-Login 'teacher1' 'teach123'
Test-Login 'student1' 'stud123'
