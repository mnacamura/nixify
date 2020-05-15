$0 !~ /^\. / && $0 !~ /^source / {
    print
}

/^\. / || /^source / {
    _RS = RS
    RS = "^$"
    while ( (getline contents < $2) > 0 ) {
        print contents
    }
    RS = _RS
}

