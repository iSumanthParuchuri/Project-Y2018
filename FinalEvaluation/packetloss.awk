BEGIN {
        sendLine = 0;
        recvLine = 0;
        fowardLine = 0;
}
 
$0 ~/^s.* AGT/ {
        sendLine ++ ;
}
 
$0 ~/^r.* AGT/ {
        recvLine ++ ;
}
 
$0 ~/^f.* RTR/ {
        fowardLine ++ ;
}
 
END {
        printf "cbr s:%d r:%d, r/s Packets dropped:%.4f, f:%d \n", sendLine, recvLine, (sendLine-recvLine),fowardLine;
}
 
