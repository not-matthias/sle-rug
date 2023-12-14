module TestAST

import Syntax;
import ParseTree;
import AST;
import CST2AST;
import IO;

public void runAllTests(){
    // AForm t = testSimple(readFile(|cwd:///examples/tests/ast.myql|));
    // println("AForm: ");
    // println(t);

    AForm t = testSimple(readFile(|cwd:///examples/binary.myql|));
    println("AForm: ");
    println(t);
}


public AForm testSimple(str input){
    Tree parsed = parse(#start[Form], input);
    return cst2ast(parsed);
}

