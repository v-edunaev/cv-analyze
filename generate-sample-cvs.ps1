# Script to generate sample CV files in PDF and DOCX format

Write-Host "Generating sample CV files..." -ForegroundColor Cyan

# Read the text CV content
$cvContent = Get-Content "test-data\valid-cv-sample.txt" -Raw

# Generate DOCX file
Write-Host "Generating DOCX file..." -ForegroundColor Yellow

$word = New-Object -ComObject Word.Application
$word.Visible = $false
$doc = $word.Documents.Add()

$selection = $word.Selection

# Add content
$selection.TypeText($cvContent)

# Format
$selection.WholeStory()
$selection.Font.Name = "Calibri"
$selection.Font.Size = 11

# Save as DOCX
$docxPath = (Resolve-Path ".\test-data").Path + "\valid-cv-sample.docx"
$doc.SaveAs([ref]$docxPath, [ref]16) # 16 = wdFormatDocumentDefault (docx)
$doc.Close()

Write-Host "✓ Created: $docxPath" -ForegroundColor Green

# Generate PDF file
Write-Host "Generating PDF file..." -ForegroundColor Yellow

$doc2 = $word.Documents.Open($docxPath)
$pdfPath = (Resolve-Path ".\test-data").Path + "\valid-cv-sample.pdf"
$doc2.SaveAs([ref]$pdfPath, [ref]17) # 17 = wdFormatPDF
$doc2.Close()

Write-Host "✓ Created: $pdfPath" -ForegroundColor Green

# Generate invalid DOCX (corrupted)
Write-Host "Generating invalid DOCX..." -ForegroundColor Yellow
$invalidDocxPath = (Resolve-Path ".\test-data").Path + "\invalid-cv-corrupted.docx"
"PK" + [char]0x03 + [char]0x04 + "CORRUPTED" | Out-File -FilePath $invalidDocxPath -Encoding ASCII -NoNewline
Write-Host "✓ Created: $invalidDocxPath" -ForegroundColor Green

# Quit Word
$word.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($word) | Out-Null

Write-Host ""
Write-Host "Sample CV generation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Generated files:" -ForegroundColor Yellow
Write-Host "  - valid-cv-sample.txt" -ForegroundColor White
Write-Host "  - valid-cv-sample.docx" -ForegroundColor White
Write-Host "  - valid-cv-sample.pdf" -ForegroundColor White
Write-Host "  - invalid-cv-empty.txt" -ForegroundColor White
Write-Host "  - invalid-cv-too-short.txt" -ForegroundColor White
Write-Host "  - invalid-cv-corrupted.txt" -ForegroundColor White
Write-Host "  - invalid-cv-corrupted.docx" -ForegroundColor White
Write-Host ""
