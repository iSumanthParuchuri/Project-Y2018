puts "Enter number of nodes (more than 10 nodes)"
set tnn [gets stdin]
#===================================
#     Simulation parameters setup
#===================================
set val(chan)   Channel/WirelessChannel    ;# channel type
set val(prop)   Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)  Phy/WirelessPhy            ;# network interface type
set val(mac)    Mac/802_11                 ;# MAC type
set val(ifq)    Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)     LL                         ;# link layer type
set val(ant)    Antenna/OmniAntenna        ;# antenna model
set val(ifqlen) 50                         ;# max packet in ifq
set val(nn)     $tnn                          ;# number of mobilenodes
set val(rp)     AODV                       ;# routing protocol
set val(x)      1500                        ;# X dimension of topography
set val(y)      1500                        ;# Y dimension of topography
set val(stop)   100.0                      ;# time of simulation end

#===================================
#        Initialization        
#===================================

set f0 [open throughput.tr w]
set f1 [open lost.tr w]
set f2 [open delay.tr w]        

#Create a ns simulator
set ns [new Simulator]

#Setup topography object
set topo       [new Topography]
$topo load_flatgrid $val(x) $val(y)
create-god $val(nn)

#Open the NS trace file
set tracefile [open blackhole.tr w]
$ns trace-all $tracefile

#Open the NAM trace file
set namfile [open blackhole.nam w]
$ns namtrace-all $namfile
$ns namtrace-all-wireless $namfile $val(x) $val(y)
set chan [new $val(chan)];#Create wireless channel

#===================================
#     Mobile node parameter setup
#===================================
$ns node-config -adhocRouting  $val(rp) \
                -llType        $val(ll) \
                -macType       $val(mac) \
                -ifqType       $val(ifq) \
                -ifqLen        $val(ifqlen) \
                -antType       $val(ant) \
                -propType      $val(prop) \
                -phyType       $val(netif) \
                -channel       $chan \
	       	-energyModel EnergyModel \
		-initialEnergy 100 \
		 -rxPower 0.3 \
		 -txPower 0.6 \
                -topoInstance  $topo \
                -agentTrace    ON \
                -routerTrace   ON \
                -macTrace      OFF \
                -movementTrace ON

#===================================
#        Nodes Definition        
#===================================
for {set i 0} {$i < $val(nn) } {incr i} {
set n($i) [$ns node]
$n($i) set X_  [expr rand() * 1500]
$n($i) set Y_ [expr rand() * 1000]	
$n($i) set Z_ 0.000000000000;
$ns initial_node_pos $n($i) 30
		
}

puts "Enter source node"
set source [gets stdin]
puts "Enter destination node"
set dest [gets stdin]

puts "Enter Total Number of Blackhole in the network:"
set twh [gets stdin]
puts "Enter Blackhole node ids:"
for {set i 0} {$i < $twh } {incr i} {
set whno [gets stdin]
set no($i) $whno
}
for {set i 0} {$i < $twh } {incr i} {
$n($no($i)) color red
$ns at 0.0 "$n($no($i)) color red"
$ns at 0.0 "$n($no($i)) label Blackhole"
$ns at 0.0 "[$n($no($i)) set ragent_] hacker"
}

$n($source) color green
$ns at 0.0 "$n($source) color brown"
$ns at 0.0 "$n($source) label Source"

$n($dest) color blue
$ns at 0.0 "$n($dest) color blue"
$ns at 0.0 "$n($dest) label Destination"

#for random motion
for {set i 0} {$i < $val(nn)} {incr i} {
    set xx_ [expr rand()*1500]
    set yy_ [expr rand()*1000]
    set rng_time [expr rand()*$val(stop)]
    $ns at $rng_time "$n($i) setdest $xx_ $yy_ 15.0"   ;# random movements
}


#===================================
#        Agents Definition        
#===================================
#Setup a UDP connection
set udp0 [new Agent/UDP]
$ns attach-agent $n($source) $udp0
set null1 [new Agent/LossMonitor]
$ns attach-agent $n($dest) $null1
$ns connect $udp0 $null1
$udp0 set packetSize_ 1500

#===================================
#        Applications Definition        
#===================================
#Setup a CBR Application over UDP connection
set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp0
$cbr0 set packetSize_ 1000
$cbr0 set rate_ 0.1Mb
$cbr0 set random_ null
$ns at 1.0 "$cbr0 start"
$ns at 100.0 "$cbr0 stop"

set holdtime 0
set holdseq 0

set holdrate1 0

proc record {} {
global null1  f0 f1 f2 holdtime holdseq holdrate1 

set ns [Simulator instance]
set time 0.9 ;#Set Sampling Time to 0.9 Sec

set bw0 [$null1 set bytes_]
set bw1 [$null1 set nlost_]

set bw2 [$null1 set lastPktTime_]
set bw3 [$null1 set npkts_]

set now [$ns now]
       
        # Record Bit Rate in Trace Files
        puts $f0 "$now [expr (($bw0+$holdrate1)*8)/(2*$time*1000000)]"

 
        # Record Packet Loss Rate in File
        puts $f1 "$now [expr $bw1/$time]"

if { $bw3 > $holdseq } {
                puts $f2 "$now [expr ($bw2 - $holdtime)/($bw3 - $holdseq)]"
        } else {
                puts $f2 "$now [expr ($bw3 - $holdseq)]"
        }

$null1 set bytes_ 0
$null1 set nlost_ 0

set holdtime $bw2
set holdseq $bw3
 
set  holdrate1 $bw0
    $ns at [expr $now+$time] "record"   ;# Schedule Record after $time interval sec
}
 
 
# Start Recording at Time 0
$ns at 0.0 "record"


#===================================
#        Termination        
#===================================
#Define a 'finish' procedure
proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    exec nam blackhole.nam &
#exec xgraph throughput.tr -geometry -x time -y throughput -t Throughput 800x400 &
 #exec xgraph lost.tr  -geometry -x time -y lost -t Lost 800x400 &
 #exec xgraph delay.tr  -geometry -x time -y delay -t End_End_Delay 800x400 &
    exit 0
}
for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "\$n($i) reset"
}
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "finish"
$ns at $val(stop) "puts \"done\" ; $ns halt"
$ns run
