module TestAST

import Syntax;
import ParseTree;
import AST;
import CST2AST;
import IO;

public void runAllTests(){
    AForm t = testSimple(readFile(|cwd:///examples/tests/ast.myql|));
    println("AForm: ");
    println(t);

    testSimple(readFile(|cwd:///examples/binary.myql|));
    testSimple(readFile(|cwd:///examples/cyclic.myql|));
    testSimple(readFile(|cwd:///examples/empty.myql|));
    testSimple(readFile(|cwd:///examples/errors.myql|));
    testSimple(readFile(|cwd:///examples/tax.myql|));
}


public AForm testSimple(str input){
    Tree parsed = parse(#start[Form], input);
    return cst2ast(parsed);
}

