param($word)

$alphabet = 'abcdefghijklmnopqrstuvwxyz'

function deletion {
  (0..($word.Length-1)) |
    ForEach {
      @($word.Substring(0,$_) + $word.Substring($_+1))
    }
}

function transposition {
  @((0..($word.Length-2)) |
    ForEach {
		$word.Substring(0, $_) + $word[$_+1] + $word[$_] + $word.Substring($_+2)
	})
}

function alteration {
	ForEach($i in (0..($word.Length - 1)) ) {
		ForEach($c in $alphabet.GetEnumerator()) {
			@($word.substring(0,$i)+$c+$word.substring($i+1))
		}
	}
}

function insertion {
	$n = $word.Length
	ForEach($i in (0..(($n - 1) + 1))) {
		$alphabet.GetEnumerator() |
		ForEach {
			@($word.substring(0,$i)+$_+$word.substring($i))
		}
	}
}

function train($text) {
	$h = @{}

	$text  = $text -join " "
	$split = [regex]::split($text.ToLower(), '\W+')
    $split | % {$h[$_] = ''}

	$h
}

if(!(Test-Path "holmes.JustWords.txt") ) {
	Write-Progress "Caching" -status " training"
	$nwords = (train (Get-Content "holmes.txt")).psbase.Keys | sort
	$nwords | Set-Content -Encoding Ascii "holmes.JustWords.txt"
} else {
	$nwords = [System.IO.File]::ReadAllLines("$pwd\holmes.JustWords.txt")
}

echo (deletion) (transposition) (alteration) (insertion) |
	ForEach {
		$nwords -eq $_
	} | sort -Unique