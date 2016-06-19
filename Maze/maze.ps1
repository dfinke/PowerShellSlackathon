param($Rows=8, $Columns=8)

Add-Type -AssemblyName System.Drawing

class Cell {

    [int]$Row
    [int]$Col

    $links = @{}

    [Cell]$North
    [Cell]$East
    [Cell]$South
    [Cell]$West

    Hidden [Cell[]] $TheNeighbors

    Cell([int]$Row, [int]$Col){
        $this.Row=$Row
        $this.Col=$Col
    }

    Link([Cell]$Cell,$bidi) {
        $this.links[$Cell] = $true
        if($bidi) {
            $Cell.Link($this, $false)
        }
    }

    UnLink([Cell]$Cell, $bidi) {
        $this.links.Remove($Cell)

        if($bidi) { $Cell.UnLink($this, $false) }
    }

    ClearNeighbors() { $this.TheNeighbors = @() }

    [Cell[]] Neighbors() {
        if($this.TheNeighbors.Count -eq 0) {
            $this.TheNeighbors = $this.North, $this.South, $this.West, $this.East
        }
        return $this.TheNeighbors
    }

    [bool] IsLinked ([Cell]$cell) {
        if($cell -eq $null) {return $false}
        return $this.links.ContainsKey($cell)
    }

    [object] GetLinks()  { return $this.links.keys }
    [string] ToString()  { return "[R{0}][C{1}]" -f $this.Row, $this.Col }
}

class Grid {
    [int]$NumberOfRows
    [int]$NumberOfColumns
    [object]$Cells

    Grid([int]$NumberOfRows, [int]$NumberOfColumns){
        $this.NumberOfRows = $NumberOfRows
        $this.NumberOfColumns = $NumberOfColumns
        $this.ConfigureCells()
    }

    [int] Size() { return $this.NumberOfRows*$this.NumberOfColumns}

    [Cell] RandomCell() {

        $row = Get-Random -Minimum 0 -Maximum ($this.NumberOfRows-1)
        $column = Get-Random -Minimum 0 -Maximum ($this.NumberOfColumns-1)

        return $this.Cells[$row,$column]
    }

    Hidden ConfigureCells(){
        $this.Cells = New-Object 'object[,]' $this.NumberOfRows,$this.NumberOfColumns

        for ($row = 0; $row -lt $this.NumberOfRows; $row++)
        {
            for ($col = 0; $col -lt $this.NumberOfColumns; $col++)
            {
               $this.Cells[$row,$col]=[Cell]::new($row, $col)
            }
        }

        foreach ($cell in $this.Cells) {
            $row, $col= $cell.row, $cell.Col

            $cell.North = $this.Cells[($row-1), $col]
            $cell.South = $this.Cells[($row+1), $col]
            $cell.West  = $this.Cells[$row, ($col-1)]
            $cell.East  = $this.Cells[$row, ($col+1)]
        }
    }


    [string] DisplayMaze() {

        $output = "+" + ("---+" * ($this.NumberOfColumns-1)) + "`n"

        for ($r = 0; $r -lt $this.NumberOfRows; $r++) {
            $top    = "|"
            $bottom = "+"

            for ($c = 1; $c -lt $this.NumberOfColumns; $c++) {

                [Cell]$cell = $this.Cells[$r,$c]

                $body = "   "

                $eastBoundary = "|"
                if($cell.East -And $cell.IsLinked($cell.East)) { $eastBoundary = " " }

                $top += $body+$eastBoundary

                $southBoundary = "---"
                if($cell.South -And $cell.IsLinked($cell.South)) { $southBoundary = "   " }
                $corner = "+"

                $bottom += $southBoundary + $corner
            }

            $output+=$top + "`n"
            $output+=$bottom + "`n"
        }

        return $output
    }

    ToPng($CellSize, $FileName) {

        $background = "White"

        $width  = $CellSize * $this.NumberOfColumns
        $height = $CellSize * $this.NumberOfRows

        $wall = New-Object System.Drawing.Pen 'Black', 1

        $bmp = New-Object System.Drawing.Bitmap ($width+1), ($height+1)

        $graphics = [System.Drawing.Graphics]::FromImage($bmp)
        $graphics.Clear($background )

        foreach ($cell in $this.Cells)
        {
            $x1 = $cell.Col*$CellSize
            $y1 = $cell.Row*$CellSize
            $x2 = ($cell.col+1)*$CellSize
            $y2 = ($cell.Row+1)*$CellSize

            if(!$cell.North) { $graphics.DrawLine($wall, $x1, $y1, $x2, $y1) }
            if(!$cell.West)  { $graphics.DrawLine($wall, $x1, $y1, $x1, $y2) }

            if($cell.IsLinked($cell.East))  { $graphics.DrawLine($wall, $x2, $y1, $x2, $y2) }
            if($cell.IsLinked($cell.South)) { $graphics.DrawLine($wall, $x1, $y2, $x2, $y2) }
        }

        $bmp.Save($FileName)
        Invoke-Item $FileName
    }
}

class BinaryTree {
    [Grid]$grid

    BinaryTree([Grid]$grid) {
        $this.grid = $grid

        foreach ($cell in $grid.Cells) {

            $cell.ClearNeighbors()

            if($cell.North) { $cell.TheNeighbors  = $cell.North }
            if($cell.East)  { $cell.TheNeighbors += $cell.East  }

            $neighbor = $cell.TheNeighbors | Get-Random
            $cell.Link($neighbor,$true)
        }
    }
}

cls

$Grid = [Grid]::new($Rows, $Columns)
$null = [BinaryTree]::new($Grid)
$Grid.ToPng(40, "c:\temp\test.png")