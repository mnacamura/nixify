function slurp(line,    words) {
    if ( line ~ /^\. / || line ~ /^source / ) {
        split(line, words)
        while ( (getline _line < words[2]) > 0 ) {
            slurp(_line)
        }
    } else if ( NR != 1 && line ~ /^#!/ ) {
        # Ignore shebang not in the first line
    } else if ( line ~ /^# shellcheck/ ) {
        # Ignore comments of shellcheck annotation
    } else {
        print line
    }
}

{
    slurp($0)
}
