import "io"

export {
	memset, memsetoffset, memcpy, strcpy, strcat, tolowercase, strcmp, 
	strcasecmp, fixed_to_str, str_to_fixed, instr, getline
}

let memset(src, val, nbytes) be {
	for i = 0 to nbytes - 1 by 1 do {
		byte i of src := val
	}
	resultis src
}

let memsetoffset(src, val, nbytes, offset) be {
	for i = offset to (nbytes + offset - 1) by 1 do {
		byte i of src := val;
	}
	resultis src
}

let memcpy(dest, src, nbytes) be {
	for i = 0 to nbytes - 1 by 1 do {
		byte i of dest := byte i of src;
	}
	resultis dest
}

let memcpyoffset(dest, src, offset, nbytes) be {
	for i = offset to (nbytes + offset - 1) by 1 do {
		byte i of dest := byte i of src;
	}
	resultis dest
}

let strcpy(dest, src) be {
	let i = 0;
	{	byte i of dest := byte i of src;
		i +:= 1
	} repeatwhile byte (i - 1) of src /= nil; //Until nil terminator found
	resultis dest
}

let strcat(dest, src) be {
	let i = strlen(dest), j = 0;
	{	byte i of dest := byte j of src;
		i +:= 1;
		j +:= 1;
	} repeatwhile byte (j - 1) of src /= nil; //Until nil terminator found
	resultis dest
}

let tolowercase(character) be {
	let res = character;
	if (65 <= character /\ character <= 90) then res +:= 32;
	resultis res;
}

let strcmp(str1, str2) be {
	let i = 0, res = 0, len1 = strlen(str1), len2 = strlen(str2), smaller, maxLen;
	smaller := (len1 < len2) -> -1, 1;
	maxLen := (smaller = -1) -> len1, len2;
	for i = 0 to maxLen by 1 do {
		if (byte i of str1 < byte i of str2) then resultis -1;
		if (byte i of str1 > byte i of str2) then resultis 1;
	}
	resultis (len1 = len2) -> 0, smaller;
}

let strcasecmp(str1, str2) be {
	let i = 0, res = 0, len1 = strlen(str1), len2 = strlen(str2), smaller, maxLen;
	smaller := (len1 < len2) -> -1, 1;
	maxLen := (smaller = -1) -> len1, len2;
	for i = 0 to maxLen by 1 do {
		if (tolowercase(byte i of str1) < tolowercase(byte i of str2)) then resultis -1;
		if (tolowercase(byte i of str1) > tolowercase(byte i of str2)) then resultis 1;
	}
	resultis (len1 = len2) -> 0, smaller;
}

let fixed_to_str(str, arr, nbytes) be {
	for i = 0 to nbytes - 1 by 1 do {
		byte i of str := byte i of arr;
	}
	byte nbytes of str := nil;
	resultis str;
}

let str_to_fixed(arr, nbytes, str) be {
	let len = strlen(str), n = nbytes;
	test (len < n) then {
		for i = 0 to len - 1 by 1 do 
			byte i of arr := byte i of str;
		for i = len to nbytes - 1 by 1 do 
			byte i of arr := nil
	} else {
		for i = 0 to nbytes - 1 by 1 do 
			byte i of arr := nil
	}
	resultis arr;
}

let instr(dest, nbytes) be {
	let tmpChar = 0, i = 0;
	while (1) do {
		tmpChar := inch();
		// out("\'%c\'", tmpChar);
		if (tmpChar = '\n' \/ tmpChar = ' ') then {
			if i > 0 then break;
			loop;
		}
		if tmpChar = '\b' then {
			out("\b \b");
			i -:= 1;
			loop
		}
		if (i = nbytes) then break;
		byte i of dest := tmpChar;
		i +:= 1;
	}
	if (i < nbytes) then byte i of dest := nil;//Setting nil terminator
	resultis dest;
}

let getline(dest, nbytes) be {
	let tmpChar = 0, i = 0;
	while (1) do {
		tmpChar := inch();
		// out("\'%c\'", tmpChar);
		if (tmpChar = '\n') then {
			if i > 0 then break;
			loop;
		}
		if tmpChar = '\b' then {
			out("\b \b");
			i -:= 1;
			loop
		}
		if (i = nbytes) then break;
		byte i of dest := tmpChar;
		i +:= 1;
	}
	if (i < nbytes) then byte i of dest := nil;//Setting nil terminator
	resultis dest;
}
