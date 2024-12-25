$word = NEW-OBJECT -COMOBJECT WORD.APPLICATION

Write-Host "[docx2pdf.ps1]"
$files = Get-ChildItem | Where-Object{ $_.Name -match "docx$" }
Write-Host "[start]"
foreach ($file in $files)
{
    try
    {
        $result = (Test-Path $file.FullName.Replace(".docx", ".pdf"))
        if ($result)
        {
            Write-Host "$( $file.Name ) ... skip"
        }
        else
        {
            Write-Host "$( $file.Name ) ... converting"
            $doc = $word.Documents.OpenNoRepairDialog($file.FullName)
            foreach ($pp in $doc.InlineShapes)
            {
                $pp.LockAspectRatio = $true
            }
            $doc.Save()
            $doc.SaveAs([ref] $file.FullName.Replace(".docx", ".pdf"), [ref]17)
            $doc.Close()
            Write-Host "$($file.FullName.Replace(".docx", ".pdf") ) ... done"
        }
    }
    catch
    {
        Write-Host "[ERROR]$( $file.Name ) ... failed"
    }
}
Write-Host "[done]"
#Pause
$word.Quit()
