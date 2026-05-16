tape = @{
    left = [System.Collections.Generic.Stack[int]]::new()
    right = [System.Collections.Generic.Stack[int]]::new()
    current = 0
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
