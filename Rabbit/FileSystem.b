
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
 *			32 will store the DIRTY | VALID bits for the file
 *			1 will store whether the file is a directory 
 *		RD_DATE_CREATED - long date of when created
 *		RD_SIZE - space needed to store the words above
 *
 *	File Entry
 *		FE_NAME of the file, maximum 24 characters long
 *		FE_FILE_PTR ptr to first block in a file
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

	FILE_NAME_SIZE = 5,
	FILE_NAME_BYTES = FILE_NAME_SIZE * 4;

	FE_NAME = 0, 
	FE_FILE_PTR = 5,
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
	SD_H_S_MS = 1, 		/*	5 most significant bits = hour
							6 next bits = minute
							6 next bits = second
							10 next bits = milliseconds
							5 least significant bits not used */

	SET = 1,
	UNSET = 0
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

manifest {//FILE * or OPEN_FILE(OF)
	OF_NAME = 0, 						//24 CHARS, 6 WORDS
	OF_DATE_MOD = 5, 					//LONG DATE, 7 WORDS
	OF_FILE_SIZE = 12,					//Size of file in bytes
	OF_DATA_BLKS = 13,					//number of data blocks being used
	OF_CAPACITY = 14, 					//Total number of bytes 
	OF_DATA_CREATED = 15,				//Short date, see datetime2(v) on documentation
	OF_LEVELS = 15,						//Uses last 3 bits of DATA_CREATED ! 0
	OF_DETAILS = 16, 					//Uses last 3 bits of DATA_CREATED ! 1
	OF_BLK_BUFF = 17,					//Ptr to block buffer
	OF_BLK_OFFSET = 18,					//Current offset in buffer
	OF_FE_BLOCK = 19,
	
	OF_SIZE = 20,
	OF_SIZE_BYTES = OF_SIZE * 4,
	OF_DATA_START = OF_SIZE, 	

	OF_EOF = 0b10101010101010101010101010101010
}

manifest { 
	heapSize = 8192,
	mounted = 0
}

static {
	heap = vec(heapSize),
	mnt = "mount",
	dsmnt = "dismount",
	frmt = "format",
	open = "open",
	list = "ls",
	lsOpen = "lsOpen",
	del = "delete",
	cls = "close",
	ph = "printHeap",
	ex = "exit"
}

//Disc Utilities
let clearBuffer(blkBuffer) be {
	for i = 0 to BLOCK_SIZE - 1 by 1 do 
		blkBuffer ! i := nil
}
let writeBlockToDisc(discUnit, blkNumber, blkBuffer) be {
	let res;
	res := devctl(DC_DISC_WRITE, discUnit, blkNumber, 1, blkBuffer);
	if res < 0 then {
		out("Could not write block to disc %d at block %d, please try again", discUnit, blkNumber);
		//Throw some interrupt or something
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
		out("%d\n", blkBuffer ! i);
	}
	out("\n\n");
}
let printBlockBuffer(blkBuffer) be {
	for i = 0 to BLOCK_SIZE - 1 by 1 do {
		out("%d\n", blkBuffer ! i);
	}
	out("\n\n");
}
let getBits(bit3, bit2, bit1) be {
	let details = 0;
	if bit3 = SET then details +:= 1;
	details := details << 1;
	if bit2 = SET then details +:= 1;
	details := details << 1;
	if bit1 = SET then details +:= 1;
	resultis details;
}
let clearBits(dataWord) be {
	resultis dataWord bitand 0b11111111111111111111111111111000;
}
let setBits(dataWord, bit3, bit2, bit1) be {
	resultis clearBits(dataWord) bitor getBits(bit3, bit2, bit1);
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
	out("Root Name: %s | Last Modified: %02d/%02d/%4d\n", rootDirBuff + RD_NAME,
		rootDirDate ! LD_MONTH, rootDirDate ! LD_DAY, rootDirDate ! LD_YEAR);
	out("Entries: %d | Capacity: %d | Levels: %d\n", 
		rootDirBuff ! RD_ENTRIES, rootDirBuff ! RD_CAPACITY, rootDirBuff ! RD_LEVELS);

	rootDirDate := rootDirBuff + RD_DATE_CREATED;
	out("Details: %05b | Created On: %02d/%02d/%4d\n\n\n", rootDirBuff ! RD_DETAILS,
		rootDirDate ! LD_MONTH, rootDirDate ! LD_DAY, rootDirDate ! LD_YEAR);
}
let printDiscFreeList(freeList) be {
	out("Free Blocks: %d | Ptr Blocks: %d\n", 
		freeList ! FL_FREE_BLKS,freeList ! FL_PTR_BLKS);
}
let printFileEntry(fileEntry) be {
	out("%s | BLK: %d | Last Modified: ", fileEntry + FE_NAME, fileEntry ! FE_FILE_PTR);
	printShortDate(fileEntry + FE_DATE);
	out("\n");
}

let createSuperBlockMD(discUnit, discNameFixed, discSize, tmpSuperBlock) be {
	let format_date = vec(LONG_DATE_SIZE), ptrBlocks;
	//Blocks_Size + 1 since a ptr block will can point to BLOCK_SIZE # of blocks, + 1 to round up 
	ptrBlocks := (discSize - BLOCKS_FOR_SYS) / (BLOCK_SIZE + 1) + 1; 
	datetime(seconds(), format_date);

	memcpy(tmpSuperBlock + SB_DISC_NAME, discNameFixed, SB_NAME_BYTES);
	tmpSuperBlock ! SB_DISC_SIZE := discSize;
	tmpSuperBlock ! SB_ROOT_DIR := RD_BLOCK_NUMBER;
	tmpSuperBlock ! SB_FREE_BLKS := discSize - BLOCKS_FOR_SYS - ptrBlocks;
	tmpSuperBlock ! SB_FREE_LIST := FL_BLOCK_NUMBER;
	memcpy(tmpSuperBlock + SB_FORMAT_TIME, format_date, LONG_DATE_BYTES);
	tmpSuperBlock ! SB_BLK_NUMBER := SB_BLOCK_NUMBER;
	tmpSuperBlock ! SB_COPY := discSize - 3;
	tmpSuperBlock ! SB_RD_CPY := discSize - 2;
	tmpSuperBlock ! SB_FL_CPY := discSize - 1;
	tmpSuperBlock ! SB_UNIT_NUM := discUnit;
}
let createRootDirMD(rootNameFixed, discUnit, tmpRootDirMD) be {
	let modDate = vec(LONG_DATE_SIZE), createDate = vec(LONG_DATE_SIZE);
	datetime(seconds(), modDate);
	datetime(seconds(), createDate);

	memcpy(tmpRootDirMD + RD_NAME, rootNameFixed, RD_NAME_BYTES);
	memcpy(tmpRootDirMD + RD_DATE_MOD, modDate, LONG_DATE_BYTES);
	tmpRootDirMD ! RD_ENTRIES := 0;
	tmpRootDirMD ! RD_CAPACITY := BLOCK_SIZE >> 3;//Divide by 2^3, 8 words per entry
	tmpRootDirMD ! RD_LEVELS := 0;
	tmpRootDirMD ! RD_DISC_UNIT := discUnit;
	tmpRootDirMD ! RD_DETAILS := setBits(tmpRootDirMD ! RD_DETAILS, UNSET, SET, SET);
	memcpy(tmpRootDirMD + RD_DATE_CREATED, createDate, LONG_DATE_BYTES);
}
let createFreeList(tmpSuperBlock, tmpFreeList) be {
	let tmpPtrBlock = vec(BLOCK_SIZE), discSize, discUnit, 
		ptrBlocks, curDataBlock, lastBlock;

		discSize := tmpSuperBlock ! SB_DISC_SIZE;
		discUnit := tmpSuperBlock ! SB_UNIT_NUM;
		
		clearBuffer(tmpFreeList);
		ptrBlocks := (discSize - BLOCKS_FOR_SYS) / (1 +  BLOCK_SIZE) + 1;
		tmpFreeList ! FL_FREE_BLKS := discSize - BLOCKS_FOR_SYS - ptrBlocks;
		tmpFreeList ! FL_PTR_BLKS := ptrBlocks;

		curDataBlock := 3;
		lastBlock := discSize - 4;
		for i = 0 to ptrBlocks - 1 by 1 do {
			tmpFreeList ! (FL_DATA + i) := curDataBlock;
			curDataBlock +:= 1;
			clearBuffer(tmpPtrBlock);
			for i = 0 to BLOCK_SIZE - 1 by 1 do {
				tmpPtrBlock ! i := curDataBlock;
				test curDataBlock < lastBlock then 
					curDataBlock +:= 1
				else
					break;
			}
			writeBlockToDisc(discUnit, tmpFreeList ! i, tmpPtrBlock);
			if curDataBlock = lastBlock then break;
		}
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

let shiftArrUp(n, aVector, vecSize) be {
	if (n < 1) then return;
	for i = 0 to vecSize - n - 1 by 1 do 
		aVector ! i := aVector ! (i + n);
	for i = vecSize - n to vecSize - 1 by 1 do
		aVector ! i := nil;
}
let shiftArrDown(n, aVector, vecSize) be {
	if n < 1 then return;
	for i = vecSize - 1 to n by -1 do 
		aVector ! i := aVector ! (i - n);
	for i = 0 to n - 1 by 1 do 
		aVector ! i := nil;
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
	let freeList = discPtr ! DP_FREE_LIST, ptrBlock, ptrBlockNum, slot, 
		discUnit = discPtr ! DP_DISC_UNIT;
	test freeList ! FL_PTR_BLKS > 0 then {
		for i = 0 to freeList ! FL_PTR_BLKS - 1 by 1 do {
			ptrBlockNum := freeList ! (FL_DATA + i);
			//Rare chance when all ptr blocks are full and freedBlock must become ptrBlock
			if ptrBlockNum = nil then {
				freeList ! (FL_DATA + i) := freedBlock;
				freeList ! FL_PTR_BLKS +:= 1;
				resultis 0;
			}
			//TODO May be able to use a bit with addr to signal empty or full
			readBlockFromDisc(discUnit, ptrBlockNum, ptrBlock);
			if ptrBlock ! (BLOCK_SIZE - 1) = nil then {//Room to add here
				slot := BLOCK_SIZE - 1;
				//Shifting slot up to highest empty slot
				until ptrBlock ! (slot - 1) /= nil do {
					slot -:= 1;
					if slot = 0 then break;
				}
				ptrBlock ! slot := freedBlock;
				writeBlockToDisc(discUnit, ptrBlockNum, ptrBlock);
				freeList ! FL_FREE_BLKS +:= 1;
				resultis 0;
			}
		}
	} else {
		slot := BLOCK_SIZE - 1;
		until freeList ! (slot - 1) /= nil do {
			slot -:= 1;
			if slot = FL_DATA then break;
		}
		freeList ! slot := freedBlock;
		freeList ! FL_FREE_BLKS +:= 1;
		resultis 0;
	}
}
let getFreeBlock(discPtr) be {
	let freeList = discPtr ! DP_FREE_LIST, freeBlk, ptrBlock, ptrBlockNum, 
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
		writeBlockToDisc(discUnit, freeList ! FL_DATA, ptrBlock);
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
	nBlocks := freeList ! FL_FREE_BLKS;//In case ptr block was added back as a free block 
	ptrBlocks := freeList ! FL_PTR_BLKS;//In case ptr block was added back as a free block

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
		for i = 0 to BLOCK_SIZE - 1 by 8 do {
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
						resultis rootDirBlock ! i;
					}
				}
			} else {//All previous blocks are full, must make ptr block
				rootDirBlock ! i := getFreeBlock(discPtr);
				readBlockFromDisc(discUnit, rootDirBlock ! i, entryBlock);
				clearBuffer(entryBlock);
				memcpy(entryBlock, fileEntry, FE_SIZE_BYTES);//First entry in block
				writeBlockToDisc(discUnit, rootDirBlock ! i, entryBlock);
				rootDir ! RD_ENTRIES +:= 1;
				resultis rootDirBlock ! i;
			}
		}
	} else test level = 0 then {
		for i = 0 to BLOCK_SIZE - 1 by FE_SIZE do {
			if rootDirBlock ! i = nil then {//Slot found
				memcpy(rootDirBlock + i, fileEntry, FE_SIZE_BYTES);
				rootDir ! RD_ENTRIES +:= 1;
				resultis RD_BLOCK_NUMBER;
			}
		} //rootDirBlock full, must use level of ptrs
		for i = 0 to BLOCK_SIZE - 1 by 1 do entryBlock ! i := rootDirBlock ! i;//Copying over
		clearBuffer(rootDirBlock);
		rootDirBlock ! 0 := getFreeBlock(discPtr);
		rootDirBlock ! 1 := getFreeBlock(discPtr);
		writeBlockToDisc(discUnit, rootDirBlock ! 0, entryBlock);
		clearBuffer(entryBlock);
		memcpy(entryBlock, fileEntry, FE_SIZE_BYTES);
		writeBlockToDisc(discUnit, rootDirBlock ! 1, entryBlock);
		resultis rootDirBlock ! 1;
	} else {
		out("We have reached a second level of ptrs and are not ready for this shit\n");
		finish;
	}
}
let createNewFile(discPtr, fileName) be {
	let fileBlockNum, rootDirSlot, fileBlkBuff = vec(BLOCK_SIZE),secondsMod = seconds(),
		fileEntry = newvec(FE_SIZE), rootDir = discPtr ! DP_ROOT_DIR;
	fileBlockNum := getFreeBlock(discPtr);
	str_to_fixed(fileBlkBuff + OF_NAME, FILE_NAME_BYTES, fileName);
	datetime(secondsMod, fileBlkBuff + OF_DATE_MOD);
	fileBlkBuff ! OF_FILE_SIZE := 0;
	fileBlkBuff ! OF_DATA_BLKS := 1;
	fileBlkBuff ! OF_CAPACITY := BLOCK_SIZE - OF_SIZE - 1;//Minus 1 for EOF word
	datetime2(fileBlkBuff + OF_DATA_CREATED);
	fileBlkBuff ! OF_LEVELS := clearBits(fileBlkBuff ! OF_LEVELS);
	fileBlkBuff ! OF_DETAILS := setBits(fileBlkBuff ! OF_DETAILS, UNSET, SET, UNSET);
	fileBlkBuff ! OF_BLK_BUFF := nil;//not open yet
	fileBlkBuff ! OF_BLK_OFFSET := nil;//not open yet
	fileBlkBuff ! OF_DATA_START := OF_EOF;//Empty at first

	memcpy(fileEntry + FE_NAME, fileName, FILE_NAME_BYTES);
	fileEntry ! FE_FILE_PTR := fileBlockNum;
	fileEntry ! FE_DATE := fileBlkBuff ! OF_DATA_CREATED;
	fileEntry ! FE_DETAILS := fileBlkBuff ! OF_DETAILS;	
	fileBlkBuff ! OF_FE_BLOCK := addToRootDir(discPtr, fileEntry);
	resultis fileEntry;
}
let deleteFileFromDisc(discPtr, fileName, fileBlkNum) be {
	let deletedFile = vec(BLOCK_SIZE), fileData = deletedFile + OF_DATA_START,
		level = deletedFile ! OF_LEVELS;
	readBlockFromDisc(discPtr ! DP_DISC_UNIT, fileBlkNum, deletedFile);
	if level = 1 then {
		for i = OF_DATA_START to BLOCK_SIZE - 1 by 1 do {
			test deletedFile ! i /= nil then 
				addFreeBlock(deletedFile ! i)
			else 
				break
		}
	} 
	if level > 1 then {
		out("We have reached a second level of ptrs and are not ready for this shit\n");
		finish;
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
		out("%02d) %s\n", i, (openFileList ! i) + OF_NAME);
}
let removeFromOpenList(openFileList, fileIndex) be {
	shiftArrUp(1, openFileList + fileIndex, BLOCK_SIZE - fileIndex);
	openFileList ! OFL_ENTRIES -:= 1
}
let findInOpenList(openFileList, fileName) be {	
	for i = 1 to openFileList ! OFL_ENTRIES do {
		if strcasecmp(fileName, openFileList + OF_NAME) = 0 then resultis i;
	}
	resultis -1
}
let closeFile(discPtr, filePtr) be {
	let fileEntry = findInRootDir(discPtr, filePtr ! OF_NAME), fileBuff = filePtr ! OF_BLK_BUFF;
	shiftBlockBufferDown(OF_SIZE, fileBuff);
	filePtr ! OF_BLK_OFFSET +:= OF_SIZE;
	memcpy(fileBuff, filePtr, OF_SIZE_BYTES);//COPYING FILE METADATA BACK TO BUFFER
	writeBlockToDisc(discPtr ! DP_DISC_UNIT, fileEntry ! FE_FILE_PTR, filePtr ! OF_BLK_BUFF);
	freevec(fileBuff);
	freevec(fileEntry);
	removeFromOpenList(discPtr ! DP_OPEN_LIST, findInOpenList(filePtr ! OF_NAME));
	freevec(filePtr);
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
				closeFile(discPtr, openFileList ! choice);
				removeFromOpenList(openFileList, choice);
				break;
			} else test choice = -1 then {
				closeFile(discPtr, openFilePtr);
				return;
			} else {
				out("Invalid choice!!!\n\n");
			}
		}
	}
	openFileList ! OFL_ENTRIES +:= 1;
	openFileList !+ (openFileList ! OFL_ENTRIES) := openFilePtr;
}

let ls(discPtr) be {
	let rootDirBlock = discPtr ! DP_RD_BLOCK;
	listRootDir(rootDirBlock, discPtr ! DP_ROOT_DIR ! RD_LEVELS, discPtr ! DP_DISC_UNIT);
}
let lsOpenFiles(discPtr) be {
	printOpenList(discPtr ! DP_OPEN_LIST);
}
let deleteFile(discPtr, fileName) be {
	let fileEntry = findInRootDir(discPtr, fileName), openListEntry;
	if fileEntry /= nil then {
		deleteFileFromDisc(discPtr, fileName, fileEntry ! FE_FILE_PTR);
		deleteFileFromRD(discPtr, fileName);
	}
	openListEntry := findInOpenList(discPtr ! DP_OPEN_LIST, fileEntry + FE_NAME);
	if openListEntry /= -1 then removeFromOpenList(discPtr ! DP_OPEN_LIST, openListEntry);
}
let openFile(discPtr, fileName) be {
	let openFilePtr = newvec(OF_SIZE), fileEntry = nil, blockBuffer = newvec(BLOCK_SIZE);
	fileEntry := findInRootDir(discPtr ! DP_ROOT_DIR, fileName);
	test fileEntry = nil then {
		fileEntry := createNewFile(discPtr, fileName);
		out("Creating new file : %s\n", fileName);
		printHeap(heap, heapSize);
	} else {
		out("Found the file : %s\n", fileName);
	}
	readBlockFromDisc(discPtr ! DP_DISC_UNIT, fileEntry ! FE_FILE_PTR, blockBuffer);
	freevec(fileEntry);
	memcpy(openFilePtr, blockBuffer, OF_SIZE_BYTES);
	shiftBlockBufferUp(OF_SIZE, blockBuffer);//Shifting buffer up
	openFilePtr ! OF_BLK_BUFF := blockBuffer;
	openFilePtr ! OF_BLK_OFFSET := 0;
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
	memset(rootDir, nil, RD_SIZE_BYTES);
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
	clearBuffer(discPtr ! DP_BLOCK_BUFF);
	memcpy(discPtr ! DP_BLOCK_BUFF, discPtr ! DP_SUPER_BLOCK, SB_SIZE_BYTES);
	memcpy(discPtr ! DP_BLOCK_BUFF + SB_ROOT_DIR_INFO, discPtr, DP_ROOT_DIR, RD_SIZE_BYTES);
	writeSBtoDisc(discPtr ! DP_DISC_UNIT, discPtr ! DP_DISC_SIZE, discPtr ! DP_BLOCK_BUFF);
	writeRDtoDisc(discPtr ! DP_DISC_UNIT, discPtr ! DP_DISC_SIZE, discPtr ! DP_RD_BLOCK);
	writeFLtoDisc(discPtr ! DP_DISC_UNIT, discPtr ! DP_DISC_SIZE, discPtr ! DP_FREE_LIST);
	
	freevec(discPtr ! DP_SUPER_BLOCK);
	freevec(discPtr ! DP_ROOT_DIR);
	freevec(discptr ! DP_RD_BLOCK);
	freevec(discPtr ! DP_FREE_LIST);
	freevec(discPtr ! DP_BLOCK_BUFF);
	freevec(discPtr ! DP_OPEN_LIST);
	freevec(discPtr);
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

let start() be {
	let discPtr = nil, input = vec(BLOCK_SIZE), discUnit,
		discName = vec(SB_NAME_SIZE), fileName = vec(FILE_NAME_SIZE),
		filePtr, fileIndex;

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
	out("\tprintHeap - to print the current heap data\n");
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
			// out("DiscUnit: %d | DiscName: %s\n", discUnit ! 0, discName);
			discPtr := mountDisc(discUnit, discName);
			printHeap(heap, heapSize);
			if checkMountedDisc(discPtr) = mounted then 
				out("Successfully mounted disc %s\n", discName)
		} else test strcasecmp(input, dsmnt) = 0 then {
			if checkMountedDisc(discPtr) /= mounted then loop;
			dismountDisc(discPtr);
			printHeap(heap, heapSize);
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
			getline(fileName, FILE_NAME_SIZE);
			openFile(discPtr, fileName);
		} else test strcasecmp(input, list) = 0 then {
			if checkMountedDisc(discPtr) /= mounted then loop;
			ls(discPtr);
		} else test strcasecmp(input, lsOpen) = 0 then {
			if checkMountedDisc(discPtr) /= mounted then loop;
			lsOpenFiles(discPtr);
		} else test strcasecmp(input, del) = 0 then {
			if checkMountedDisc(discPtr) /= mounted then loop;
			out("Enter the file you wish to delete: ");
			getline(fileName, FILE_NAME_SIZE);
			deleteFile(discPtr, fileName);
		} else test strcasecmp(input, cls) = 0 then {
			if checkMountedDisc(discPtr) /= mounted then loop;
			out("Enter the file you wish to close: ");
			getline(fileName, FILE_NAME_SIZE);
 			fileIndex := findInOpenList(discPtr ! DP_OPEN_LIST, fileName);
 			if fileIndex = -1 then loop;
 			filePtr := discPtr ! DP_OPEN_LIST ! fileIndex;
			closeFile(discPtr, filePtr);
		} else test strcasecmp(input, ph) = 0 then {
			printHeap(heap, heapSize);
		} else if strcasecmp(input, ex) = 0 then {
			if discPtr /= nil then dismountDisc(discPtr);
			break;
		}
	}
}


