import "io"
import "string"

manifest {//SUPER_BLOCK
	SB_BLOCK_NUMBER = 0,
	RD_BLOCK_NUMBER = 1;
	FL_BLOCK_NUMBER = 2,					

	SB_DISC_NAME = 0,
	SB_DISC_SIZE = 8,
	SB_ROOT_DIR = 9,
	SB_FREE_BLKS = 10,
	SB_FREE_LIST = 11,								
	SB_FORMAT_TIME = 12,
	SB_BLK_NUMBER = 19,
	SB_COPY = 20,
	SB_RD_CPY = 21,
	SB_FL_CPY = 22,
	SB_UNIT_NUM = 23,
	
	SB_SIZE = 24,
	SB_ROOT_DIR_INFO = SB_SIZE,
	SB_SIZE_BYTES = SB_SIZE * 4,
	SB_NAME_SIZE = 8,
	SB_NAME_BYTES = SB_NAME_SIZE * 4,

	BLOCKS_FOR_SYS = 6,
	BLOCK_SIZE = 128,
	BYTES_PER_BLOCK = BLOCK_SIZE * 4
}
/*	Root Directory
 *		RD_NAME - name of root_dir file, 6 words long
 *		RD_DATE_MOD - last time root dir has been modified
 *		RD_ENTRIES - number of files in the root directory
 *		RD_CAPACITY - total number of files capable of storing in current level
 *		RD_LEVELS - number of levels of ptrs to files
 *		RD_DISC_UNIT unit of disc
 *		RD_DETAILS stored as 000...000321
 *			321 will store the VALID | DIRTY | STICKY
 *		RD_DATE_CREATED - long date of when created
 *		RD_SIZE - space needed to store the words above
 *
 *	File Entry
 *		FE_NAME of the file, maximum 24 characters long
 *		FE_FILE_BLK ptr to first block in a file
 *		FE_DATE last modification to the date stored with datetime2
 *		FE_LEVELS number of levels of pointers to data for file
 *			321 will store level of ptrs for file read as a number
 *		FE_DETAILS will use the last 3 unused bits from DATE ! 1 to store as 000...321:
 *			32 will store the DIRTY | VALID bits for the file
 *			1 will store whether the file is a directory 
 */
manifest {//ROOT_DIR_INFO(RD) and FILE_ENTRY(FE)
	RD_NAME = 0,
	RD_DATE_MOD = 6,
	RD_ENTRIES = 13,
	RD_CAPACITY = 14,
	RD_LEVELS = 15,
	RD_DISC_UNIT = 16,
	RD_DETAILS = 17,
	RD_DATE_CREATED = 18,
	RD_SIZE = 25,
	RD_SIZE_BYTES = RD_SIZE * 4,

	RD_NAME_SIZE = 6,
	RD_NAME_BYTES = RD_NAME_SIZE * 4;

	RD_VALID =  0b100,
	RD_DIRTY =  0b010,
	RD_STICKY = 0b001,

	FILE_NAME_SIZE = 5,
	FILE_NAME_BYTES = FILE_NAME_SIZE * 4;

	FE_NAME = 0, 
	FE_FILE_BLK = 5,
	FE_DATE = 6,
	FE_LEVELS = 6,
	FE_DETAILS = 7,
	FE_SIZE = 8,
	FE_SIZE_BYTES = FE_SIZE * 4
}
manifest {//FREE_LIST
	FL_FREE_BLKS = 0,
	FL_PTR_BLKS = 1,
	FL_DATA = 2
}
manifest {//LONG_DATE(LD) AND SHORT_DATE(SD)
	LONG_DATE_SIZE = 7,
	LONG_DATE_BYTES = LONG_DATE_SIZE * 4,

	LD_YEAR = 0, 								//year
	LD_MONTH = 1,								//month, 1-12
	LD_DAY = 2,									//day, 1-31
	LD_DOW = 3,									//day of week, 0 = Sunday
	LD_HOUR = 4, 								//hour, 0-23
	LD_MIN = 5, 								//minute, 0-59
	LD_SEC = 6, 								//second, 0-59

	SHORT_DATE_SIZE = 2,
	SHORT_DATE_BYTES = SHORT_DATE_SIZE * 4,
	SD_Y_M_D_DOW  = 0, 	/* 	13 most significant bits = year
							4 next bits = month
							5 next bits = day
							3 next bits = day of week
							7 least significant bits not used */
	SD_H_S_MS = 1		/*	5 most significant bits = hour
							6 next bits = minute
							6 next bits = second
							10 next bits = milliseconds
							5 least significant bits not used */
}
manifest {//DISC_PTR
	DP_DISC_UNIT = 0,
	DP_DISC_SIZE = 1,
	DP_DISC_NAME = 2,
	DP_SUPER_BLOCK = 10,
	DP_ROOT_DIR = 11,
	DP_RD_BLOCK =12, 
	DP_FREE_LIST = 13,
	DP_BLOCK_BUFF = 14,
	DP_OPEN_LIST = 15,
	DP_SIZE = 16,

	//OFL - OPEN FILE LIST
	OFL_ENTRIES = 0,
	OFL_SIZE = BLOCK_SIZE
}
manifest {//FILE OPTION CONSTANTS
	READ = 	0b10000,
	WRITE = 0b01000,
	GETLVL = 0b00111,
	LVLCLEAR = bitnot GETLVL,

	VALID =  0b1000,
	DIRTY =  0b0100,
	STICKY = 0b0010,
	IS_DIR = 0b0001,
	DETSET = 0b1111,
	DETCLR = bitnot DETSET
}
manifest {//FILE * or OPEN_FILE(OF)
	OF_NAME = 0, 						//20 CHARS, 5 WORDS
	OF_FILE_BLK = 5,
	OF_DATE_MOD = 6, 					//SHORT DATE, 2 WORDS
	OF_FUNCTIONS = 6,					//Bits 54 will be READ | WRITE
	OF_LEVEL = 6,						//Uses last 3 bits of DATE_CREATED ! 0
	OF_DETAILS = 7, 					//Uses last 4 bits of DATE_CREATED ! 1
	OF_BYTE_SIZE = 8,					//Size of file in bytes
	OF_DATA_BLKS = 9,					//number of data blocks being used
	OF_DATE_CREATED = 10,				//SHORT DATE, 2 WORDS
	OF_MOD_BLOCK = 12,					//Value of where blk buff must be written back to if closed
	OF_MOD_BYTE = 13,					//USED FOR READ and WRITE: Current byte of word
	OF_BLK_BUFF = 14,					//Block Buffer for file
	OF_BLK_OFFSET = 15,					//Current byte in buffer
	
	OF_SIZE = 15,
	OF_SIZE_BYTES = OF_SIZE * 4,
	OF_DATA_START = OF_SIZE,
	delchar = 127,
	bspace = '\b'
}
manifest { heapSize = 8192 }
static { heap = vec(heapSize) }

//Disc Utilities
let clearBuffer(blkBuffer) be {
	vecset(blkBuffer, nil, BLOCK_SIZE);
}
let copyBlock(dest, src) be {
	veccpy(dest, src, BLOCK_SIZE);
}
let printBlockBuffer(blkBuffer) be {
	for i = 0 to BLOCK_SIZE - 1 by 1 do {
		out("%d\n", blkBuffer ! i);
	}
	out("\n\n");
}
let writeBlockToDisc(discUnit, blkNumber, blkBuffer) be {
	let res;
	res := devctl(DC_DISC_WRITE, discUnit, blkNumber, 1, blkBuffer);
	if res < 0 then {
		out("Could not write block to disc %d at block %d, please try again\n", discUnit, blkNumber);
		printBlockBuffer(blkBuffer);
		finish
	}
	resultis res;
}
let readBlockFromDisc(discUnit, blkNumber, blkBuffer) be {
	let res;
	res := devctl(DC_DISC_READ, discUnit, blkNumber, 1, blkBuffer);
	if res < 0 then {
		out("Could not read block from disc %d at block %d, please try again", discUnit, blkNumber);
		//Throw some interrupt or something
		finish
	}
	resultis res;
}
let checkDisk(discUnit) be {
	let discSize = devctl(DC_DISC_CHECK, discUnit);
	if (discSize = 0) then {
		out("Disc #%d is not available for use\n", discUnit);
		resultis nil;
	}
	resultis discSize;
}
let printBlockFromDisc(discUnit, blockNumber) be {
	let blkBuffer = vec(BLOCK_SIZE);
	readBlockFromDisc(discUnit, blockNumber, blkBuffer);
	for i = 0 to BLOCK_SIZE - 1 by 1 do {
		out("%d | %x | %b | %c%c%c%c \n", blkBuffer ! i, blkBuffer ! i, blkBuffer ! i, byte 0 of (blkBuffer ! i),
			byte 1 of (blkBuffer ! i), byte 2 of (blkBuffer ! i), byte 3 of (blkBuffer ! i));
	}
	out("\n\n");
}
let printSuperBlock(sbBuffer) be {
	out("Disc Name: %s | Unit Number: %d\n", sbBuffer + SB_DISC_NAME, sbBuffer ! SB_UNIT_NUM);
	out("Size: %d | Free Blocks: %d\n",sbBuffer ! SB_DISC_SIZE, sbBuffer ! SB_FREE_BLKS);
	out("Root Dir: %d | Free List: %d\n", sbBuffer ! SB_ROOT_DIR, sbBuffer ! SB_FREE_LIST);
	out("FormatDate: %02d/%02d/%4d\n", (sbBuffer + SB_FORMAT_TIME) ! LD_MONTH,
			(sbBuffer + SB_FORMAT_TIME) ! LD_DAY, (sbBuffer + SB_FORMAT_TIME) ! LD_YEAR);
	out("SB_COPY: %d | SB_RD_CPY: %d | SB_FL_CPY : %d\n\n\n", sbBuffer ! SB_COPY,
		sbBuffer ! SB_RD_CPY, sbBuffer ! SB_FL_CPY);
}
let printRootDir(rootDirBuff) be {
	let rootDirDate = rootDirBuff + RD_DATE_MOD;
	out("Root Name: %s | Last Modified: ", rootDirBuff + RD_NAME);
	printLongDate(rootDirBuff + RD_DATE_MOD);
	out("\nEntries: %d | Capacity: %d | Levels: %d\n", 
		rootDirBuff ! RD_ENTRIES, rootDirBuff ! RD_CAPACITY, rootDirBuff ! RD_LEVELS);

	rootDirDate := rootDirBuff + RD_DATE_CREATED;
	out("Details: %05b | Created On: ", rootDirBuff ! RD_DETAILS);
	printLongDate(rootDirBuff + RD_DATE_CREATED);
	outch('\n');
}
let printDiscFreeList(freeList) be {
	let n = (freeList ! FL_PTR_BLKS > 0) -> freeList ! FL_PTR_BLKS, freeList ! FL_PTR_BLKS;
	out("Free Blocks: %d | Ptr Blocks: %d\n", 
		freeList ! FL_FREE_BLKS,freeList ! FL_PTR_BLKS);
	for i = FL_DATA to (n + FL_DATA - 1) do {
		out("%d | %x | %b\n", freeList  ! i, freeList ! i, freeList ! i);
	}
	out("\n\n");
}
let printFileEntry(fileEntry) be {
	let fileName = vec(FILE_NAME_SIZE);
	fixed_to_str(fileName, fileEntry + FE_NAME, FILE_NAME_BYTES - 1);
	out("%s | BLK: %d | Last Modified: ", fileName, fileEntry ! FE_FILE_BLK);
	printShortDate(fileEntry + FE_DATE);
	out("\n");
}
let printOpenFile(openFilePtr) be {
	let capacity = openFilePtr ! OF_DATA_BLKS * BYTES_PER_BLOCK;
	if capacity = 0 then capacity := (BLOCK_SIZE - OF_SIZE) * 4;
	out("FileName: %s | Last Modified: ", openFilePtr + OF_NAME);
	printShortDate(openFilePtr + OF_DATE_MOD);
	out("\nFile Size : %d | Blocks: %d | Blk Number %d\n", openFilePtr ! OF_BYTE_SIZE, 
		openFilePtr ! OF_DATA_BLKS, openFilePtr ! OF_FILE_BLK);
	out("Capacity: %d | Date Created ", capacity);
	printShortDate(openFilePtr + OF_DATE_CREATED);
	out("\n");
}

let createSuperBlockMD(discUnit, discNameFixed, discSize, tmpSuperBlock) be {
	let ptrBlocks = (discSize - BLOCKS_FOR_SYS) / (BLOCK_SIZE + 1) + 1; 
	memcpy(tmpSuperBlock + SB_DISC_NAME, discNameFixed, SB_NAME_BYTES);
	tmpSuperBlock ! SB_DISC_SIZE := discSize;
	tmpSuperBlock ! SB_ROOT_DIR := RD_BLOCK_NUMBER;
	tmpSuperBlock ! SB_FREE_BLKS := discSize - BLOCKS_FOR_SYS - ptrBlocks;
	tmpSuperBlock ! SB_FREE_LIST := FL_BLOCK_NUMBER;
	datetime(seconds(), tmpSuperBlock + SB_FORMAT_TIME);
	tmpSuperBlock ! SB_BLK_NUMBER := SB_BLOCK_NUMBER;
	tmpSuperBlock ! SB_COPY := discSize - 3;
	tmpSuperBlock ! SB_RD_CPY := discSize - 2;
	tmpSuperBlock ! SB_FL_CPY := discSize - 1;
	tmpSuperBlock ! SB_UNIT_NUM := discUnit;
}
let createRootDirMD(rootNameFixed, discUnit, tmpRootDirMD) be {
	let modDate = vec(LONG_DATE_SIZE), createDate = vec(LONG_DATE_SIZE);
	veccpy(tmpRootDirMD + RD_NAME, rootNameFixed, RD_NAME_SIZE);
	datetime(seconds(), tmpRootDirMD + RD_DATE_MOD);
	tmpRootDirMD ! RD_ENTRIES := 0;
	tmpRootDirMD ! RD_CAPACITY := BLOCK_SIZE / FE_SIZE;
	tmpRootDirMD ! RD_LEVELS := 0;
	tmpRootDirMD ! RD_DISC_UNIT := discUnit;
	tmpRootDirMD ! RD_DETAILS := RD_VALID;
	veccpy(tmpRootDirMD + RD_DATE_CREATED, tmpRootDirMD + RD_DATE_MOD, LONG_DATE_SIZE);
}
let createFreeList(tmpSuperBlock, tmpFreeList) be {
	let tmpPtrBlock = vec(BLOCK_SIZE), discSize, discUnit, 
		ptrBlocks, curDataBlock, lastBlock, remaining;

		discSize := tmpSuperBlock ! SB_DISC_SIZE;
		discUnit := tmpSuperBlock ! SB_UNIT_NUM;
		
		clearBuffer(tmpFreeList);
		ptrBlocks := (discSize - BLOCKS_FOR_SYS) / (1 +  BLOCK_SIZE);
		remaining := (discSize - BLOCKS_FOR_SYS) rem (1 +  BLOCK_SIZE);
		curDataBlock := 3;
		for i = 0 to ptrBlocks - 1 do {
			tmpFreeList ! (FL_DATA + i) := curDataBlock;
			curDataBlock +:= 1;
			for slot = 0 to BLOCK_SIZE - 1 do {
				tmpPtrBlock ! slot := curDataBlock;
				curDataBlock +:= 1;
			}
			writeBlockToDisc(discUnit, tmpFreeList ! (FL_DATA + i), tmpPtrBlock);
		}
		if remaining > 0 then {
			tmpFreeList ! ptrBlocks := curDataBlock;
			curDataBlock +:= 1;
			clearBuffer(tmpPtrBlock);
			for i = 0 to remaining - 1 do {
				tmpPtrBlock ! i := curDataBlock;
				curDataBlock +:= 1;
			}
			writeBlockToDisc(discUnit, tmpFreeList ! ptrBlocks, tmpPtrBlock);
			ptrBlocks +:= 1
		}
		tmpFreeList ! FL_FREE_BLKS := discSize - BLOCKS_FOR_SYS - ptrBlocks;
		tmpFreeList ! FL_PTR_BLKS := ptrBlocks;
		for i = ptrBlocks to BLOCK_SIZE - 1 by 1 do 
			tmpFreeList ! i := nil;
		
}
let createDiscPtr(discUnit, discPtr, superblock, rootDir, 
	rootDirBlock, freeList, blockBuffer, openList) be {
	discPtr ! DP_DISC_UNIT := discUnit;
	memcpy(discPtr + DP_DISC_NAME, superblock + SB_DISC_NAME, SB_NAME_BYTES);
	discPtr ! DP_DISC_SIZE := superblock ! SB_DISC_SIZE;
	discPtr ! DP_SUPER_BLOCK := superblock;
	discPtr ! DP_ROOT_DIR := rootDir;
	discPtr ! DP_RD_BLOCK := rootDirBlock;
	discPtr ! DP_FREE_LIST := freeList;
	discPtr ! DP_BLOCK_BUFF := blockBuffer;
	discPtr ! DP_OPEN_LIST := openList;
}

let writeSBtoDisc(discUnit, discSize, superBlockBuffer) be {
	writeBlockToDisc(discUnit, SB_BLOCK_NUMBER, superBlockBuffer);
	writeBlockToDisc(discUnit, superBlockBuffer ! SB_COPY, superBlockBuffer);
}
let writeRDtoDisc(discUnit, discSize, rootDirBlock) be {
	writeBlockToDisc(discUnit, RD_BLOCK_NUMBER, rootDirBlock);
	writeBlockToDisc(discUnit, discSize - 2, rootDirBlock);
}
let writeFLtoDisc(discUnit, discSize, freeListBuffer) be {
	writeBlockToDisc(discUnit, FL_BLOCK_NUMBER, freeListBuffer);
	writeBlockToDisc(discUnit, discSize - 1, freeListBuffer);
}

let shiftBlockBufferUp(n, blockBuffer) be {
	shiftArrUp(n, blockBuffer, BLOCK_SIZE);
}
let shiftBlockBufferDown(n, blockBuffer) be {
	shiftArrDown(n, blockBuffer, BLOCK_SIZE);
}

let popPtrBlock(freeList, nBlocks, ptrBlocks) be {
	shiftBlockBufferUp(1, freeList);
	freeList ! FL_FREE_BLKS := nBlocks;
	freeList ! FL_PTR_BLKS := ptrBlocks;
}
let addFreeBlock(discPtr, freedBlock) be {
	let freeList = discPtr ! DP_FREE_LIST, ptrBlock = vec(BLOCK_SIZE), ptrBlockNum, slot, 
		discUnit = discPtr ! DP_DISC_UNIT;
	for i = 0 to freeList ! FL_PTR_BLKS - 1 do {
		ptrBlockNum := freeList ! (FL_DATA + i);
		readBlockFromDisc(discUnit, ptrBlockNum, ptrBlock);
		if ptrBlock ! (BLOCK_SIZE - 1) = nil then {//Space for freed block
			slot := BLOCK_SIZE - 1;
			until ptrBlock ! (slot - 1) /= nil do {
				slot -:= 1;//Until previous is not nil
				if slot = 0 then break;
			}
			out("Found slot %d in block %d\n", slot, ptrBlockNum);
			ptrBlock ! slot := freedBlock;
			writeBlockToDisc(discUnit, ptrBlockNum, ptrBlock);
			freeList ! FL_FREE_BLKS +:= 1;
			out("Added new free block %d to blk :%d\n", freedBlock, ptrBlock);
			return;
		}
	}
	test freeList ! FL_FREE_BLKS > 0 then {
		if freeList ! FL_FREE_BLKS = (BLOCK_SIZE - FL_DATA) then {
			out("Free list is somehow full, something is wrong!\n");
			finish;
		}
		freeList ! (FL_DATA + freeList ! FL_PTR_BLKS) := freedBlock;
		clearBuffer(ptrBlock);
		writeBlockToDisc(discUnit, freedBlock, ptrBlock);
		freeList ! FL_PTR_BLKS +:= 1;
		out("Made new ptr block\n");
	} else {//Single block
		test freeList ! FL_FREE_BLKS = (BLOCK_SIZE - FL_DATA) then {//Jump to level 2
			veccpy(ptrBlock, freeList + FL_DATA, BLOCK_SIZE - FL_DATA);
			writeBlockToDisc(discUnit, freedBlock, ptrBlock);
			clearBuffer(ptrBlock);
			ptrBlock ! 0 := freedBlock;
			veccpy(freeList + FL_DATA, ptrBlock, BLOCK_SIZE - FL_DATA);
			freeList ! FL_PTR_BLKS := 1;
			out("Made first ptr block\n");
		} else {
			freeList ! (FL_DATA + freeList ! FL_FREE_BLKS) := freedBlock;
			freeList ! FL_FREE_BLKS +:= 1;
			out("Added new free block %d to blk :%d\n", freedBlock, FL_BLOCK_NUMBER);
		}
	}
}
let getFreeBlock(discPtr) be {
	let freeList = discPtr ! DP_FREE_LIST, freeBlk, ptrBlock = vec(BLOCK_SIZE), ptrBlockNum, 
		discUnit = discPtr ! DP_DISC_UNIT, nBlocks = freeList ! FL_FREE_BLKS, 
		ptrBlocks = freeList ! FL_PTR_BLKS;

	if nBlocks = 0 then {
		out("Te Jodiste, disc %d is full", discUnit);
		finish;
	}
	test ptrBlocks > 0 then {//Using ptr blocks to free blocks
		ptrBlockNum := freeList ! FL_DATA;//First ptr block in free list
		readBlockFromDisc(discUnit, ptrBlockNum, ptrBlock);
		freeBlk := ptrBlock ! 0;//First free block in ptr block
		shiftBlockBufferUp(1, ptrBlock);
		writeBlockToDisc(discUnit, ptrBlockNum, ptrBlock);
		nBlocks -:= 1;
		if ptrBlock ! 0 = nil then {//Ptr Block now empty
			ptrBlocks -:= 1;
			popPtrBlock(freeList, nBlocks, ptrBlocks);
			addFreeBlock(discPtr, ptrBlockNum);
		}
	} else {//126 or fewer pts to free blocks
		freeBlk := freeList ! FL_DATA;
		nBlocks -:= 1;
		popPtrBlock(freeList, nBlocks, ptrBlocks);
	}
	freeList ! FL_FREE_BLKS := nBlocks;//In case ptr block was added back as a free block 
	freeList ! FL_PTR_BLKS := ptrBlocks;//In case ptr block was added back as a free block

	if ptrBlocks = 1 /\ nBlocks <= 125 then {
		readBlockFromDisc(discUnit, freeList ! FL_DATA, ptrBlock);//Reading last ptr block
		for i = 0 to nBlocks - 1 by 1 do {//Writing its ptr after itself in the freeList
			freeList ! (FL_DATA + 1 + i) := ptrBlock ! i;
		}
		clearBuffer(ptrBlock);//Clearing block
		writeBlockToDisc(discUnit, freeList ! FL_DATA, ptrBlock);//Writing back
		freeList ! FL_FREE_BLKS := nBlocks + 1;
		freeList ! FL_PTR_BLKS := 0;
	}
	discPtr ! DP_SUPER_BLOCK ! SB_FREE_BLKS -:= 1;
	freeList ! FL_FREE_BLKS := nBlocks;
	freeList ! FL_PTR_BLKS := ptrBlocks;
	resultis freeBlk;
}

let listRootDir(rootDirBlock, level, discUnit) be {
	let blockBuffer = vec(BLOCK_SIZE);
	test level > 0 then {
		for i = 0 to BLOCK_SIZE - 1 by 1 do {
			if rootDirBlock ! i = nil then return;
			readBlockFromDisc(discUnit, rootDirBlock ! i, blockBuffer);
			listRootDir(blockBuffer, level - 1, discUnit);
		}
	} else {
		for i = 0 to BLOCK_SIZE - 1 by FE_SIZE do {
			test rootDirBlock ! i /= nil then 
				printFileEntry(rootDirBlock + i)
			else 
				return
		}
	}
}
let rootDirSearch(rootDirBlock, fileName, level, discUnit) be {
	let res, fileEntry, fileEntryName = vec(FILE_NAME_SIZE), blockBuffer = vec(BLOCK_SIZE);
	test level > 0 then {//Ptr Blocks
		for i = 0 to BLOCK_SIZE - 1 by 1 do {//Possibly modify check using bit from ptr adrr
			if rootDirBlock ! i = nil then resultis nil;
			readBlockFromDisc(discUnit, rootDirBlock ! i, blockBuffer);
			fileEntry := rootDirSearch(blockBuffer, fileName, level - 1, discUnit);
			if fileEntry /= nil then resultis fileEntry;
		}
	} else {	
		for i = 0 to BLOCK_SIZE - 1 by FE_SIZE do {
			fileEntry := rootDirBlock + i;
			if fileEntry ! 0 = nil then break;//If name is nil there are no more files
			memcpy(fileEntryName, fileEntry + FE_NAME, FILE_NAME_BYTES);
			if strcasecmp(fileName, fileEntryName) = 0 then {//Found file entry
				res := newvec(FE_SIZE);
				memcpy(res, fileEntry, FE_SIZE_BYTES);
				resultis res;
			}
			memset(fileEntryName, nil, FILE_NAME_SIZE);//Clearing
		}
		resultis nil;
	}
}
let findInRootDir(discPtr, fileName) be {
	//Returns file entry of file
	resultis rootDirSearch(discPtr ! DP_RD_BLOCK, fileName, 
		discPtr ! DP_ROOT_DIR ! RD_LEVELS, discPtr ! DP_ROOT_DIR ! RD_DISC_UNIT);
}
let addToRootDir(discPtr, fileEntry) be {
	let discUnit = discPtr ! DP_DISC_UNIT,rootDir = discPtr ! DP_ROOT_DIR,
		rootDirBlock = discPtr ! DP_RD_BLOCK, level = rootDir ! RD_LEVELS,
		entryBlock = vec(BLOCK_SIZE);
	test level = 1 then {
		for i = 0 to BLOCK_SIZE - 1 by 1 do {
			test rootDirBlock ! i /= nil then {
				readBlockFromDisc(discUnit, rootDirBlock ! i, entryBlock);
				if entryBlock ! (BLOCK_SIZE - FE_SIZE) /= nil then loop;//No space for entry
				for j = 0 to BLOCK_SIZE - 1 by FE_SIZE do {//Space in this block for an entry
					if entryBlock ! j = nil then {//insert here
						memcpy(entryBlock + j, fileEntry, FE_SIZE_BYTES);
						writeBlockToDisc(discUnit, rootDirBlock ! i, entryBlock);
						rootDir ! RD_ENTRIES +:= 1;
						return;
					}
				}
			} else {//All previous blocks are full, must make ptr block
				rootDirBlock ! i := getFreeBlock(discPtr);
				readBlockFromDisc(discUnit, rootDirBlock ! i, entryBlock);
				clearBuffer(entryBlock);
				memcpy(entryBlock, fileEntry, FE_SIZE_BYTES);//First entry in block
				writeBlockToDisc(discUnit, rootDirBlock ! i, entryBlock);
				rootDir ! RD_ENTRIES +:= 1;
				return;
			}
		}
	} else test level = 0 then {
		for i = 0 to BLOCK_SIZE - 1 by FE_SIZE do {
			if rootDirBlock ! i = nil then {//Slot found
				veccpy(rootDirBlock + i, fileEntry, FE_SIZE);
				rootDir ! RD_ENTRIES +:= 1;
				return;
			}
		} //rootDirBlock full, must use level of ptrs
		veccpy(entryBlock, rootDirBlock, BLOCK_SIZE);
		clearBuffer(rootDirBlock);
		rootDirBlock ! 0 := getFreeBlock(discPtr);
		rootDirBlock ! 1 := getFreeBlock(discPtr);
		writeBlockToDisc(discUnit, rootDirBlock ! 0, entryBlock);
		clearBuffer(entryBlock);
		veccpy(entryBlock, fileEntry, FE_SIZE);
		writeBlockToDisc(discUnit, rootDirBlock ! 1, entryBlock);
		writeBlockToDisc(discUnit, RD_BLOCK_NUMBER, rootDirBlock);
		readBlockFromDisc(discUnit, RD_BLOCK_NUMBER, discPtr ! DP_RD_BLOCK);
		discPtr ! DP_ROOT_DIR ! RD_LEVELS +:= 1;
	} else {
		out("We have reached a second level of ptrs and are not ready for this shit\n");
		finish;
	}
}

//BIT UTILITIES
let passedRead(function) be {
	resultis contains(function, 'r') + 1
}
let passedWrite(function) be {
	resultis contains(function, 'w') + 1
}
let passedAppend(function) be {
	resultis contains(function, 'a') + 1	
}
let clearDetails(filePtr) be {
	filePtr ! OF_DETAILS := (filePtr ! OF_DETAILS) bitand DETCLR;//Clears details
}
let clearRead(filePtr) be {
	filePtr ! OF_FUNCTIONS := (filePtr ! OF_FUNCTIONS) bitand (bitnot READ);
}
let clearWrite(filePtr) be {
	filePtr ! OF_FUNCTIONS := (filePtr ! OF_FUNCTIONS) bitand (bitnot WRITE);
}
let clearLevel(filePtr) be {
	filePtr ! OF_LEVEL := (filePtr ! OF_LEVEL) bitand LVLCLEAR;
}
let setLevel(filePtr, level) be {
	if 7 < level < 0 then {
		out("Invalid level passed level : %d\n", level);
		finish;
	}
	clearLevel(filePtr);
	filePtr ! OF_LEVEL := (filePtr ! OF_LEVEL) bitor level;//Sets any
}
let setRead(filePtr) be {
	clearRead(filePtr);
	filePtr ! OF_FUNCTIONS := (filePtr ! OF_FUNCTIONS) bitor READ;
}
let setWrite(filePtr) be {
	clearWrite(filePtr);
	filePtr ! OF_FUNCTIONS := (filePtr ! OF_FUNCTIONS) bitor WRITE;
}
let setDetails(filePtr, details) be {
	clearDetails(filePtr);
	filePtr ! OF_DETAILS := (filePtr ! OF_DETAILS) bitor details;//Sets details
}
let getRead(filePtr) be {
	resultis (filePtr ! OF_FUNCTIONS) bitand READ;
}
let getWrite(filePtr) be {
	resultis (filePtr ! OF_FUNCTIONS) bitand WRITE;
}
let getLevel(filePtr) be {
	resultis (filePtr ! OF_LEVEL) bitand GETLVL;
}

let createNewFile(discPtr, fileName) be {
	let fileBlockNum, rootDirSlot, fileBlkBuff = vec(BLOCK_SIZE),
		fileEntry = newvec(FE_SIZE), rootDir = discPtr ! DP_ROOT_DIR;
	fileBlockNum := getFreeBlock(discPtr);
	clearBuffer(fileBlkBuff);
	str_to_fixed(fileBlkBuff + OF_NAME, FILE_NAME_BYTES, fileName);
	fileBlkBuff ! OF_FILE_BLK := fileBlockNum;
	datetime2(fileBlkBuff + OF_DATE_MOD);
	clearRead(fileBlkBuff);
	clearWrite(fileBlkBuff);
	setLevel(fileBlkBuff, 0);
	setDetails(fileBlkBuff, 0b1000);
	fileBlkBuff ! OF_BYTE_SIZE := 0;
	fileBlkBuff ! OF_DATA_BLKS := 0;//Using file block, no additional data blocks
	veccpy(fileBlkBuff + OF_DATE_CREATED, fileBlkBuff + OF_DATE_MOD, SHORT_DATE_SIZE);
	fileBlkBuff ! OF_MOD_BLOCK := nil;//Not open
	fileBlkBuff ! OF_MOD_BYTE := nil;//Not open
	fileBlkBuff ! OF_BLK_BUFF := nil;//Not open
	fileBlkBuff ! OF_BLK_OFFSET := nil;//Not open
	
	str_to_fixed(fileEntry + FE_NAME, FILE_NAME_BYTES, fileName);
	fileEntry ! FE_FILE_BLK := fileBlockNum;
	veccpy(fileEntry + FE_DATE, fileBlkBuff + OF_DATE_MOD, SHORT_DATE_SIZE);
	addToRootDir(discPtr, fileEntry);
	writeBlockToDisc(discPtr ! DP_DISC_UNIT, fileBlockNum, fileBlkBuff);
	resultis fileEntry;
}

let deleteFileFromDisc(discPtr, fileBlkNum) be {
	let deletedFile = vec(BLOCK_SIZE), level;
	// out("Checking block: %d\n", fileBlkNum);
	readBlockFromDisc(discPtr ! DP_DISC_UNIT, fileBlkNum, deletedFile);
	level := getLevel(deletedFile);
	if level > 0 then {//Assuming 1 level of ptrs max
		for i = OF_DATA_START to BLOCK_SIZE - 1 by 1 do {
			test deletedFile ! i /= nil then 
				addFreeBlock(deletedFile ! i)
			else 
				break
		}
	}
	addFreeBlock(fileBlkNum);
}
let deleteFileFromRD(discPtr, fileName) be {
	let rootDir = discPtr ! DP_ROOT_DIR, rootDirBlock = discPtr ! DP_RD_BLOCK,
		discUnit = discPtr ! DP_DISC_UNIT, level = rootDir ! RD_LEVELS,
		entryBlock = vec(BLOCK_SIZE);
	test level = 1 then {
		for i = 0 to BLOCK_SIZE - 1 by 1 do {
			test rootDirBlock ! i /= nil then {
				readBlockFromDisc(discUnit, rootDirBlock ! i, entryBlock);
				for i = 0 to BLOCK_SIZE - 1 by FE_SIZE do {
					if strcasecmp(fileName, entryBlock + i) = 0 then {
						shiftArrUp(FE_SIZE, entryBlock + i, BLOCK_SIZE - i);		
						discPtr ! DP_ROOT_DIR ! RD_ENTRIES -:= 1;
						return;
					}
				}
			} else {
				return;
			}
		}
	} else test level = 0 then {
		for i = 0 to BLOCK_SIZE - 1 by FE_SIZE do {
			if strcasecmp(fileName, rootDirBlock + i) = 0 then {
				shiftArrUp(FE_SIZE, rootDirBlock + i, BLOCK_SIZE - i);
				discPtr ! DP_ROOT_DIR ! RD_ENTRIES -:= 1;
				break;
			}
		}
		return
	} else {
		out("We have reached a second level of ptrs and are not ready for this shit\n");
		finish;
	}
}

let printOpenList(openFileList) be {
	for i = 1 to openFileList ! OFL_ENTRIES do 
		out("%02d) %s\n", i, openFileList ! i + OF_NAME);
}
let removeFromOpenList(openFileList, fileIndex) be {
	shiftArrUp(1, openFileList + fileIndex, BLOCK_SIZE - fileIndex);
	openFileList ! OFL_ENTRIES -:= 1;
}
let findInOpenList(openFileList, fileName) be {	
	for i = 1 to openFileList ! OFL_ENTRIES do {
		if strcasecmp(fileName, openFileList ! i + OF_NAME) = 0 then resultis i;
	}
	resultis -1
}
let closeFile(discPtr, openFileIndex) be {
	let openFilePtr = discPtr ! DP_OPEN_LIST ! openFileIndex, buff = openFilePtr ! OF_BLK_BUFF;
	removeFromOpenList(discPtr ! DP_OPEN_LIST, openFileIndex);
	if openFilePtr ! OF_MOD_BYTE > openFilePtr ! OF_BYTE_SIZE then 
		openFilePtr ! OF_BYTE_SIZE := openFilePtr ! OF_MOD_BYTE;
	if buff /= openFilePtr then {
		writeBlockToDisc(discPtr ! DP_DISC_UNIT, openFilePtr ! OF_MOD_BLOCK, 
			openFilePtr ! OF_BLK_BUFF);//Writing back to disc
		freevec(buff);
	}	
	clearRead(openFilePtr);
	clearWrite(openFilePtr);
	writeBlockToDisc(discPtr ! DP_DISC_UNIT, openFilePtr ! OF_FILE_BLK, openFilePtr);//Writing back
	openFilePtr ! OF_MOD_BYTE := nil;
	openFilePtr ! OF_MOD_BLOCK := nil;
	openFilePtr ! OF_BLK_BUFF := nil;
	openFilePtr ! OF_BLK_OFFSET := nil;
	freevec(openFilePtr);
}
let closeAllFiles(discPtr) be {
	for i = 1 to discPtr ! DP_OPEN_LIST ! OFL_ENTRIES do 
		closeFile(discPtr, 1);
}
let addToOpenList(discPtr, openFilePtr) be {
	let choice, openFileList = discPtr ! DP_OPEN_LIST;
	if openFileList ! OFL_ENTRIES = (BLOCK_SIZE - 1) then {//Open List is full
		while true do {
			out("No room for open file, select one of the following to close:\n");
			printOpenList(openFileList);
			out("-1) To cancel opening %s\n", openFilePtr ! OF_NAME);
			choice := inno();
			test (0 < choice <= openFileList ! OFL_ENTRIES) then {
				closeFile(discPtr, choice);
				break;
			} else test choice = -1 then {
				freevec(openFilePtr ! OF_BLK_BUFF);
				freevec(openFilePtr);
				return;
			} else {
				out("Invalid choice!!!\n\n");
			}
		}
	}
	openFileList ! OFL_ENTRIES +:= 1;
	openFileList ! (openFileList ! OFL_ENTRIES) := openFilePtr;
}

let ls(discPtr) be {
	out("Number of Entries: %d\n", discPtr ! DP_ROOT_DIR ! RD_ENTRIES);
	listRootDir(discPtr ! DP_RD_BLOCK, discPtr ! DP_ROOT_DIR ! RD_LEVELS, discPtr ! DP_DISC_UNIT);
}
let lsOpenFiles(discPtr) be {
	printOpenList(discPtr ! DP_OPEN_LIST);
}
let deleteFile(discPtr, fileName) be {
	let fileEntry = findInRootDir(discPtr, fileName), 
		openListEntry = findInOpenList(discPtr ! DP_OPEN_LIST, fileEntry + FE_NAME);
	if openListEntry /= -1 then closeFile(discPtr, openListEntry);
	if fileEntry /= nil then {
		deleteFileFromDisc(discPtr, fileEntry ! FE_FILE_BLK);
		deleteFileFromRD(discPtr, fileName);
	}
	freevec(fileEntry);
}
let openFile(discPtr, fileName, function) be {
	let openFilePtr = newvec(BLOCK_SIZE), fileEntry = nil;
	if (findInOpenList(discPtr ! DP_OPEN_LIST, fileName) /= -1) then {
		out("File \'%s\' is already open\n", fileName);
		return;
	}
	fileEntry := findInRootDir(discPtr, fileName);
	test fileEntry = nil then {
		out("Creating new file : %s\n", fileName);
		fileEntry := createNewFile(discPtr, fileName);
	} else {
		out("Found the file : %s\n", fileName);
	}
	readBlockFromDisc(discPtr ! DP_DISC_UNIT, fileEntry ! FE_FILE_BLK, openFilePtr);
	freevec(fileEntry);
	if passedRead(function) > 0 then setRead(openFilePtr);
	if passedWrite(function) > 0 then setWrite(openFilePtr);

	test openFilePtr ! OF_DATA_BLKS > 0 then {		
		test (passedAppend(function) > 0) then {//Will open at end of last block
			openFilePtr ! OF_MOD_BLOCK := openFilePtr ! (OF_DATA_START + (openFilePtr ! OF_DATA_BLKS) - 1);
			openFilePtr ! OF_BLK_OFFSET := openFilePtr ! OF_BYTE_SIZE rem BYTES_PER_BLOCK;
			openFilePtr ! OF_MOD_BYTE := openFilePtr ! OF_BYTE_SIZE;
		} else {//Will open at beginning of first block
			openFilePtr ! OF_MOD_BLOCK := openFilePtr ! OF_DATA_START;
			openFilePtr ! OF_BLK_OFFSET := nil;
			openFilePtr ! OF_MOD_BYTE := nil;
		}
		openFilePtr ! OF_BLK_BUFF := newvec(BLOCK_SIZE);
		readBlockFromDisc(discPtr ! DP_DISC_UNIT, openFilePtr ! OF_MOD_BLOCK, openFilePtr ! OF_BLK_BUFF);
	} else {
		openFilePtr ! OF_BLK_BUFF := openFilePtr;
		openFilePtr ! OF_MOD_BYTE := (passedAppend(function) = 0) -> 0, OF_BYTE_SIZE - 1;
		openFilePtr ! OF_BLK_OFFSET := openFilePtr ! OF_MOD_BYTE + (OF_DATA_START * 4);
		openFilePtr ! OF_MOD_BLOCK := openFilePtr ! OF_FILE_BLK;
	}
	addToOpenList(discPtr, openFilePtr);
	resultis openFilePtr;
}

let formatDisc(discUnit, discName) be {
	let discSize, blockBuffer = vec(BLOCK_SIZE), tmpSuperBlock = vec(SB_SIZE), 
		discNameFixed = vec(SB_NAME_SIZE), rootNameFixed = vec(RD_NAME_SIZE),
		tmpRootDirMD = vec(RD_SIZE), tmpFreeList = vec(BLOCK_SIZE);
	discSize := checkDisk(discUnit);

	str_to_fixed(discNameFixed, SB_NAME_BYTES, discName);
	createSuperBlockMD(discUnit, discNameFixed, discSize, tmpSuperBlock);

	str_to_fixed(rootNameFixed, RD_NAME_BYTES, "RootDirectory");
	createRootDirMD(rootNameFixed, discUnit, tmpRootDirMD);
	clearBuffer(blockBuffer);//Super Block metadata and root dir meta data stored in SB
	for i = 0 to SB_SIZE - 1 by 1 do 
		blockBuffer ! i := tmpSuperBlock ! i;
	for i = 0 to RD_SIZE - 1 by 1 do 
		blockBuffer ! (SB_ROOT_DIR_INFO + i) := tmpRootDirMD ! i;
	writeSBtoDisc(discUnit, discSize, blockBuffer);	
	clearBuffer(blockBuffer);
	writeRDtoDisc(discUnit, discSize, blockBuffer);//clear at first
	createFreeList(tmpSuperBlock, tmpFreeList);
	writeFLtoDisc(discUnit, discSize, tmpFreeList);
}
let mountDisc(discUnit, name) be {
	let superblock, rootDir, rootDirBlock, freeList, blockBuffer, discPtr, openFileBlk, openList;
	checkDisk(discUnit);
	
	blockBuffer := newvec(BLOCK_SIZE);
	superblock := newvec(SB_SIZE);
	readBlockFromDisc(discUnit, SB_BLOCK_NUMBER, blockBuffer);
	memcpy(superblock, blockBuffer, SB_SIZE_BYTES);
	if strcasecmp(superblock + SB_DISC_NAME, name) /= 0 then {
		freevec(superblock);
		freevec(blockBuffer);
		out("Invaliid name, DiscName: %s | Name: %s\n", superblock + SB_DISC_NAME, name);
		resultis nil
	}
	rootDir := newvec(RD_SIZE);
	rootDirBlock := newvec(BLOCK_SIZE);
	freeList := newvec(BLOCK_SIZE);
	openList := newvec(OFL_SIZE);
	memcpy(rootDir, blockBuffer + SB_ROOT_DIR_INFO, RD_SIZE_BYTES);
	clearBuffer(blockBuffer);
	readBlockFromDisc(discUnit, RD_BLOCK_NUMBER, rootDirBlock);
	readBlockFromDisc(discUnit, FL_BLOCK_NUMBER, freeList);
	discPtr := newvec(DP_SIZE);
	createDiscPtr(discUnit, discPtr, superblock, rootDir, rootDirBlock, freeList, blockBuffer, openList);
	resultis(discPtr);
} 
let dismountDisc(discPtr) be {//discPtr is basically superblock
	let sizeFromCheck = checkDisk(discPtr ! DP_DISC_UNIT);
	if (discPtr ! DP_DISC_SIZE /= sizeFromCheck) then {
		out("Inconsistency between disc size for disc %d\n", 
			discPtr ! DP_DISC_UNIT);
		out("DISC * size: %d | Size of Disc: %d\n", 
			discPtr ! DP_DISC_SIZE, sizeFromCheck);
		finish;
	}
	closeAllFiles(discPtr ! DP_OPEN_LIST);
	clearBuffer(discPtr ! DP_BLOCK_BUFF);
	memcpy(discPtr ! DP_BLOCK_BUFF, discPtr ! DP_SUPER_BLOCK, SB_SIZE_BYTES);
	memcpy(discPtr ! DP_BLOCK_BUFF + SB_ROOT_DIR_INFO, discPtr ! DP_ROOT_DIR, RD_SIZE_BYTES);
	writeSBtoDisc(discPtr ! DP_DISC_UNIT, discPtr ! DP_DISC_SIZE, discPtr ! DP_BLOCK_BUFF);
	writeRDtoDisc(discPtr ! DP_DISC_UNIT, discPtr ! DP_DISC_SIZE, discPtr ! DP_RD_BLOCK);
	writeFLtoDisc(discPtr ! DP_DISC_UNIT, discPtr ! DP_DISC_SIZE, discPtr ! DP_FREE_LIST);
	
	freevec(discPtr ! DP_SUPER_BLOCK);
	freevec(discPtr ! DP_ROOT_DIR);
	freevec(discPtr ! DP_RD_BLOCK);
	freevec(discPtr ! DP_FREE_LIST);
	freevec(discPtr ! DP_BLOCK_BUFF);
	freevec(discPtr ! DP_OPEN_LIST);
	freevec(discPtr);
}

let writeByte(discPtr, filePtr, input) be {
	let isBackSpace, dataBlks = filePtr ! OF_DATA_BLKS, firstByte, lastByte, tmp;
	isBackSpace := (input = '\b' \/ input = 127) -> true, false;
	firstByte := (dataBlks > 0) -> 0, OF_DATA_START * 4;
	lastByte := BYTES_PER_BLOCK - 1;
	out("%c", input);
	test isBackSpace /= true then {
		if filePtr ! OF_BLK_OFFSET = lastByte then {
			test dataBlks > 0 then {//Assuming level 1 pointers for now
				writeBlockToDisc(discPtr ! DP_DISC_UNIT, filePtr ! OF_MOD_BLOCK, filePtr ! OF_BLK_BUFF);
				tmp := nil;
				for i = OF_DATA_START to BLOCK_SIZE - 1 do {
					if filePtr ! i = nil then {
						tmp := i;
						break;
					}
				}
				if tmp = nil then {
					out("Need to advance a level of pointers, not ready for this\n");
					return;
				}
				filePtr ! OF_MOD_BLOCK := filePtr ! tmp;
				if filePtr ! OF_MOD_BLOCK = nil then {
					filePtr ! OF_MOD_BLOCK := getFreeBlock(discPtr);
					filePtr ! tmp := filePtr ! OF_MOD_BLOCK;
					filePtr ! OF_DATA_BLKS +:= 1;
				}
				readBlockFromDisc(discPtr ! DP_DISC_UNIT, filePtr ! OF_MOD_BLOCK, filePtr ! OF_BLK_BUFF);
				filePtr ! OF_BLK_OFFSET := 0;
			} else {//Filling first block(file block)
				filePtr ! OF_BLK_BUFF := newvec(BLOCK_SIZE);
				veccpy(filePtr ! OF_BLK_BUFF, filePtr + OF_DATA_START, BLOCK_SIZE - OF_DATA_START);
				filePtr ! OF_DATA_START := getFreeBlock(discPtr);
				filePtr ! OF_DATA_BLKS +:= 1;
				for i = OF_DATA_START + 1 to BLOCK_SIZE - 1 do 
					filePtr ! i := nil;
				filePtr ! OF_MOD_BLOCK := filePtr ! OF_DATA_START;
				filePtr ! OF_MOD_BYTE := BLOCK_SIZE - OF_DATA_START;
				filePtr ! OF_BLK_OFFSET := BLOCK_SIZE - OF_DATA_START - 1;
			}
		}
		filePtr ! OF_BLK_OFFSET +:= 1;
		byte (filePtr ! OF_BLK_OFFSET) of filePtr ! OF_BLK_BUFF := input;
		filePtr ! OF_MOD_BYTE +:= 1;
	} else {
		if filePtr ! OF_BLK_OFFSET = firstByte then {
			test dataBlks > 0 then {
				addFreeBlock(discPtr, filePtr ! OF_MOD_BLOCK);
				filePtr ! OF_DATA_BLKS -:= 1;
				filePtr ! (OF_DATA_START + filePtr ! OF_DATA_BLKS) := nil;//Clearing freed block
				test dataBlks > 0 then {
					filePtr ! OF_MOD_BLOCK := filePtr ! (OF_DATA_START + filePtr ! OF_DATA_BLKS - 1);
					readBlockFromDisc(discPtr ! DP_DISC_UNIT, filePtr ! OF_MOD_BLOCK, filePtr ! OF_BLK_BUFF);
					printBlockBuffer(filePtr ! OF_BLK_BUFF);//To show there was a change
					filePtr ! OF_BLK_OFFSET := BYTES_PER_BLOCK - 1;
				} else {//Shift back to level 0
					freevec(filePtr ! OF_BLK_BUFF);//Not needed anymore
					filePtr ! OF_MOD_BLOCK := filePtr ! OF_FILE_BLK;
					filePtr ! OF_MOD_BYTE := 1;
					filePtr ! OF_BLK_BUFF := filePtr;
					filePtr ! OF_BLK_OFFSET := OF_DATA_START;
				}
			} else {//Cleared last character of file block, or nothing to erase
				filePtr ! OF_MOD_BLOCK := filePtr ! OF_FILE_BLK;
				filePtr ! OF_MOD_BYTE := 1;
				filePtr ! OF_BLK_BUFF := filePtr;
				filePtr ! OF_BLK_OFFSET := OF_DATA_START;
				vecset(filePtr ! OF_BLK_BUFF + OF_DATA_START, nil, BLOCK_SIZE - OF_DATA_START);
			}
		}

		filePtr ! OF_MOD_BYTE -:= 1;
	}
}
let eof(filePtr) be {
	resultis (filePtr ! OF_MOD_BYTE >= filePtr ! OF_BYTE_SIZE) -> true, false;
}
let readByte(discPtr, filePtr) be {
	let resChar, dataBlks, tmp;
	if eof(filePtr) then resultis -1;
	dataBlks := filePtr ! OF_DATA_BLKS;
	test filePtr ! OF_BLK_OFFSET < BLOCK_SIZE then {//There is data left in block
		resChar := byte (filePtr ! OF_BLK_OFFSET) of filePtr ! OF_BLK_BUFF;
	} else {//Already read everthing from current block, must pull other
		tmp := (OF_MOD_BYTE / BYTES_PER_BLOCK) - 1;
		filePtr ! OF_MOD_BLOCK := filePtr ! (OF_DATA_START + tmp);
		readBlockFromDisc(discPtr ! DP_DISC_UNIT, filePtr ! OF_MOD_BLOCK, filePtr ! OF_BLK_BUFF);
		resChar := byte 0 of filePtr ! OF_BLK_BUFF;
	}
	filePtr ! OF_BLK_OFFSET +:= 1;
	filePtr ! OF_MOD_BYTE +:= 1;
	resultis resChar;
}
let fwrite(discPtr, filePtr, buffer, nbytes) be {//size will be at most a block
	for i = 0 to nbytes - 1 do 
		writeByte(discPtr, filePtr, byte i of buffer);
	writeBlockToDisc(discPtr ! DP_DISC_UNIT, filePtr ! OF_MOD_BLOCK, filePtr ! OF_BLK_BUFF);
	resultis nbytes;
}
let fread(discPtr, filePtr, buffer, nbytes) be {
	let i = 0;
	while i < nbytes do {
		byte i of buffer := readByte(discPtr, filePtr);
		if byte i of buffer < 0 then break;
		i +:= 1;
	}
	resultis i;
}


let checkMountedDisc(discPtr) be {
	if discPtr = nil then {
		out("No disc is mounted!\n");
		resultis -1;
	}
	resultis 0
}
let getDiscUnit() be {
	out("Enter the disc unit then enter: ");
	resultis inno();
}
let getDiscName(discName) be {
	out("Enter disc name then enter: ");
	getline(discName, BLOCK_SIZE);
}

manifest {
	mounted = 0
}
static {
	mnt = "mount",
	dsmnt = "dismount",
	frmt = "format",
	open = "open",
	list = "ls",
	lsOpen = "lsOpen",
	del = "delete",
	cls = "close",
	ph = "printHeap",
	ex = "exit",
	wtof = "write",
	rfrf = "read",
	printBlock = "printB",
	printSB = "printSB",
	printRD = "printRD",
	printFL = "printFL"
}
let start() be {
	let discPtr = nil, input = vec(BLOCK_SIZE), discUnit, blkNumber, 
	fileEntry, inputSize, fileIndex, filePtr, inputOffset,
	discName = vec(SB_NAME_SIZE), fileName = vec(FILE_NAME_SIZE);

	init(heap, heapSize);
	out("You have started Julian's File System :) \n\n");
	out("You can use any of the following commands: \n");
	out("\tmount - to mount a disc into memory\n");
	out("\tdismount - to dismount a disc from memory\n");
	out("\tformat - to format a disc for use(will erase current memory on disc)\n");
	out("\topen - to open a file\n");
	out("\tls - to list all files in the root directory\n");
	out("\tlsOpen - to list all open files\n");
	out("\tdelete - to delete a specified file\n");
	out("\tclose - to close an open file\n");
	out("\twrite - to write to an open file\n");
	out("\tread - to read from a open file\n");
	out("\tprintHeap - to print the current heap data\n");
	out("\tprintBlock - to print the values in a given block\n");
	out("\texit - to exit file system\n");
	while true do {
		out("Enter a command: ");
		getline(input, BLOCK_SIZE);
		test strcasecmp(input, mnt) = 0 then {
			if discPtr /= nil then {
				out("Disc already mounted, must dismount first\n");
				loop;
			}
			discUnit := getDiscUnit();
			getDiscName(discName);
			discPtr := mountDisc(discUnit, discName);
			if checkMountedDisc(discPtr) = mounted then 
				out("Successfully mounted disc %s\n", discName)
		} else test strcasecmp(input, dsmnt) = 0 then {
			if checkMountedDisc(discPtr) /= mounted then loop;
			dismountDisc(discPtr);
			discPtr := nil;
			out("Dismounted disc %s\n", discName);
		} else test strcasecmp(input, frmt) = 0 then {
			discUnit := getDiscUnit();
			getDiscName(discName);
			out("DiscUnit: %d | DiscName: %s\n", discUnit, discName);
			formatDisc(discUnit, discName);
		} else test strcasecmp(input, open) = 0 then {
			if checkMountedDisc(discPtr) /= mounted then loop;
			out("Enter the file you wish to open/create: ");
			getline(fileName, FILE_NAME_BYTES);
			out("What permissions will you be giving the file(r for read, w for write, a for append)?");
			instr(input, BLOCK_SIZE);
			openFile(discPtr, fileName, input);
		} else test strcasecmp(input, list) = 0 then {
			if checkMountedDisc(discPtr) /= mounted then loop;
			ls(discPtr);
		} else test strcasecmp(input, lsOpen) = 0 then {
			if checkMountedDisc(discPtr) /= mounted then loop;
			lsOpenFiles(discPtr);
		} else test strcasecmp(input, del) = 0 then {
			if checkMountedDisc(discPtr) /= mounted then loop;
			out("Enter the file you wish to delete: ");
			getline(fileName, FILE_NAME_BYTES);
			deleteFile(discPtr, fileName);
		} else test strcasecmp(input, cls) = 0 then {
			if checkMountedDisc(discPtr) /= mounted then loop;
			out("Enter the file you wish to close: ");
			getline(fileName, FILE_NAME_BYTES);
 			fileIndex := findInOpenList(discPtr ! DP_OPEN_LIST, fileName);
 			if fileIndex = -1 then loop;
			closeFile(discPtr, fileIndex);
		} else test strcasecmp(input, ph) = 0 then {
			printHeap(heap, heapSize);
		} else test strcasecmp(input, printBlock) = 0 then {
			if checkMountedDisc(discPtr) /= mounted then loop;
			out("Enter the block number you want to print: ");
			blkNumber := inno();
			printBlockFromDisc(discUnit, blkNumber);
		} else test strcasecmp(input, printSB) = 0 then {
			if checkMountedDisc(discPtr) /= mounted then loop;
			printSuperBlock(discPtr ! DP_SUPER_BLOCK);
		} else test strcasecmp(input, printRD) = 0 then {
			if checkMountedDisc(discPtr) /= mounted then loop;
			printRootDir(discPtr ! DP_ROOT_DIR);
		} else test strcasecmp(input, printFl) = 0 then {
			if checkMountedDisc(discPtr) /= mounted then loop;
			printDiscFreeList(discPtr ! DP_FREE_LIST);
		} else test strcasecmp(input, wtof) = 0 then {
			if checkMountedDisc(discPtr) /= mounted then loop;
			out("What file do you want to write to?\n");
			getline(fileName, FILE_NAME_BYTES);
			fileEntry := findInRootDir(discPtr, fileName);
			fileIndex := findInOpenList(discPtr ! DP_OPEN_LIST, fileName);
			if fileEntry = nil \/ fileIndex = -1 then {
				out("File does not exist or is not open. Please open the file first.\n");
				freevec(fileEntry);
				loop;
			}
			filePtr := discPtr ! DP_OPEN_LIST ! fileIndex;
			out("How many bytes are you writing to the file?\n");
			inputSize := inno();
			for i = 0 to inputSize / BYTES_PER_BLOCK - 1 do {
				for j = 0 to BLOCK_SIZE - 1 do {
					byte j of input := inch();
				}
				if fwrite(discPtr, filePtr, input, BLOCK_SIZE) /= BLOCK_SIZE then {
					out("Problem writing to file! %s\n", filePtr + OF_NAME);
					loop;
				}
			}
			inputOffset := 0;
			for i = 0 to inputSize rem BYTES_PER_BLOCK - 1 do {
				byte i of input := inch();
				inputOffset +:= 1;
			}
			if fwrite(discPtr, filePtr, input, inputOffset) /= inputOffset then {
				out("Problem writing to file! %s\n", filePtr + OF_NAME);
				loop;
			}
		} else if strcasecmp(input, ex) = 0 then {
			if discPtr /= nil then dismountDisc(discPtr);
			break;
		}
	}
}