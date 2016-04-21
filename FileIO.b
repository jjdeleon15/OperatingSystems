import "FileSystem"


manifest {//FILE * or OPEN_FILE(OF)
	OF_NAME = 0, 						//24 CHARS, 6 WORDS
	OF_DATE_MOD = 6, 					//LONG DATE, 7 WORDS
	OF_FILE_SIZE = 13,					//Size of file in bytes
	OF_DATA_BLKS = 14,					//number of data blocks being used
	OF_CAPACITY = 15, 					//Total number of bytes 
	OF_DATA_CREATED = 16,				//Short date, see datetime2(v) on documentation
	OF_LEVELS = 16,						//Uses last 3 bits of DATA_CREATED ! 0
	OF_DETAILS = 17, 					//Uses last 5 bits of DATA_CREATED ! 1
	OF_BLK_BUFF = 18,					//Ptr to block buffer
	OF_BLK_OFFSET = 19,					//Current offset in buffer
	OF_SIZE = 20,
	OF_DATA_START = 20					//data or ptrs will be stored from 20 - 127 	
}

