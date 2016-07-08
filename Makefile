#  $Id$
#######################################################################################
##  Project    : hdl-secded-producer
##  Designer   : Dmitry Murzinov (kakstattakim@gmail.com)
##  Link       : https://github.com/iDoka/hdl-secded-producer
##  Module     : Makefile
##  Description: MATLAB/Octave generator of Hamming ECC coding. Output format is Verilog HDL.
##  Revision   : $Rev
##  Version    : $GlobalRev$
##  Date       : $LastChangedDate$
##  License    : MIT
#######################################################################################


SCRIPT=hamming_producer.m
MATLAB_SCRIPT=$(shell basename -s.m $(SCRIPT))

OUTFILE=HammingCode.v

# If you have the student version of MATLAB (or simply the 32 bit version) on a 64 bit system,
# you will need to uncomment following string:
#STUDENT_OPT=-glnx86



#all: octave
all: matlab
	@echo "Generate done!"

matlab:
	@echo "MATLAB: Generating Hamming ECC coder/decoder verilog code: $(OUTFILE)"
	@matlab -nosplash -nodesktop -nodisplay -nojvm $(STUDENT_OPT) -r $(MATLAB_SCRIPT)

octave:
	@echo "Octave: Generating Hamming ECC coder/decoder verilog code: $(OUTFILE)"
	@octave --silent --no-gui --no-window-system --traditional $(SCRIPT)

clean:
	@rm -rf $(OUTFILE)

.PHONY: octave matlab all clean
