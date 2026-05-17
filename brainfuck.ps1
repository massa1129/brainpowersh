tape = @{
    left = [System.Collections.Generic.Stack[int]]::new()
    right = [System.Collections.Generic.Stack[int]]::new()
    current = 0
}

$Script::MaxCellValue = 255 # 8bit 最大値

function Move-Right(){
    $tape.left.Push($tape.current)

    if ($tape.right.Count -gt 0){
        $tape.current = $tape.right.Pop()
    } else {
        $tape.current = 0
    }
}

function Move-Left(){
    $tape.right.Push($tape.current)

    if ($tape.left.Count -gt 0){
        $tape.current = $tape.left.Pop()
    } else {
        $tape.current = 0
    }
}

function Update-TapeValue {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('Increment', 'Decrement')]
        $Action
    )

    if (Action -eq 'Increment') {
        $tape.current = ($tape.current + 1) % ($MaxCellValue + 1)
    } else {
        $tape.current = ($tape.current - 1 + ($MaxCellValue + 1)) % ($MaxCellValue + 1)
    }
}
