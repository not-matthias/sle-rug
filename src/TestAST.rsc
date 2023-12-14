module TestAST

import Syntax;
import ParseTree;
import AST;
import CST2AST;
import IO;

public void runAllTests(){
    str fileContent = readFile(|cwd:///examples/tests/simple.myql|);
    Tree parsed = parse(#start[Form], fileContent);
    println("ParseTree: ");
    println(parsed);
    
    AForm t = testSimple(parsed);
    println("AForm: ");
    println(t);
}


public AForm testSimple(start[Form] input){
    return cst2ast(input);
}

