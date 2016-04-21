import "newHeap"
import "string"

manifest {
	SB_BLOCK_NUMBER = 0,						//On disc will be first block

	SB_DISC_NAME = 0,							//32 Characters, 4 Words for DISC_NAME
	SB_DISC_SIZE = 8,
	SB_FREE_BLKS = 9,
	SB_FREE_DIR_BLK = 10,
	SB_USED_DIR_BLK = 11, 
	SB_FORMAT_TIME = 12,							//7 Words Needed
	SB_BLK_NUMBER = 19,
	SB_BLK_COPY = 20,
	SB_UNIT_NUM = 21,
	SB_SIZE = 22,
	SB_BYTES_SIZE = 88,

	SB_NAME_SIZE = 8,
	SB_NAME_BYTES = 32,							//Storing length of name in characters
	SB_FORMAT_TIME_BYTES = 28,

	BLOCKS_FOR_SYS = 4,
	BLOCK_SIZE = 128,
	BYTES_PER_BLOCK = BLOCK_SIZE * 4
}

let clearBlkBuffer(blockBuff) be {
	for i = 0 to BLOCK_SIZE - 1 by 1 do 
		blockBuff ! i := nil
}

let createSuperBlock(discUnit, discName, discSize) be {
	let superBlock = vec(SB_SIZE), date = vec(7), blocksForMgnmnt;

	memcpy(superBlock ! SB_DISC_NAME, discName, SB_NAME_BYTES);
	superBlock ! SB_DISC_SIZE := discSize;

	blocksForMgnmnt := (discSize - BLOCKS_FOR_SYS) / (1 + BLOCK_SIZE);
	if (discSize - BLOCKS_FOR_SYS) rem (1 + BLOCK_SIZE) > 0 then blocksForMgnmnt +:= 1;
	superBlock ! SB_FREE_BLKS := discSize - BLOCKS_FOR_SYS - blocksForMgnmnt;
	
	superBlock ! SB_FREE_DIR_BLK := 1;
	superBlock ! SB_USED_DIR_BLK := 2;
	datetime(seconds(), date);
	memcpy(superBlock ! SB_FORMAT_TIME, date, SB_FORMAT_TIME_BYTES);
	superBlock ! SB_BLK_NUMBER := SB_BLOCK_NUMBER;//FIRST BLOCK IN DISC
	superBlock ! SB_BLK_COPY := discSize - 1;//LAST BLOCK IN DISC
	superBlock ! SB_UNIT_NUM := discUnit;

	resultis superBlock;
}

let createFreeList(superBlock) be {
	let freeListBlk = vec(BLOCK_SIZE), ptrBlockBuff = vec(BLOCK_SIZE), discSize, discUnit,
		blocksForMgnmnt, numOfBlksUsed, totalFreeBlks, curBlock;

	discSize := superBlock ! SB_DISC_SIZE;
	discUnit := superBlock ! SB_UNIT_NUM;

	clearBlkBuffer(freeListBlk);
	

	blocksForMgnmnt := (discSize - BLOCKS_FOR_SYS) / (1 + BLOCK_SIZE);
	if (discSize - BLOCKS_FOR_SYS) rem (1 + BLOCK_SIZE) > 0 then blocksForMgnmnt +:= 1;
	
	totalFreeBlks := superBlock ! SB_FREE_BLKS;

	curBlock := BLOCKS_FOR_SYS - 1;//-1 since cpy of SB is after all data
	numOfBlksUsed := 0;

	for i = 0 to BLOCK_SIZE - 1 by 1 do {//Populating FREE_LIST_BLOCK
		freeListBlk ! i := curBlock;
		curBlock +:= 1;
		numOfBlksUsed +:= 1;
		clearBlkBuffer(ptrBlockBuff);
		for db = 0 to BLOCK_SIZE - 1 by 1 do {
			if (numOfBlksUsed = totalFreeBlks) then break;
			ptrBlockBuff ! db := curBlock;
			curBlock +:= 1;
			numOfBlksUsed +:= 1;
		}
		if devctl(DC_DISC_WRITE, discUnit, freeListBlk ! i, 1, ptrBlockBuff) < 0 then {
			out("Error writing to disc %d, for block number %d \n", discUnit, freeListBlk ! i);
			resultis -1;
		}
		out("Page %d in free list written succesfully.\n", i);
		if (numOfBlksUsed = totalFreeBlks) then break;
	}
	if devctl(DC_DISC_WRITE, discUnit, superBlock ! SB_FREE_DIR_BLK, 1, freeListBlk) < 0 then {
		out("Error writing to disc %d, super block free dir %d \n", discUnit, superBlock ! SB_FREE_DIR_BLK);
		resultis -1;
	}
}

let formatDisc(discUnit, discName) be {
	let results, buffer = vec(BLOCK_SIZE), discSize, 
		superBlock, discNameFixed = vec(SB_NAME_SIZE);

	discSize := devctl(DC_DISC_CHECK, discUnit);
	out("Disc #%d has size of %d blocks\n", discUnit, discSize);
	if (discSize = 0) then {
		out("Disc #%d is not available for use\n", discUnit);
		resultis -1;
	}
	clearBlkBuffer(buffer);

	str_to_fixed(discNameFixed, SB_NAME_BYTES, discName);

	superBlock := createSuperBlock(discUnit, discNameFixed, discSize);
	memcpy(buffer, superBlock, BYTES_PER_BLOCK);
	if devctl(DC_DISC_WRITE, discUnit, SB_BLOCK_NUMBER, 1, superBlock) < 0 then {
		out("Could not write the SB to disc %d, please try again", discUnit);
		resultis -2;
	}

	if devctl(DC_DISC_WRITE, discUnit, discSize - 1, 1, superBlock) < 0 then {//Copy of SB
		out("Could not write SB_BLK_COPY to disc %d, please try again", discUnit);
		resultis -3;
	}
	createFreeList(superBlock);
	clearBlkBuffer(buffer);
	if devctl(DC_DISC_WRITE, discUnit, superBlock ! SB_USED_DIR_BLK, 1, buffer) < 0 then {//Copy of SB
		out("Could not write SB_USED_DIR_BLK to disc %d, please try again", discUnit);
		resultis -4;
	}
}

let mountDisc(discUnit, discName) be {
	let r, discPtr = newvec(SB_SIZE), buff = vec(BLOCK_SIZE), nameStr = vec(SB_NAME_SIZE + 1);
	if devctl(DC_DISC_CHECK, discUnit) = 0 then {
		out("Disc #%d is not available for use\n", discUnit);
		resultis -1;
	}

	if devctl(DC_DISC_READ, discUnit, SB_BLOCK_NUMBER, 1, buff) < 0 then {
		out("Could not read Disc #%d for DISC *\n", discUnit);
		resultis -2;
	}
	memcpy(discPtr, buff, SB_BYTES_SIZE);//discPtr now contains SB data
	if discUnit /= discPtr ! SB_UNIT_NUM then {
		out("Disc Unit Number does not match, passed: %d | onDisc: %d\n", 
			discUnit, discPtr ! SB_UNIT_NUM);
		resultis -3;
	}

	memset(nameStr, nil, SB_NAME_BYTES + 4);//Clearing nameStr just in case
	fixed_to_str(nameStr, discPtr ! SB_DISC_NAME, SB_NAME_BYTES);//Copying name in as string
	if (strcasecmp(nameStr, discName) /= 0) then {
		out("Disc Name does not match, passed: %s | onDisc: %s\n", discName, nameStr);
		resultis -4;
	}

	out("succesfully mounted disc #%d\n", discUnit);
	resultis discPtr;
}

let dismountDisc(discPtr) be {
	let discUnit = discPtr ! SB_UNIT_NUM, buffer = vec(BLOCK_SIZE), 
		res, discSize = discPtr ! SB_DISC_SIZE;
	res := devctl(DC_DISC_CHECK, discUnit);
	if res = 0 \/ res /= discSize then {
		out("Error dismounting disc #%d. Size read: %d | Size on SB: %d\n", 
			discUnit, res, discSize);
		resultis -1;
	}
	memset(buffer, nil, BYTES_PER_BLOCK);
	memcpy(buffer, discPtr, SB_BYTES_SIZE);
	if devctl(DC_DISC_WRITE, discUnit, SB_BLOCK_NUMBER, 1, buffer) < 0 then {
		out("Could not write back the super block to disc %d, please try again", discUnit);
		resultis -1;
	}

	if devctl(DC_DISC_WRITE, discUnit, discSize - 1, 1, buffer) < 0 then {//Copy of SB
		out("Could not write back the super block copy to disc %d, please try again", discUnit);
		resultis -1;
	}
	freevec(discPtr);
}

//File Utilities

/**
	@params - freeListBlk is the freeListBlk of a SB for a disc
	@returns - the blkNumber of a free block, negative number on error
	The free block is removed from the freeBlkList, whatever calls getFreeBlock
		must make sure to allocate it to an open file or place back into the free list
**/
let getFreeBlock(discPtr, freeListBlk) be {
	let freeBlk = -1, ptrBlkBuffer = vec(BLOCK_SIZE), empty = 0, ptrTemp, discUnit = discPtr ! SB_UNIT_NUM;
	if (freeListBlk ! 0 = nil) then {
		out("There are no free blocks in disc %d\n", discUnit);
		resultis -1;
	}

	if devctl(DC_DISC_READ, discUnit, freeListBlk ! 0, 1, ptrBlkBuffer) < 0 then {
		out("Could not read ptrBlock(0) from free list in disc %d\n", discUnit);
		resultis -2;
	}

	freeBlk := ptrBlkBuffer ! 0;
	for i = 0 to BLOCK_SIZE - 2 by 1 do //Shifts all ptrs up
		ptrBlkBuffer ! i := ptrBlkBuffer ! (i + 1);
	ptrBlkBuffer ! (BLOCK_SIZE - 1) := nil;

	if (ptrBlkBuffer ! 0 = nil) then empty := 1;

	if empty = 1 then {//Top ptr block is empty, shifting blocks then adding block to freelist
		ptrTemp := freeListBlk ! 0;//Saving the empty blocks number
		for i = 0 to BLOCK_SIZE - 2 by 1 do //Shifts all ptr blocks up
			freeListBlk ! i := freeListBlk ! (i + 1);
		freeListBlk ! (BLOCK_SIZE - 1) := nil;
		addToFreeList(ptrTemp, freeListBlk);//Recycling
	}
	discPtr ! SB_FREE_BLKS -:= 1;
	resultis freeBlk;
}

/**
	@params - blkNumber is the block being freed and added to the free list
	@params - freeListBlk is the freeListBlk of a SB for a disc
	
	@returns - 0 on success or a negative number upon error
	The freed block will be placed in the first ptrBlk with an available ptr
**/
let addToFreeList(blkNumber, discPtr, freeListBlk) be {
	let ptrBlkBuffer = vec(BLOCK_SIZE), slotNum = -1, discUnit = discPtr ! SB_UNIT_NUM;
	if discPtr ! SB_FREE_BLKS = 0 then {
		out("Te jodiste, no hay cama pa tanta gente en casa %d(Disc Unit)\n", discUnit);
		resultis -1;
	}
	for i = 0 to BLOCK_SIZE - 1 by 1 do {
		if freeListBlk ! i = nil then {//Empty ptr in free list so all previous ptrBlks are full
			freeListBlk ! i := getFreeBlock(discPtr, freeListBlk);
			clearBlkBuffer(ptrBlkBuffer);
			if devctl(DC_DISC_WRITE, discUnit, freeListBlk ! i, 1, ptrBlkBuffer) < 0 then {
				out("Could not clear newly added block(#%d) for free ptr list\n", freeListBlk ! i);
				resultis -2;
			}
		}
		if devctl(DC_DISC_READ, discUnit, freeListBlk ! i, 1, ptrBlkBuffer) < 0 then {
			out("Could not read ptrBlock(%d) from free list in disc %d\n", i, discUnit);
			resultis -3;
		}

		if ptrBlkBuffer ! (BLOCK_SIZE - 1) = nil then {//Space to insert freeblk
			slotNum := BLOCK_SIZE - 1;
			for i = BLOCK_SIZE - 2 to 0 by -1 do {
				test ptrBlkBuffer ! i = nil then {//If top is clear, store value
					slotNum := i;
				else //If not empty found highest open slot
					break;
			}	
			ptrBlkBuffer ! slotNum := blkNumber;
			break;
		}
	}
	discPtr ! SB_FREE_BLKS +:= 1;
	resultis 0;
}















