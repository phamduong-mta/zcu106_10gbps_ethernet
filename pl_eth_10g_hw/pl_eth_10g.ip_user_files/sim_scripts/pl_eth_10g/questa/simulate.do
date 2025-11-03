onbreak {quit -f}
onerror {quit -f}

vsim  -lib xil_defaultlib pl_eth_10g_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {pl_eth_10g.udo}

run 1000ns

quit -force
