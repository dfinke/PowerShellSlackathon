param(
    $q,
    [Switch]$Raw
)

$q

$url = "http://api.wolframalpha.com/v2/query?input=$q&appid=$($WolframAlpahApiKey)"
$r=(Invoke-RestMethod $url).queryresult

    if($r.success -eq 'false') {
        Write-Error $r.error.msg
        return
    }

    if($Raw) {
        $r
    } else {
        $r.pod |
            ? {$_.title -match 'result|Approximate result|total|response'} |
            % subpod |
            % plaintext

        ''
    }