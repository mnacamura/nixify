$0 !~ /^\. / && $0 !~ /^source / {
    print
}

/^\. / || /^source / {
    while ( (getline line < $2) > 0 ) {
        if ( line !~ /^#!/ )
            print line
    }
}
