set outfile [lindex $argv 0]
write_hw_platform -fixed -include_bit -force -file $outfile
