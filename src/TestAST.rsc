module TestAST

import Syntax;
import ParseTree;
import IO;

public void runAllTests(){
    str fileContent = readFile(|cwd:///examples/tests/simple.myql|);
    Tree t = testSimple(fileContent);
    println("Tree: ");
    println(t);
}

public Tree testSimple(str input){
    Tree res = parse(#start[Form], input);
    return res;
}

