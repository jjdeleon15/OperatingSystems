export { outch, outno, outhex, outbin, outf, outs, out, inch, inch2, inno, numbargs, 
	       lhs, thiscall, returnto, sleep,seconds, datetime, datetime2, devctl, 
         devctlv, strlen, random,set_kb_buffer, printLongDate, printShortDate, 
         init, newvec, freevec, printHeap, printHeapEntry, printFreeList,
         DC_DISC_CHECK, DC_DISC_READ, DC_DISC_WRITE, DC_TAPE_CHECK, 
         DC_TAPE_READ, DC_TAPE_WRITE, DC_TAPE_REWIND, DC_TAPE_LOAD, 
         DC_TAPE_UNLOAD, DC_TERMINC, DC_TERMINW, DC_TERMOUTC, 
         DC_TERMOUTW, DC_SECONDS, DC_USECONDS, DC_DATETIME }

manifest
{ DC_DISC_CHECK = 0,
  DC_DISC_READ = 1,
  DC_DISC_WRITE = 2,
  DC_TAPE_CHECK = 3,
  DC_TAPE_READ = 4,
  DC_TAPE_WRITE = 5,
  DC_TAPE_REWIND = 6,
  DC_TAPE_LOAD = 7,
  DC_TAPE_UNLOAD = 8,
  DC_TERMINC = 9,
  DC_TERMINW = 10,
  DC_TERMOUTC = 11,
  DC_TERMOUTW = 12,
  DC_SECONDS = 13,
  DC_USECONDS = 14,
  DC_DATETIME = 15,
  DC_LAST_CODE = 15 }

let numbargs() be
{ assembly
  { load  R1, [FP]
    load  R1, [R1+2]
    div   R1, 2 } }

let lhs() be
{ assembly
  { load  R1, [FP]
    load  R1, [R1+2]
    and   R1, 1
    rsub  R1, 0 } }

let thiscall() be
{ assembly { load  R1, [FP] } }

let returnto(frame, value) be
{ assembly
  { load  R2, FP
    load  R4, [<frame>]
    load  R1, [<value>]
    load  SP, R2
    load  R2, [R2]
    comp  R2, R4
    jcond neq, PC-4
    load  R5, [SP+1]
    add   SP, 2
    load  FP, R2
    jump  R5 } }

let outch(c) be
{ assembly { type [<c>] } }

let outno(n) be
{ if n<0 then
  { n := -n;
    outch('-') }
  if n>9 then outno(n/10);
  outch('0' + n rem 10) }

let outnow(n, w, f) be
{ let b = vec 12, sgn = false, sz = 0;
  if n<0 then
  { sgn := true;
    n := - n }
  { b ! sz := '0' + n rem 10;
    sz +:= 1;
    n /:= 10 } repeatuntil n = 0;
  if sgn then
  { if f = '0' then
    { outch('-');
      sgn := 0 }
    w -:= 1 }
  for i = sz+1 to w do
    outch(f);
  if sgn then
    outch('-');
  while sz > 0 do
  { sz -:= 1;
    outch(b ! sz) } }

let bitsin(n) be
{ for i = 32 to 1 by -1 do
  { n := n rotl 1;
    if n bitand 1 then resultis i }
  resultis 0 }

let outhex(n) be
{ let outhex1(n) be
  { test n<10 then
      outch('0' + n)
    or
      outch('A' + n - 10) }
  let s = 28, pr = false;
  while s >= 0 do
  { let d = n >> s bitand 15;
    if d <> 0 then pr := true;
    if pr then outhex1(d);
    s := s - 4 }
  if not pr then outch('0') }

let outhexw(n, wide, fill) be
{ let pad = wide - 1 - (bitsin(n) - 1)/4;
  while pad > 0 do
  { outch(fill);
    pad -:= 1 }
  outhex(n) }

let outbin(n) be
{ let c = 0, pr = false, d;
  while c < 32 do
  { n := n rotl 1;
    d := n bitand 1;
    if d <> 0 then pr := true;
    if pr then outch('0' + d);
    c := c + 1 }
  if not pr then outch('0') }

let outbinw(n, wide, fill) be
{ let pad = wide - bitsin(n);
  if n = 0 then pad := wide - 1;
  while pad > 0 do
  { outch(fill);
    pad -:= 1 }
  outbin(n) }

let outf(n) be
{ let e = 0, c = 0, mil = 1000000.0;
  test n #< 0.0 then
  { outch('-');
    n := #- n }
  or
    outch('+');
  while n #>= 10.0 do
  { e := e + 1;
    n := n #/ 10.0 }
  unless n #= 0.0 do
    while n #< 1.0 do
    { e := e - 1;
      n := n #* 10.0 }
  assembly
  { load  r1, [<n>]
    fmul  r1, [<mil>]
    frnd  r1, r1
    fdiv  r1, [<mil>]
    store r1, [<n>] }
  outch('0' + fix n);
  outch('.');
  while c < 6 do
  { n := n #- float fix n;
    n := n #* 10.0;
    outch('0' + fix n);
    c := c + 1 }
  outch('e');
  test e < 0 then
  { outch('-');
    e := - e }
  or
    outch('+');
  test e >= 100 then
    outno(e)
  or
  { outch('0' + e / 10);
    outch('0' + e rem 10) } }

let outs(s, w) be
{ let len = 0, minw = w, maxw = w;
  if s = nil then return;
  if numbargs() = 1 \/ w = 0 then
  { minw := 0;
    maxw := 999999 }
  while len < maxw do
  { let c = byte len of s;
    if c = 0 then break;
    outch(c);
    len +:= 1 }
  while len < minw do
  { outch(' ');
    len +:= 1 } }

let strlen(s) be
{ let i = 0;
  until byte i of s = 0 do
    i +:= 1;
  resultis i }

let out(format) be
{ let i = 0, an = 1, na = numbargs(), arg = @format;
  if format = nil then return;
  while true do
  { let c = byte i of format;
    if c = 0 then break;
    test c = '%' then
    { let c = byte i+1 of format, av = 0, wide = 0, fill = ' ';
      if c = 0 then
      { outch('%');
        break }
      i +:= 1;
      if c = '0' then
      { fill := '0';
        i +:= 1; 
        c := byte i of format; }
      while c >= '0' /\ c <= '9' do
      { wide := wide * 10 + c - '0';
        i +:= 1; 
        c := byte i of format; }
      if an <= na then av := arg!an;
      an +:= 1;
      test c = 'd' then
        test wide > 0 then
          outnow(av, wide, fill)
        or
          outno(av)
      or test c = 'f' then
        outf(av)
      or test c = 's' then
        outs(av, wide)
      or test c = 'c' then
        outch(av)
      or test c = 'x' then
        test wide > 0 then
          outhexw(av, wide, fill)
        or
          outhex(av)
      or test c = 'b' then
        test wide > 0 then
          outbinw(av, wide, fill)
        or
          outbin(av)
      or
      { outch('%');
        outch(c) } }
    or
      outch(c);
    i := i + 1 } }

let inch_unbuff() be
{ assembly
  { inch  R1
    jpos  R1, PC+2
    pause
    jump  PC-4 } }

static { buffer = vec 301, buff_num = 0, buff_ptr = 0, buff_max = 1200 }

let set_kb_buffer(v, size) be
{ if size<2 then return;
  buffer := v;
  buff_num := 0;
  buff_ptr := 0;
  buff_max := (size-1)*4 }

let inch() be
{ if buff_num > buff_ptr then
  { let c = byte buff_ptr of buffer;
    buff_ptr +:= 1;
    resultis c }
  buff_ptr := 1;
  buff_num := 0;
  while true do
  { let c = inch_unbuff();
    if c = 8 \/ c = 127 then
    { if buff_num > 0 then
      { buff_num -:= 1;
        out("%c %c", 8, 8) }
      loop }
    outch(c);
    byte buff_num of buffer := c;
    unless buff_num > buff_max do buff_num +:= 1;
    if c = '\n' then resultis byte 0 of buffer } }

let inch2() be
{ if buff_num > buff_ptr then
  { let c = byte buff_ptr of buffer;
    buff_ptr +:= 1;
    resultis c }
  buff_ptr := 1;
  buff_num := 0;
  while true do
  { let c = inch_unbuff();
    if c = 8 \/ c = 127 then
    { if buff_num > 0 then
      { buff_num -:= 1;
        out("%c %c", 8, 8) }
      loop }
    outch(c);
    byte buff_num of buffer := c;
    unless buff_num > buff_max do buff_num +:= 1;
    resultis byte 0 of buffer } }


let inno() be
{ let n = 0, c, s = 0;
  c := inch() repeatuntil c>='0' /\ c<='9' \/ c='-' \/ c='+';
  test c='-' then 
  { s := 1;
    c := inch() }
  or if c='+' then
    c := inch();
  while c>='0' /\ c<='9' do
  { n := n * 10 + c - '0';
    c := inch() }
  if s then
    resultis -n;
  resultis n }

let devctl(op, unit, p1, p2, p3) be
{ let p = vec(5), r = 0;
  p ! 0 := op;
  p ! 1 := unit;
  p ! 2 := p1;
  p ! 3 := p2;
  p ! 4 := p3;
  assembly
  { load  R2, [<p>]
    peri  R1, R2
    store R1, [<r>] }
  resultis r }

let devctlv(p) be
{ let r = 0;
  assembly
  { load  R2, [<p>]
    peri  R1, R2
    store R1, [<r>] }
  resultis r }

let seconds() be
{ let n = 0;
  assembly
  { load  R1, $SECONDS
    store R1, [<n>]
    peri  R1, <n> } }

let sleep(n) be
{ let endtime = seconds()+n;
  until seconds() >= endtime do
    assembly { pause } }

let datetime(t, v) be
{ let p = vec 9;
  p ! 1 := t;
  assembly
  { load  R1, $DATETIME
    load  R2, [<p>]
    store R1, [R2]
    peri  R1, R2 }
  for i = 2 to 8 do
    v ! (i-2) := p ! i }

let datetime2(v) be
{ let t = vec 3, p = vec 9, x;
  assembly
  { load  R1, $USECONDS
    load  R2, [<t>]
    store R1, [R2]
    peri  R1, R2 }
  p ! 1 := t ! 1;
  assembly
  { load  R1, $DATETIME
    load  R2, [<p>]
    store R1, [R2]
    peri  R1, R2 }
  x := 0;
  (selector 13 : 19) from x := p ! 2;
  (selector 4 : 15) from x := p ! 3;
  (selector 5 : 10) from x := p ! 4;
  (selector 3 : 7) from x := p ! 5;
  v ! 0 := x;
  x := 0;
  (selector 5 : 27) from x := p ! 6;
  (selector 6 : 21) from x := p ! 7;
  (selector 6 : 15) from x := p ! 8;
  (selector 10 : 5) from x := t ! 2;
  v ! 1 := x; }

let printLongDate(longDate) be {
  let year, month, day, dow, hour, minute, secs;
  year := longDate ! 0;
  month := longDate ! 1;
  day := longDate ! 2;
  dow := longDate ! 3;
  hour := longDate ! 4;
  minute := longDate ! 5;
  secs := longDate ! 6;
  out("%02d/%02d/%04d %02d:%02d:%04d", month, day, year, hour, minute, secs);
}

let printShortDate(shortDate) be {
  let year, month, day, dow, hour, minute, secs, msecs;
  year := shortDate ! 0 >> 19;
  month := (shortDate ! 0 bitand 0b00000000000001111000000000000000) >> 15;
  day := (shortDate ! 0 bitand 0b00000000000000000111110000000000) >> 10;
  dow := (shortDate ! 0 bitand 0b00000000000000000000001110000000) >> 7;
  hour := (shortDate ! 1 bitand 0b11111000000000000000000000000000) >> 27;
  minute := (shortDate ! 1 bitand 0b00000111111000000000000000000000) >> 21;
  secs := (shortDate ! 1 bitand 0b00000000000111111000000000000000) >> 15;
  msecs := (shortDate ! 1 bitand 0b00000000000000000111111111100000) >> 5;
  out("%02d/%02d/%04d %02d:%02d:%04d", month, day, year, hour, minute, secs);
}

let random(max) be
{ static { seed = 872364821 };
  if max < 0 then 
  { seed := seconds();
    return }
  seed := seed * 628191 + 361;
  resultis (seed bitand 0x7FFFFFFF) rem (max + 1) }

static {
  HEAP_PTR = nil,                                               //Ptr to base of heap
  HEAP_SIZE = nil,                                              //Number of words currently used in heap
  HEAP_CAP = nil,                                               //Total capacity for heap
  HEAP_FREE_HEAD = nil                                          //Ptr to first available chunck
}

manifest {
  USED = 0b10101010101010101010101010101010,
  FREE = 0b01010101010101010101010101010101,
  INVALID_WORD = 0b10011001100110011001100110011001,      /*Used for excess memory stored by
                                                            heap for proper*/
  ENTRY_ABOVE_SIZE = -1,                                  //Size of prev one on top of status    
  ENTRY_STATUS = 0,                                       //Will contain USED or FREE
  ENTRY_PREV = 1,                                         //Ptr to previous free entry if freed
  ENTRY_NEXT = 2,                                         //Ptr to next free entry if freed
  ENTRY_SIZE = 3,                                         //Total size of the block       
  ENTRY_DATA = 4,                                         //Where data starts for entry

  ENTRY_FORMAT_SPACE = 4,                                 //Space needed to manage entry
  MINIMUM_SIZE = 4,                                       //Same as space needed to manage an entry

  T = 1,
  F = 0,

  END = nil                                                //Used to determine end of linked list
}

let printHeapEntry(heapEntry) be {
  let heapPtr, status, prev, next, size;
  heapPtr := heapEntry - ENTRY_FORMAT_SPACE;
  status := heapPtr ! ENTRY_STATUS = FREE -> "FREE", "USED";
  prev := heapPtr ! ENTRY_PREV /= nil -> heapPtr ! ENTRY_PREV, nil;
  next := heapPtr ! ENTRY_NEXT /= nil -> heapPtr ! ENTRY_NEXT, nil;
  size := heapPtr ! ENTRY_SIZE;
  out("Address: %d | Status: %s | Prev: %d | Next: %d | Size: %d\n", 
    heapPtr, status, prev, next, size);
}

let printHeap(vecPtr, vecSize) be {
  let iterator = vecPtr, prevIterator;
  out("Heap: %d | Capacity: %d\n", vecPtr, vecSize);
  while (iterator < (vecPtr + vecSize)) do {
    printHeapEntry(iterator + ENTRY_DATA);//Shifting as if passed from outside
    prevIterator := iterator;
    iterator +:= (iterator ! ENTRY_SIZE);
    if prevIterator = iterator then {
      out("Houston We Have A PROBLEM!\n");
      break;
    }
  }
  out("\n");
}

let printFreeList() be {
  let iterator = HEAP_FREE_HEAD;
  while (iterator /= END) do {
    printHeapEntry(iterator + ENTRY_DATA);//Shifting as if passed from outside
    iterator := (iterator ! ENTRY_NEXT);
  }
  out("\n");
}

let getProperEntrySize(size) be {
  let newEntrySize = ENTRY_FORMAT_SPACE + size;
  if (size = 0) then resultis ENTRY_FORMAT_SPACE;
  newEntrySize +:= (MINIMUM_SIZE - (size rem 4));//Adds cushion to allow copy of size at end
  resultis newEntrySize
}

let forwardPrevToNext(heapEntry) be {
  if (heapEntry ! ENTRY_PREV /= nil) then {
    heapEntry ! ENTRY_PREV ! ENTRY_NEXT := heapEntry ! ENTRY_NEXT
  }
  if (heapEntry ! ENTRY_NEXT /= nil) then  {
    heapEntry ! ENTRY_NEXT ! ENTRY_PREV := heapEntry ! ENTRY_PREV
  }
  if (HEAP_FREE_HEAD = heapEntry) then {
    HEAP_FREE_HEAD := heapEntry ! ENTRY_NEXT
  }
}

let storeCopyOfSize(heapEntry) be {
  let entrySize = heapEntry ! ENTRY_SIZE;
  heapEntry ! (entrySize - 1) := entrySize
}

let formatHeapEntryForUse(heapEntry, heapEntrySize, dataSize) be {
  // out("Formatting heapEntry: %d\n", heapEntry);
  heapEntry ! ENTRY_STATUS := USED;
  heapEntry ! ENTRY_PREV := nil;
  heapEntry ! ENTRY_NEXT := nil;
  heapEntry ! ENTRY_SIZE := heapEntrySize;
  for i = 0 to dataSize - 1 by 1 do {
    heapEntry ! (ENTRY_DATA + i) := nil
  }
  for i = ENTRY_DATA + dataSize to heapEntrySize - 2 by 1 do {
    heapEntry ! i := INVALID_WORD
  }
  storeCopyOfSize(heapEntry);
  // out("DONE Formatting heapEntry: %d\n", heapEntry);
}

let addToFront(freeMemPtr) be {
  freeMemPtr ! ENTRY_PREV := nil;
  freeMemPtr ! ENTRY_NEXT := HEAP_FREE_HEAD;
  if (freeMemPtr ! ENTRY_NEXT /= END) then {//Updating next link with current address
    freeMemPtr ! ENTRY_NEXT ! ENTRY_PREV := freeMemPtr
  }
  HEAP_FREE_HEAD := freeMemPtr
}

let appendToTopBlock(topEntry, freedMemEntry) be {
  let topEntrySize = topEntry ! ENTRY_SIZE, freedMemSize = freedMemEntry ! ENTRY_SIZE;
  topEntry ! ENTRY_SIZE := topEntrySize + freedMemSize;
  storeCopyOfSize(topEntry);
  if HEAP_FREE_HEAD = freedMemEntry then {
    HEAP_FREE_HEAD := topEntry
  }
  freedMemEntry ! ENTRY_STATUS := nil;
  freedMemEntry ! ENTRY_PREV := nil;
  freedMemEntry ! ENTRY_NEXT := nil;
  freedMemEntry ! ENTRY_SIZE := nil;
}

let myNewVec(size) be {
  let newEntrySize, freeMemPtr = HEAP_FREE_HEAD, bestMemBlk = nil, remSize;
  if (size < 0) then {
    //Throw some error, no negative memory can be used
    resultis -1; //Indicating failure
  }
  newEntrySize := getProperEntrySize(size);
  until (freeMemPtr = END) do {
    if (freeMemPtr ! ENTRY_SIZE >= newEntrySize) then {
      if ((bestMemBlk = nil) \/ (bestMemBlk ! ENTRY_SIZE > freeMemPtr ! ENTRY_SIZE)) then {
        bestMemBlk := freeMemPtr
      }
    } 
    freeMemPtr := freeMemPtr ! ENTRY_NEXT
  }

  if (bestMemBlk = nil) then {
    //TODO ask for more space and then allocate newEntry
    out("Insuficient space for new entry, size: %d\n", newEntrySize);
    printHeap(HEAP_PTR, HEAP_SIZE);
    printFreeList();
    return
  }
  if (newEntrySize < bestMemBlk ! ENTRY_SIZE) then {//Must split block with new entry on top
    freeMemPtr := bestMemBlk + newEntrySize;
    freeMemPtr ! ENTRY_STATUS := FREE;
    freeMemPtr ! ENTRY_PREV := bestMemBlk ! ENTRY_PREV;
    freeMemPtr ! ENTRY_NEXT := bestMemBlk ! ENTRY_NEXT;
    freeMemPtr ! ENTRY_SIZE := (bestMemBlk ! ENTRY_SIZE) - newEntrySize;
    storeCopyOfSize(freeMemPtr);
    if bestMemBlk = HEAP_FREE_HEAD then {
      HEAP_FREE_HEAD := freeMemPtr;
    }
    if (freeMemPtr ! ENTRY_PREV /= 0) then { 
      freeMemPtr ! ENTRY_PREV ! ENTRY_NEXT := freeMemPtr
    }
    if (freeMemPtr ! ENTRY_NEXT /= 0) then { 
      freeMemPtr ! ENTRY_NEXT ! ENTRY_PREV := freeMemPtr
    }
  }
  formatHeapEntryForUse(bestMemBlk, newEntrySize, size);
  HEAP_SIZE +:= newEntrySize;
  test size > 0 then {
    resultis bestMemBlk + ENTRY_DATA;
  } else {
    resultis bestMemBlk + ENTRY_SIZE;//No data for entry so just returning size
  }
}

let myFreeVec(entryPtr) be {
  let freeMemPtr, freeMemSize, entryAbove = nil, entryAfter = nil, 
    entryAboveSize, entryAfterSize, aboveFree, afterFree;
  // printHeap(HEAP_PTR, HEAP_CAP);
  freeMemPtr := entryPtr - ENTRY_FORMAT_SPACE; 
  if freeMemPtr ! ENTRY_STATUS /= FREE /\ 
    freeMemPtr ! ENTRY_STATUS /= USED then {
      if (entryPtr ! -1) /= 0 then {
        printHeap(HEAP_PTR, HEAP_CAP);
        out("Invalid ptr passed: %d\n", entryPtr);
        finish
      }
  }

  freeMemSize := freeMemPtr ! ENTRY_SIZE;
  if (freeMemPtr ! ENTRY_STATUS /= USED) then {
    //Should throw some sort of interrupt of exception
    printHeapEntry(freeMemPtr);
    out("HeapEntry: %d | NOT IN USE\n\n", freeMemPtr);
    return;
  } 
  
  test freeMemPtr > HEAP_PTR then {
    entryAboveSize := freeMemPtr ! ENTRY_ABOVE_SIZE;
    entryAbove := freeMemPtr - entryAboveSize;
    aboveFree := entryAbove ! ENTRY_STATUS = FREE -> T, F;
  } else {//FreeMemPtr at top of heap, has no entry above
    aboveFree := F
  }

  test (freeMemPtr + freeMemSize) < (HEAP_PTR + HEAP_CAP) then {
    entryAfter := freeMemPtr + freeMemSize;
    entryAfterSize := entryAfter ! ENTRY_SIZE;
    afterFree := entryAfter ! ENTRY_STATUS = FREE -> T, F;
  } else {//FreeMemPtr at bottom of heap, has no entry after
    afterFree := F
  }

  freeMemPtr ! ENTRY_STATUS := FREE;
  freeMemPtr ! ENTRY_PREV := nil;
  freeMemPtr ! ENTRY_NEXT := nil;
  HEAP_SIZE -:= freeMemSize;

  if (aboveFree = F /\ afterFree = F) then {//No combining
    addToFront(freeMemPtr)
  }

  if (aboveFree = T) then {//Combine with top
    appendToTopBlock(entryAbove, freeMemPtr);
    freeMemPtr := entryAbove;
  }

  if (afterFree = T) then {//Append Bottom, addToFront is top not free
    forwardPrevToNext(entryAfter);
    appendToTopBlock(freeMemPtr, entryAfter);
    if (aboveFree = F) then addToFront(freeMemPtr); 
  }
  // printHeap(HEAP_PTR, HEAP_CAP);
}

let myInit(heapPtr, size) be {
  HEAP_PTR := heapPtr;
  HEAP_CAP := size;
  HEAP_FREE_HEAD := HEAP_PTR;
  HEAP_FREE_HEAD ! ENTRY_STATUS := FREE;
  HEAP_FREE_HEAD ! ENTRY_PREV := nil;
  HEAP_FREE_HEAD ! ENTRY_NEXT := END;
  HEAP_FREE_HEAD ! ENTRY_SIZE := size;
  storeCopyOfSize(HEAP_FREE_HEAD);
}

static {
  init = myInit,
  newvec = myNewVec,
  freevec = myFreeVec
}