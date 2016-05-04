import "io"

let enable_ints(v) be
{ assembly
  { load  r1, [<v>]
    setsr r1, $intvec      // set special register
    load  r1, 0
    setfl r1, $ip          // set flag "interrupt being processed"
} }

let set_timer(t) be
{ assembly
  { load  r1, [<t>]
    setsr r1, $timer } }

let stop = false;

let kbbuff = vec(25),
    kbbs = 0, kbbe = 0, kbbn = 0, kbbmax = 99, kbblines = 0;

let kbbadd(c) be
{ if kbbn >= kbbmax then resultis 0;
  byte kbbe of kbbuff := c;
  if c = '\n' then kbblines +:= 1;
  kbbn +:= 1;
  kbbe +:= 1;
  if kbbe > kbbmax then kbbe := 0;
  resultis 1 }

let kbbunadd() be
{ let newkbbe = kbbe - 1, c;
  if newkbbe < 0 then newkbbe := kbbmax;
  c := byte newkbbe of kbbuff;
  if c = '\n' \/ kbbn = 0 then resultis 0;
  kbbe := newkbbe;
  kbbn -:= 1;
  resultis 1 }

let kbbremove() be
{ let c;
  if kbblines = 0 then resultis 0;
  c := byte kbbs of kbbuff;
  kbbn -:= 1;
  kbbs +:= 1;
  if kbbs > kbbmax then kbbs := 0;
  if c = '\n' then kbblines -:= 1;
  resultis c }

let kbbackch() be
{ let c;
  if kbbn >= kbbmax + 1 then return;
  kbbs -:= 1;
  if kbbs < 0 then kbbs := kbbmax;
  kbbn +:= 1;
  c := byte kbbs of kbbuff;
  if c = '\n' then kbblines +:= 1 }

let minch() be
{ let c = 0;
  while true do
  { c := kbbremove();
    if c <> 0 then
      resultis c;
    assembly { pause } } }

let keyboard_handler() be
{ let c, v = vec 3;
  assembly
  { load  r1, [<v>]
    load  r2, $terminc
    store r2, [r1+0]
    load  r2, 1
    store r2, [r1+1]
    load  r2, <c>
    store r2, [r1+2]
    peri  r2, r1 }
  test c < 32 /\ c <> '\n' then
  { test c = 'H'-64 then
    { if kbbunadd() then
        assembly
        { type 8
          type ' '
          type 8 } }
    else test c = 'X'-64 then 
      stop := true
    else
    { kbbadd(c);
      out("[%d]", c) } }
  else
  { if kbbadd(c) then
      assembly
      { type [<c>] } }
  ireturn }

manifest
{ PCB_FLAGS = 0, PCB_INTCODE = 1, PCB_INTADDR = 2, PCB_INTX = 3, PCB_PC = 4,
  PCB_FP = 5, PCB_SP = 6, PCB_R12 = 7, PCB_R11 = 8, PCB_R10 = 9, PCB_R9 = 10,
  PCB_R8 = 11, PCB_R7 = 12, PCB_R6 = 13, PCB_R5 = 14, PCB_R4 = 15,
  PCB_R3 = 16, PCB_R2 = 17, PCB_R1 = 18, PCB_R0 = 19, PCB_STATE = 20,
  SIZEOF_PCB = 21 }

manifest
{ FLAG_R = 1, FLAG_Z = 2, FLAG_N = 4, FLAG_ERR = 8, FLAG_SYS = 16, FLAG_IP = 32, FLAG_VM = 64 }

let make_pcb(pcb, pc, sp, code) be
{ pcb ! PCB_R0 := 0;
  pcb ! PCB_R1 := 1*code;
  pcb ! PCB_R2 := 2*code;
  pcb ! PCB_R3 := 3*code;
  pcb ! PCB_R4 := 4*code;
  pcb ! PCB_R5 := 5*code;
  pcb ! PCB_R6 := 6*code;
  pcb ! PCB_R7 := 7*code;
  pcb ! PCB_R8 := 8*code;
  pcb ! PCB_R9 := 9*code;
  pcb ! PCB_R10 := 10*code;
  pcb ! PCB_R11 := 11*code;
  pcb ! PCB_R12 := 12*code;
  pcb ! PCB_SP := sp;
  pcb ! PCB_FP := sp;
  pcb ! PCB_PC := pc;
  pcb ! PCB_INTX := 0;
  pcb ! PCB_INTADDR := 0;
  pcb ! PCB_INTCODE := 0;
  pcb ! PCB_FLAGS := FLAG_R;
  pcb ! PCB_STATE := 'R' }

let compute_1() be
{ let x = 0;
  for i = 0 to 1000 do
  { out("%d ", x);
    if stop then break;
    for j = 1 to 500 do
    { if stop then break;
      for k = 0 to 1000 do
        x +:= 1;
      for k = 0 to 999 do
        x -:= 1 } }
  out("\nall done\n") }

let compute_2() be
{ let x = 59;
  for i = 0 to 1000 do
  { out("%d ", x);
    if stop then break;
    for j = 1 to 400 do
    { if stop then break;
      for k = 0 to 1000 do
        x +:= 1;
      for k = 0 to 999 do
        x -:= 1 } }
  out("\nall done\n") }

manifest
{ iv_none = 0,        iv_memory = 1,      iv_pagefault = 2,   iv_unimpop = 3,
  iv_halt = 4,        iv_divzero = 5,     iv_unwrop = 6,      iv_timer = 7,
  iv_privop = 8,      iv_keybd = 9,       iv_badcall = 10,    iv_pagepriv = 11,
  iv_debug = 12,      iv_intrfault = 13 }

manifest { USER_STACK_SIZE = 1000 }

static
{ curr_proc = 0;
  num_procs = 0;
  proc_table = vec(3) }
  
let start_process(pn) be
{ let pcb = proc_table ! pn;
  let sp = pcb ! PCB_SP;
  let fp = pcb ! PCB_FP;
  curr_proc := pn;
  assembly
  { load  r1, [<sp>]
    setsr r1, $usrsp
    load  r1, [<fp>]
    setsr r1, $usrfp
    load  r1, [<pcb>]
    add   r1, <PCB_R0>
    load  r2, 19
    push  [r1]
    dec   r1
    dec   r2
    jpos  r2, pc-4
    push  40
    iret } }

let timer_handler(intcode, intaddr, intx, pc, fp, sp, r12, r11,
                  r10, r9, r8, r7, r6, r5, r4, r3, r2, r1, r0) be
{ static { count = 0 }
  let pn = curr_proc;
  count +:= 1;
  if count = 100 then
  { outs("\n  Boo!\n");
    count := 0 }
  while true do
  { pn +:= 1;
    if pn > num_procs then pn := 1;
    if pn = curr_proc then break;
    if proc_table ! pn ! PCB_STATE = 'R' then break }
  set_timer(500000);
  unless pn = curr_proc do
  { let pcb = proc_table ! curr_proc, 
        ptr = @intcode - 1;
    assembly
    { load  r1, [<pcb>]
      load  r2, [<ptr>]
      load  r3, 19
      load  r4, [r2]
      store r4, [r1]
      inc   r1
      inc   r2
      dec   r3
      jpos  r3, pc-6 }
    curr_proc := pn;
    pcb := proc_table ! curr_proc;
    ptr := @intcode - 1;
    assembly
    { load  r1, [<pcb>]
      load  r2, [<ptr>]
      load  r3, 19
      load  r4, [r1]
      store r4, [r2]
      inc   r1
      inc   r2
      dec   r3
      jpos  r3, pc-6 } }
  ireturn }

let start() be
{ let ivec = vec(20), n;
  let user_stack_1 = vec(USER_STACK_SIZE), user_stack_2 = vec(USER_STACK_SIZE);
  let pcb_1 = vec(SIZEOF_PCB), pcb_2 = vec(SIZEOF_PCB);

  proc_table ! 0 := nil;
  proc_table ! 1 := pcb_1;
  proc_table ! 2 := pcb_2;
  num_procs := 2;

  make_pcb(pcb_1, compute_1, user_stack_1 + USER_STACK_SIZE, 101);
  make_pcb(pcb_2, compute_2, user_stack_2 + USER_STACK_SIZE, 10101);

  for i = 0 to 19 do
    ivec ! i := nil;

  ivec ! iv_timer := timer_handler;      
  ivec ! iv_keybd := keyboard_handler;   // these are the handlers constantly running
  
  enable_ints(ivec);
  inch := minch;
  set_timer(500000);

  start_process(1);

  out("What is your favourite number? ");
  n := inno();
  out("Yuck! %d is terrible\n", n); }
