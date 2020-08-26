
exec xgraph  delay.tr  -x TIME -y delay -bg white  -t "End-End-delay" -geometry 800*500 &

exec xgraph  lost.tr  -x TIME -y lost -bg white  -t "Loss_Ratio" -geometry 800*500 &

exec xgraph  throughput.tr  -x TIME -y throughput -bg white -t "Throughput" -geometry 800*500 &


