# Nushell Environment Config File
def create_left_prompt [] {
    let path_segment = ($env.PWD)
    $path_segment
}

def create_right_prompt [] {
    let time_segment = ([
        (date now | date format '%m/%d/%Y %r')
    ] | str join)
    $time_segment
}
