{
    if ( /^\. / || /^source / ) {
        while ( (getline line < $2) > 0 ) {
            if ( line !~ /^#!/ )
                print line
        }
    } else if ( $0 !~ /^# shellcheck / ) {
        print
    }

}
