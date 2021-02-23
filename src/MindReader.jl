################################################################################

module MindReader

################################################################################

#  argument parser
include( "Utilities/argParser.jl" );

################################################################################


#  declare tool directories
utilDir    = "Utilities/"
signalDir  = "SignalProcessing/"

################################################################################

#  load functions
@info("Loading modules...")
include( string(utilDir,    "fileReaderEDF.jl") );
include( string(utilDir,    "fileReaderXLSX.jl") );
include( string(signalDir,  "signalBin.jl") );
include( string(signalDir,  "fastFourierTransform.jl") );

################################################################################
end

################################################################################
