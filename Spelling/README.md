# Spelling Corrector

A port of this python implementation http://norvig.com/spell-correct.html

Try:

* `.\spelling.ps1 speling`
* `.\spelling.ps1 trin`


1. Reads holmes.txt, pulls out all words ~100K and puts them in a hash table. If this is the first time running it, it will use the PowerShell function `Export-Clixml` to store the hashtable so next time it is sub second response.
1.  An edit can be a deletion (remove one letter), a transposition (swap adjacent letters), an alteration (change one letter to another) or an insertion (add a letter).

Here's the line that returns a set of all words *c* that are one edit away from *w*.

`$theSet += (deletion) + (transposition) + (alteration) + (insertion)`