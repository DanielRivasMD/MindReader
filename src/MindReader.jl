################################################################################

module MindReader

################################################################################

#  argument parser
include( "Utilities/argParser.jl" );

################################################################################


#  declare tool directories
utilDir    = "Utilities/"
#  load functions
@info("Loading modules...")
include( string(utilDir,    "fileReaderEDF.jl") );
include( string(utilDir,    "fileReaderXLSX.jl") );

################################################################################
end

################################################################################
