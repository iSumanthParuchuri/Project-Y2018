BEGIN {
initialenergy=100
maxenergy=0
n=25
nodeid=999
}
{
# Trace line format: energy
event = $1
time = $2 

if (event== "N") {
node_id = $5
energy = $7
}
# Store remaining energy
finalenergy[node_id] = energy
}
END {
# Compute consumed energy for each node
for (i in finalenergy) {
consumenergy[i] = initialenergy-finalenergy[i]
totalenergy += consumenergy[i]
if(maxenergy < consumenergy[i]){
maxenergy = consumenergy[i]
nodeid = i
}
}
###compute average energy
averagenergy=totalenergy/n
####output
for (i=0; i<n; i++) {
print("node",i, consumenergy[i])
}
print("+===========+")
print("average energy",averagenergy)
print("+===========+")
print("Average Residual energy",initialenergy-averagenergy)
print("+===========+")
}BEGIN {
}BEGIN {
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
        printf "cbr s:%d r:%d, r/s Ratio:%.4f, f:%d \n", sendLine, recvLine, (recvLine/sendLine),fowardLine;
}
 
