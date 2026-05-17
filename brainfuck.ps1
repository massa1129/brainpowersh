class BfCommand {
    [char]$Op # '+', '-', '>', '<', ',', '.', '[', ']'
    [int]$Value
    [int]$JumpOffset

    BfCommand([char]$op) {
        $this.Op = $op
        $this.Value = 1
        $this.JumpOffset = 0
    }
}

$BrainfuckSession = @{
    Program = [System.Collections.Generic.List[BfCommand]]::new()

    PendingOpen = [System.Collections.Generic.Stack[int]]::new()

    tape = @{
        left = [System.Collections.Generic.Stack[int]]::new()
        right = [System.Collections.Generic.Stack[int]]::new()
        current = 0
    }
}

$Script:PC = 0

function Append-AndRegisterRle {
    param(
        [string]$NewInputText
    )

    # 圧縮対象
    $rleTargets = @('+', '-')
    $ValidChars = @([char]'+', [char]'-', [char]'<', [char]'>', [char]',', [char]'.', [char]'[', [char]']')

    foreach ($char in $NewInputText.ToCharArray()) {

        if ($ValidChars -notcontains $char) { continue }

        $lastCmd = if ($BrainfuckSession.Program.Count -gt 0) { $BrainfuckSession.Program[-1] } else { $null }

        if ( $null -ne $lastCmd -and $lastCmd.Op -eq $char -and $rleTargets -contains $char) {
            $lastCmd.Value++
        } else {
            [BfCommand]$newCmd = [BfCommand]::new($char)
            $BrainfuckSession.Program.Add($newCmd)

            $currentIndex = $BrainfuckSession.Program.Count - 1

            if ($char -eq '[') {
                $BrainfuckSession.PendingOpen.Push($currentIndex)
            }
            elseif ($char -eq ']') {
                if ($BrainfuckSession.PendingOpen.Count -gt 0) {
                    $openIndex = $BrainfuckSession.PendingOpen.Pop()

                    $distance = $currentIndex - $openIndex

                    $BrainfuckSession.Program[$openIndex].JumpOffset = $distance
                    $BrainfuckSession.Program[$currentIndex].JumpOffset = -$distance
                } else {
                    Write-Error "Syntax Error: 対応する '[' がありません。"
                    return $false
                }
            }
        }
    }
    return $true
}

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

$Script:MaxCellValue = 255 # 8bit 最大値
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
