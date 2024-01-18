module TestCompile

import Syntax;
import ParseTree;
import AST;
import CST2AST;
import IO;
import Check;
import Resolve;


import Compile;

public void runAllTests_Compile(){
    // TEST 1: 
    println("TEST 1");
    // testCompile(readFile(|cwd:///examples/binary.myql|));
    testCompile(readFile(|cwd:///examples/binary.myql|));
}


public void testCompile(str input){
    Tree parsed = parse(#start[Form], input);
    AForm f = cst2ast(parsed);

    compile(f);
}
