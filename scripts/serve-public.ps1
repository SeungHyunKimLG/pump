param(
  [int]$Port = 5173
)

$Root = (Resolve-Path (Join-Path $PSScriptRoot "..\public")).Path.TrimEnd("\")
$Listener = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback, $Port)
$Listener.Start()

Write-Host "Serving $Root at http://localhost:$Port/"

function Write-Response {
  param(
    [Net.Sockets.NetworkStream]$Stream,
    [int]$StatusCode,
    [string]$StatusText,
    [string]$ContentType,
    [byte[]]$Body
  )

  $Header = "HTTP/1.1 $StatusCode $StatusText`r`nContent-Type: $ContentType`r`nContent-Length: $($Body.Length)`r`nCache-Control: no-cache`r`nConnection: close`r`n`r`n"
  $HeaderBytes = [Text.Encoding]::ASCII.GetBytes($Header)
  $Stream.Write($HeaderBytes, 0, $HeaderBytes.Length)
  $Stream.Write($Body, 0, $Body.Length)
}

try {
  while ($true) {
    $Client = $Listener.AcceptTcpClient()

    try {
      $Stream = $Client.GetStream()
      $Reader = [IO.StreamReader]::new($Stream, [Text.Encoding]::ASCII, $false, 1024, $true)
      $RequestLine = $Reader.ReadLine()

      do {
        $HeaderLine = $Reader.ReadLine()
      } while ($null -ne $HeaderLine -and $HeaderLine.Length -gt 0)

      if ([string]::IsNullOrWhiteSpace($RequestLine)) {
        $Body = [Text.Encoding]::UTF8.GetBytes("Bad request")
        Write-Response $Stream 400 "Bad Request" "text/plain; charset=utf-8" $Body
        continue
      }

      $Target = ($RequestLine -split " ")[1]
      $Uri = [Uri]::new("http://localhost$Target")
      $RequestPath = [Uri]::UnescapeDataString($Uri.AbsolutePath.TrimStart("/"))

      if ([string]::IsNullOrWhiteSpace($RequestPath)) {
        $RequestPath = "index.html"
      }

      $Candidate = Join-Path $Root $RequestPath
      $Resolved = $null

      if (Test-Path -LiteralPath $Candidate -PathType Leaf) {
        $Resolved = (Resolve-Path -LiteralPath $Candidate).Path
      }

      if ($null -eq $Resolved -or -not $Resolved.StartsWith($Root, [StringComparison]::OrdinalIgnoreCase)) {
        $Body = [Text.Encoding]::UTF8.GetBytes("Not found")
        Write-Response $Stream 404 "Not Found" "text/plain; charset=utf-8" $Body
        continue
      }

      $Extension = [IO.Path]::GetExtension($Resolved).ToLowerInvariant()
      $ContentType = switch ($Extension) {
        ".html" { "text/html; charset=utf-8" }
        ".js" { "text/javascript; charset=utf-8" }
        ".css" { "text/css; charset=utf-8" }
        ".json" { "application/json; charset=utf-8" }
        default { "application/octet-stream" }
      }

      $Body = [IO.File]::ReadAllBytes($Resolved)
      Write-Response $Stream 200 "OK" $ContentType $Body
    }
    catch {
      if ($null -ne $Stream) {
        $Body = [Text.Encoding]::UTF8.GetBytes("Internal server error")
        Write-Response $Stream 500 "Internal Server Error" "text/plain; charset=utf-8" $Body
      }
    }
    finally {
      $Client.Close()
    }
  }
}
finally {
  $Listener.Stop()
}
