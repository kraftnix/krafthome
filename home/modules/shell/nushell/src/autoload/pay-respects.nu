
def --env f [] {
	let dir = (with-env { _PR_LAST_COMMAND: (history | last).command, _PR_SHELL: nu } { pay-respects })
	cd $dir
}

