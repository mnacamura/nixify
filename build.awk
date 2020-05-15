function include_source_recursively(line,    words) {
    if ( line ~ /^\. / || line ~ /^source / ) {
        split(line, words)
        while ( (getline _line < words[2]) > 0 ) {
            include_source_recursively(_line)
        }
    } else if ( NR != 1 && line ~ /^#!/ ) {
        # Ignore shebang not at the first line
    } else if ( line ~ /^# shellcheck/ ) {
        # Ignore shellcheck annotations
    } else {
        print line
    }
}

{
    include_source_recursively($0)
}
