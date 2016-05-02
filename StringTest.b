import "io"
import "string"

manifest { 
	heapSize = 2048
}
static {
	good = "SUCCESS",
	bad = "FAILURE\n",
	heap = vec(heapSize)
}

let checkArrsEquals(arr1, arr2, nbytes) be {
	for i = 0 to nbytes - 1 by 1 do {
		if (byte i of arr1 /= byte i of arr2) then resultis -1
	}
	resultis 0
}

let setArrWithStr(arr, str, nbytes) be {
	for i = 0 to nbytes - 1 by 1 do {
		byte i of arr := byte i of str;
	}
	resultis arr;
}

let memsetUnitTest() be {//Dependent on strcmp
	manifest {
		vecSize = 20,
		nbytes = 80
	}
	let input = vec(vecSize), output = vec(vecSize), val, n;
	memset(input, nil, nbytes);
	memset(output, nil, nbytes);
	setArrWithStr(input, "Hello World", 12);
	setArrWithStr(output, "$$$$$ World", 12);
	n := 5;
	memset(input, '$', n);
	if (checkArrsEquals(input, output, 20) = -1) then {
		out("1) input: %s | output: %s\n", input, output);
		resultis -1;
	}

	memset(input, nil, nbytes);
	memset(output, nil, nbytes);
	setArrWithStr(input, "Hello World", 12);
	setArrWithStr(output, "$$$$$$$$$$$$$$$$$$$$", 21);
	n := 20;
	memset(input, '$', n);
	if (checkArrsEquals(input, output, 20) = -1) then {
		out("2) input: %s | output: %s\n", input, output);
		resultis -1;
	}

	memset(input, nil, nbytes);
	memset(output, nil, nbytes);
	setArrWithStr(input, "Hello World", 12);
	setArrWithStr(output, "Hello World", 12);
	n := 0;
	memset(input, '$', n);
	if (checkArrsEquals(input, output, 20) = -1) then {
		out("3) input: %s | output: %s\n", input, output);
		resultis -1;
	}

	resultis 0;
}

let memsetoffsetUnitTest() be {//Dependent on strcmp
	manifest {
		vecSize = 20,
		nbytes = 80
	}
	let input = vec(vecSize), output = vec(vecSize), val, n, offset;
	
	memsetoffset(input, nil, nbytes, 0);
	memsetoffset(output, nil, nbytes, 0);
	setArrWithStr(input, "Hello World", 12);
	setArrWithStr(output, "He$$$$$orld", 12);
	n := 5;
	offset := 2;
	memsetoffset(input, '$', n, offset);
	if (checkArrsEquals(input, output, 20) = -1) then {
		out("1) input: %s | output: %s\n", input, output);
		resultis -1;
	}

	memsetoffset(input, nil, nbytes, 0);
	memsetoffset(output, nil, nbytes, 0);
	setArrWithStr(input, "Hello World", 12);
	setArrWithStr(output, "Hello$$$$$$$$$$$$$$$", 21);
	n := 15;
	offset := 5;
	memsetoffset(input, '$', n, offset);
	if (checkArrsEquals(input, output, 20) = -1) then {
		out("2) input: %s | output: %s\n", input, output);
		resultis -1;
	}

	memsetoffset(input, nil, nbytes, 0);
	memsetoffset(output, nil, nbytes, 0);
	setArrWithStr(input, "Hello World", 12);
	setArrWithStr(output, "Hello $orld", 12);
	n := 1;
	offset := 6;
	memsetoffset(input, '$', n, offset);
	if (checkArrsEquals(input, output, 20) = -1) then {
		out("3) input: %s | output: %s\n", input, output);
		resultis -1;
	}

	resultis 0;
}

let memcpyUnitTest() be {
	let input, tmpStr, output, n;
	input := "Hello World";
	tmpStr := "Smile Homie";
	output := "Smile World";
	n := 5;
	memcpy(input, tmpStr, n);
	if (strcmp(input, output) /= 0) then {
		out("1) input: %s | output: %s\n", input, output);
		resultis -1;
	}
	
	input := "Hello World";
	tmpStr := "Smile Homie";
	output := "Smile Homie";
	n := 11;
	memcpy(input, tmpStr, n);
	if (strcmp(input, output) /= 0) then {
		out("2) input: %s | output: %s\n", input, output);
		resultis -1;
	}

	input := "Hello World";
	tmpStr := "Smile Homie";
	output := "Hello World";
	n := 0;
	memcpy(input, tmpStr, n);
	if (strcmp(input, output) /= 0) then {
		out("3) input: %s | output: %s\n", input, output);
		resultis -1;
	}

	input := "Hello World";
	tmpStr := "Savage";
	output := "Savage";
	n := 10;
	memcpy(input, tmpStr, n);
	if (strcmp(input, output) /= 0) then {
		out("4) input: %s | output: %s\n", input, output);
		resultis -1;
	}

	resultis 0;	
}
 
let strcpyUnitTest() be {
	let input, tmpStr, output, n;
	
	input := "Hello World";
	tmpStr := "Smile Homie";
	output := "Smile Homie";
	strcpy(input, tmpStr);
	if (strcmp(input, output) /= 0) then {
		out("1) input: %s | output: %s\n", input, output);
		resultis -1;
	}
	
	input := "Hello World";
	tmpStr := "What the Heck?";
	output := "What the Heck?";
	strcpy(input, tmpStr);
	if (strcmp(input, output) /= 0) then {
		out("2) input: %s | output: %s\n", input, output);
		resultis -1;
	}
	input := "What the Heck?";
	tmpStr := "Hello World";
	output := "Hello World";
	strcpy(input, tmpStr);
	if (strcmp(input, output) /= 0) then {
		out("3) input: %s | output: %s\n", input, output);
		resultis -1;
	}

	resultis 0;	
}

let strcatUnitTest() be {
	let input, tmpStr, output, n;

	input := "Hello ";
	tmpStr := "World";
	output := "Hello World";
	strcat(input, tmpStr);
	if (strcmp(input, output) /= 0) then {
		out("1) input: %s | output: %s\n", input, output);
		resultis -1;
	}

	input := "";
	tmpStr := "World";
	output := "World";
	strcat(input, tmpStr);
	if (strcmp(input, output) /= 0) then {
		out("2) input: %s | output: %s\n", input, output);
		resultis -1;
	}

	input := "Hello ";
	tmpStr := "";
	output := "Hello ";
	strcat(input, tmpStr);
	if (strcmp(input, output) /= 0) then {
		out("3) input: %s | output: %s\n", input, output);
		resultis -1;
	}

	resultis 0;
}

let tolowercaseUnitTest() be {
	let input, tmpChar, output;

	input := 'A';
	output := 'a';
	tmpChar := tolowercase(input);
	if (tmpChar /= output) then {
		out("1) input: \'%c\' | tmpChar: \'%c\' | output: \'%c\'\n", input, tmpChar, output);
		resultis -1;
	}

	input := 'Z';
	output := 'z';
	tmpChar := tolowercase(input);
	if (tmpChar /= output) then {
		out("2) input: \'%c\' | tmpChar: \'%c\' | output: \'%c\'\n", input, tmpChar, output);
		resultis -1;
	}

	input := 'm';
	output := 'm';
	tmpChar := tolowercase(input);
	if (tmpChar /= output) then {
		out("3) input: \'%c\' | tmpChar: \'%c\' | output: \'%c\'\n", input, tmpChar, output);
		resultis -1;
	}

	input := '[';
	output := '[';
	tmpChar := tolowercase(input);
	if (tmpChar /= output) then {
		out("4) input: \'%c\' | tmpChar: \'%c\' | output: \'%c\'\n", input, tmpChar, output);
		resultis -1;
	}

	resultis 0;
}

let strcmpUnitTest() be {
	let str1, str2, output;
	
	str1 := "Sorry World";
	str2 := "Hello World";
	output := strcmp(str1, str2);
	if (output /= 1) then {
		out("str1 : \'%s\' | str2 : \'%s\' | output: %d\n", str1, str2, output);
		resultis -1;
	}

	str1 := "Hello World";
	str2 := "Hello World";
	output := strcmp(str1, str2);
	if (output /= 0) then {
		out("str1 : \'%s\' | str2 : \'%s\' | output: %d\n", str1, str2, output);
		resultis -1;
	}

	str1 := "";
	str2 := "";
	output := strcmp(str1, str2);
	if (output /= 0) then {
		out("str1 : \'%s\' | str2 : \'%s\' | output: %d\n", str1, str2, output);
		resultis -1;
	}

	str1 := "Apple";
	str2 := "Hello ";
	output := strcmp(str1, str2);
	if (output /= -1) then {
		out("str1 : \'%s\' | str2 : \'%s\' | output: %d\n", str1, str2, output);
		resultis -1;
	}

	str1 := "apple";
	str2 := "Hello ";
	output := strcmp(str1, str2);
	if (output /= 1) then {
		out("str1 : \'%s\' | str2 : \'%s\' | output: %d\n", str1, str2, output);
		resultis -1;
	}

	resultis 0;
}

let strcasecmpUnitTest() be {
	let str1, str2, output;
	
	str1 := "Hello World";
	str2 := "soRRy World";
	output := strcasecmp(str1, str2);
	if (output /= -1) then {
		out("str1 : \'%s\' | str2 : \'%s\' | output: %d\n", str1, str2, output);
		resultis -1;
	}

	str1 := "hello world";
	str2 := "HELLO WORLD";
	output := strcasecmp(str1, str2);
	if (output /= 0) then {
		out("str1 : \'%s\' | str2 : \'%s\' | output: %d\n", str1, str2, output);
		resultis -1;
	}

	str1 := "";
	str2 := "";
	output := strcasecmp(str1, str2);
	if (output /= 0) then {
		out("str1 : \'%s\' | str2 : \'%s\' | output: %d\n", str1, str2, output);
		resultis -1;
	}

	str1 := "Apple";
	str2 := "Hello ";
	output := strcasecmp(str1, str2);
	if (output /= -1) then {
		out("str1 : \'%s\' | str2 : \'%s\' | output: %d\n", str1, str2, output);
		resultis -1;
	}

	resultis 0;
}

let fixed_to_stringUnitTest() be {//dependent on memset to clear vector
	manifest {
		vecSize = 20,
		nbytes = 80
	}
	let fixed = vec(vecSize), str, output, n;

	setArrWithStr(fixed, "Hello World", 11);
	n := 11;
	str := fixed_to_str(str, fixed, n);
	output := "Hello World";
	if strcmp(str, output) /= 0 then {
		out("input: %s | output: %s\n", str, output);
		resultis -1;
	}

	setArrWithStr(fixed, "Hello World", 11);
	n := 5;
	str := fixed_to_str(str, fixed, n);
	output := "Hello";
	if strcmp(str, output) /= 0 then {
		out("input: %s | output: %s\n", str, output);
		resultis -1;
	}

	setArrWithStr(fixed, "Hello World", 11);
	n := 0;
	str := fixed_to_str(str, fixed, n);
	output := "";
	if strcmp(str, output) /= 0 then {
		out("input: %s | output: %s\n", str, output);
		resultis -1;
	}

	resultis 0;
}

let string_to_fixedUnitTest() be {
	manifest {
		vecSize = 20,
		nbytes = 80
	}
	let fixed = vec(vecSize), str, output = vec(vecSize), size, n;

	memset(fixed, nil, nbytes);//Clearing
	memset(output, nil, nbytes);//Clearing
	str_to_fixed(fixed, nbytes, "Hello World");
	setArrWithStr(output, "Hello World", 11);
	if checkArrsEquals(fixed, output, vecSize) /= 0 then {
		out("1) fixed: %s | output: %s\n", fixed, output);
		resultis -1;
	}

	memset(fixed, nil, nbytes);//Clearing
	memset(output, nil, nbytes);//Clearing
	str_to_fixed(fixed, nbytes, "");
	setArrWithStr(output, "", 0);
	if checkArrsEquals(fixed, output, vecSize) /= 0 then {
		out("2) fixed: %s | output: %s\n", fixed, output);
		resultis -1;
	}

	memset(fixed, nil, nbytes);//Clearing
	memset(output, nil, nbytes);//Clearing
	str_to_fixed(fixed, nbytes, "Hello World");
	setArrWithStr(output, "Hello World", 11);
	if checkArrsEquals(fixed, output, vecSize) /= 0 then {
		out("3) fixed: %s | output: %s\n", fixed, output);
		resultis -1;
	}

	resultis 0;
}

let instrUnitTest() be {
	manifest {
		vecSize = 20,
		nbytes = 80
	}
	let input = vec(vecSize), output = vec(vecSize), str;

	memset(input, nil, nbytes);//Clearing
	memset(output, nil, nbytes);//Clearing	
	str := "Hello";
	out("Type \'%s\' exactly.\n", str);
	instr(input, nbytes);
	setArrWithStr(output, str, strlen(str) + 1);
	if strcasecmp(input, output) /= 0 then {
		out("input: %s | output: %s\n", input, output);
		resultis -1;
	}

	memset(input, nil, nbytes);//Clearing
	memset(output, nil, nbytes);//Clearing	
	str := "Hello_World";
	out("Type \'%s\' exactly.\n", str);
	instr(input, nbytes);
	setArrWithStr(output, str, strlen(str) + 1);
	if checkArrsEquals(input, output, nbytes) /= 0 then {
		out("input: %s | output: %s\n", input, output);
		resultis -1;
	}
	resultis 0;
}

let getlineUnitTest() be {
	manifest {
		vecSize = 20,
		nbytes = 80
	}
	let input = vec(vecSize), output = vec(vecSize), str;

	memset(input, nil, nbytes);//Clearing
	memset(output, nil, nbytes);//Clearing	
	str := "Hello World";
	out("Type \'%s\' exactly.\n", str);
	getline(input, nbytes);
	setArrWithStr(output, str, strlen(str) + 1);
	if checkArrsEquals(input, output, nbytes) /= 0 then {
		out("input: %s | output: %s\n", input, output);
		resultis -1;
	}

	resultis 0;
}

let start() be {//Run Tests
	let memsetSatus, memsetoffsetSatus, memcpyStatus, strcpyStatus, strcatStatus, 
		tolowercaseStatus, strcmpStatus, strcasecmpStatus, fixed_to_stringStatus, 
		string_to_fixedStatus, instrStatus, getlineStatus;
	init(heap, heapSize);
	
	memsetSatus := memsetUnitTest() = 0 -> good, bad;
	memsetoffsetSatus := memsetoffsetUnitTest() = 0 -> good, bad;
	memcpyStatus := memcpyUnitTest() = 0 -> good, bad;
	strcpyStatus := strcpyUnitTest() = 0 -> good, bad;
	strcatStatus := strcatUnitTest() = 0 -> good, bad;
	tolowercaseStatus := tolowercaseUnitTest() = 0 -> good, bad;
	strcmpStatus := strcmpUnitTest() = 0 -> good, bad;
	strcasecmpStatus := strcasecmpUnitTest() = 0 -> good, bad;
	fixed_to_stringStatus := fixed_to_stringUnitTest() = 0 -> good, bad;
	string_to_fixedStatus := string_to_fixedUnitTest() = 0 -> good, bad;
	instrStatus := instrUnitTest() = 0 -> good, bad;
	getlineStatus := getlineUnitTest() = 0 -> good, bad;

	out("memset: %s\n", memsetSatus);
	out("memsetoffset: %s\n", memsetoffsetSatus);
	out("memcpy: %s\n", memcpyStatus);
	out("strcpy: %s\n", strcpyStatus);
	out("strcat: %s\n", strcatStatus);
	out("tolowercase: %s\n", tolowercaseStatus);
	out("strcmp: %s\n", strcmpStatus);
	out("strcasecmp: %s\n", strcasecmpStatus);
	out("fixed_to_str: %s\n", fixed_to_stringStatus);
	out("str_to_fixed: %s\n", string_to_fixedStatus);
	out("instr: %s\n", instrStatus);
	out("getline: %s\n", getlineStatus);
}