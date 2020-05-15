{
    if ( /^\. / || /^source / ) {
        while ( (getline line < $2) > 0 ) {
            if ( line !~ /^#!/ )
                print line
        }
    }
    else {
        print
    }

}
