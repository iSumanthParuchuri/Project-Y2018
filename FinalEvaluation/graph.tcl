
exec xgraph  delay0.tr delay1.tr delay2.tr -x TIME -y delay -bg white  -t "End-End-delay" -geometry 800*500 &

exec xgraph  lost0.tr lost1.tr lost2.tr -x TIME -y lost -bg white  -t "Loss_Ratio" -geometry 800*500 &

exec xgraph  throughput0.tr throughput1.tr throughput2.tr  -x TIME -y throughput -bg white -t "Throughput" -geometry 800*500 &




