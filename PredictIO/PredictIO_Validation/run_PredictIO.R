
source("/home/bioinf/bhklab/farnoosh/PredictIO/Prog/PredictIO_Validation/IO_Resistance.R")
source("/home/bioinf/bhklab/farnoosh/PredictIO/Prog/PredictIO_Validation/IO_Sensitive.R")
source("/home/bioinf/bhklab/farnoosh/PredictIO/Prog/PredictIO_Validation/PredictIO.R")

source("/home/bioinf/bhklab/farnoosh/PredictIO/Prog/PredictIO_Validation/Meta-Analysis_PredictIO.R")

########################################################################################################################
########################################################################################################################

dir.create( "/home/bioinf/bhklab/farnoosh/PredictIO/Result/PredictIO_Validation/" )

get_Directory <- function( dir ){

	file = paste( "/home/bioinf/bhklab/farnoosh/PredictIO/Result/PredictIO_Validation/" , dir , sep="" )
	
	metascore = c("IO_Sensitive" , "IO_Resistance" , "PredictIO" ) 

	if( file.exists( file ) ) {
		unlink( file , recursive = TRUE )
	}

	dir.create( file )

	for( i in 1:length(metascore) ){

		dir.create( paste( file , "/" , metascore[i] , sep="" ) )

	}

}
########################################################################################################################
########################################################################################################################


cohort = c( "Shiuan" , "VanDenEnde" , "Kim" , "Gide" , "Puch",  "Padron")

for(z in 1:length( cohort ) ){

	get_Directory( dir= cohort[z] )

	load( "/home/bioinf/bhklab/farnoosh/PredictIO/Result/denovo_Single_Gene/Meta-analysis_Single_Gene_Response.RData" )

	m = meta_res[ meta_res$pval <= 0.05 & meta_res$I2_pval > 0.05 , ]
	m = m[ rev( order( abs( m$coef) ) ) , ]

	for(i in 1:nrow(meta_res)){

		if( meta_res$pval[i] <= 0.05 ){
			meta_res$include[i] = ifelse( abs( meta_res$coef[i] ) >= abs( m$coef[ 29 ] ) , 1 , 0 )
		} else{
			meta_res$include[i] = 0
		}
	}
	meta_res$cutoff = abs( m$coef[ 29 ] )

	########################################################
	########################################################
	print( paste( "####### Study:" , cohort[z] , " | IO_Resistance #######" , sep="" ) )
	Get_IO_Resistance( exprID= cohort[z] , meta_res= meta_res  )

	print( paste( "####### Study:" , cohort[z] , " | IO_Sensitive #######" , sep="" ) )
	Get_IO_Sensitive( exprID= cohort[z] , meta_res= meta_res  )

	print( paste( "####### Study:" , cohort[z] , " | PredictIO #######" , sep="" ) )
	Get_PredictIO( exprID= cohort[z] , meta_res= meta_res  )
	
}

########################################################################################################################
########################################################################################################################

source("/home/bioinf/bhklab/farnoosh/PredictIO/Prog/PredictIO_Validation/Meta-Analysis_PredictIO.R")

cohort = c( "Shiuan" , "VanDenEnde" , "Kim" , "Gide" , "Puch" ,  "Padron")

file = "/home/bioinf/bhklab/farnoosh/PredictIO/Result/PredictIO_Validation/meta_analysis"

outcome = c("Response" , "OS" , "PFS") 

if( file.exists( file ) ) {
	unlink( file , recursive = TRUE )
}

dir.create( file )

for( i in 1:length(outcome) ){
		dir.create( paste( file , "/" , outcome[i] , sep="" ) )
}

########################################################################################################################
########################################################################################################################
Get_Meta_Analysis_PredictIO( cohort= cohort )

